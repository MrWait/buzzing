use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use sea_orm::Iterable;
use sea_query::OnConflict;

pub use base::models::_entities::settings::{ActiveModel, Column, Entity, Model};
use common::{db_error, pb_decode};
use proto::idl::entity;

#[derive(Debug)]
pub struct SettingModel(pub Model);

// implement your read-oriented logic here
impl SettingModel {
    pub async fn setting_set(
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        setting: &entity::Setting,
    ) -> ModelResult<entity::Setting> {
        let setting = ActiveModel {
            user_id: ActiveValue::set(user_id),
            r#type: ActiveValue::set(t),
            data: ActiveValue::set(setting.encode_to_vec()),
            version: ActiveValue::set(setting.version),
            ..Default::default()
        };
        let pk = <Entity as EntityTrait>::PrimaryKey::iter();
        let db_setting = Entity::insert(setting)
            .on_conflict(
                OnConflict::columns(pk.clone())
                    .update_columns([Column::Data, Column::Version])
                    .to_owned(),
            )
            .exec_with_returning(db)
            .await?;

        let mut set =
            pb_decode::<entity::Setting>(&db_setting.data).map_err(|_| db_error("parse error"))?;
        set.version = db_setting.version;
        Ok(set)
    }

    pub async fn setting_update(
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        f: Box<dyn Fn(entity::Setting) -> Result<entity::Setting> + Send + Sync>,
    ) -> ModelResult<entity::Setting> {
        let setting = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::UserId, user_id)
                    .eq(Column::Type, t)
                    .build(),
            )
            .one(db)
            .await?;
        let setting = setting
            .and_then(|setting| Some(Self(setting).into()))
            .unwrap_or(entity::Setting::default());
        let new = f(setting).map_err(|_| db_error("update setting error"))?;
        Self::setting_set(db, user_id, t, &new).await
    }

    #[allow(dead_code)]
    pub async fn setting_get_all(
        db: &DatabaseConnection,
        user_id: i64,
    ) -> ModelResult<entity::Settings> {
        let mut settings = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::UserId, user_id)
                    .build(),
            )
            .all(db)
            .await?;
        let settings = entity::Settings {
            settings: settings
                .drain(..)
                .filter_map(|setting| {
                    if let Ok(mut set) = pb_decode::<entity::Setting>(&setting.data) {
                        set.version = setting.version;
                        Some((setting.r#type, set))
                    } else {
                        None
                    }
                })
                .collect(),
        };
        Ok(settings)
    }

    pub async fn setting_get(
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
    ) -> ModelResult<Option<entity::Setting>> {
        let setting = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::UserId, user_id)
                    .eq(Column::Type, t)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(setting.and_then(|setting| pb_decode::<entity::Setting>(&setting.data).ok()))
    }
}

impl Into<entity::Setting> for SettingModel {
    fn into(self) -> entity::Setting {
        entity::Setting {
            version: self.0.version,
            data: self.0.data,
        }
    }
}
