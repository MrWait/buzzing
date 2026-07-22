use sea_orm::DatabaseConnection;
use loco_rs::Result;

pub struct OpenAppModel;

impl OpenAppModel {
    pub async fn create(
        _db: &DatabaseConnection,
        _owner_id: i64,
        _tenant_id: i64,
        _name: &str,
        _description: &str,
        _app_type: i16,
    ) -> Result<(Self, i64)> {
        unimplemented!()
    }
}
