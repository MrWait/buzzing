use loco_rs::{auth::jwt, hash, prelude::*};
use serde::{Deserialize, Serialize};

pub use base::models::_entities::accounts::{self};
use common::id_gen;

pub struct Model(pub accounts::Model);

#[derive(Debug, Deserialize, Serialize)]
pub struct LoginParams {
    pub phone: String,
    pub password: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct RegisterParams {
    pub phone: String,
    pub password: String,
    pub name: String,
}

impl Model {
    /// finds a account by the provided phone
    ///
    /// # Errors
    ///
    /// When could not find user by the given token or DB query error
    pub async fn find_by_phone(db: &DatabaseConnection, phone: &str) -> ModelResult<Self> {
        let account = accounts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(accounts::Column::Phone, phone)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(account.ok_or_else(|| ModelError::EntityNotFound)?.into())
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Self> {
        let account = accounts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(accounts::Column::Id, id)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(account.ok_or_else(|| ModelError::EntityNotFound)?.into())
    }

    /// finds a account by the provided verification token
    ///
    /// # Errors
    ///
    /// When could not find account by the given token or DB query error
    pub async fn find_by_verification_token(
        db: &DatabaseConnection,
        token: &str,
    ) -> ModelResult<Self> {
        let account = accounts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(accounts::Column::VerificationToken, token)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(account.ok_or_else(|| ModelError::EntityNotFound)?.into())
    }

    /// finds a account by the provided reset token
    ///
    /// # Errors
    ///
    /// When could not find account by the given token or DB query error
    pub async fn find_by_reset_token(db: &DatabaseConnection, token: &str) -> ModelResult<Self> {
        let account = accounts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(accounts::Column::ResetToken, token)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(account.ok_or_else(|| ModelError::EntityNotFound)?.into())
    }

    /// Verifies whether the provided plain password matches the hashed password
    ///
    /// # Errors
    ///
    /// when could not verify password
    #[must_use]
    pub fn verify_password(&self, password: &str) -> bool {
        hash::verify_password(password, &self.0.password)
    }

    /// Asynchronously creates a account with a password and saves it to the
    /// database.
    ///
    /// # Errors
    ///
    /// When could not save the account into the DB
    pub async fn create_with_password(
        db: &DatabaseConnection,
        params: &RegisterParams,
        avatar: &str,
    ) -> ModelResult<Self> {
        let id = id_gen(None);
        tracing::info!("create new account: {}", id);

        if accounts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(accounts::Column::Phone, &params.phone)
                    .build(),
            )
            .one(db)
            .await?
            .is_some()
        {
            return Err(ModelError::EntityAlreadyExists {});
        }

        tracing::debug!("start gen hash");
        let password_hash =
            hash::hash_password(&params.password).map_err(|e| ModelError::Any(e.into()))?;

        tracing::debug!("insert account");

        let account = accounts::ActiveModel {
            id: ActiveValue::set(id),
            phone: ActiveValue::set(params.phone.to_string()),
            password: ActiveValue::set(password_hash),
            name: ActiveValue::set(params.name.to_string()),
            version: ActiveValue::set(0),
            avatar: ActiveValue::set(Some(avatar.to_string())),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await?;

        tracing::debug!("insert finish");

        Ok(Self(account))
    }

    /// Creates a JWT
    ///
    /// # Errors
    ///
    /// when could not convert account claims to jwt token
    pub fn generate_jwt(&self, secret: &str, expiration: &u64) -> ModelResult<String> {
        Ok(jwt::JWT::new(secret).generate_token(
            *expiration,
            self.0.id.to_string(),
            serde_json::Map::new(),
        )?)
    }
}

impl From<accounts::Model> for Model {
    fn from(value: accounts::Model) -> Self {
        Self(value)
    }
}
