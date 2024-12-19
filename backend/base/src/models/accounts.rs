use chrono::offset::Local;
use loco_rs::{hash, prelude::*};
use serde::Deserialize;
use uuid::Uuid;

pub use super::_entities::accounts::{self, ActiveModel, Entity, Model};

#[derive(Debug, Validate, Deserialize)]
pub struct Validator {
    #[validate(length(min = 11, message = "Phone must be at least 11 characters long."))]
    pub phone: String,
    #[validate(length(min = 2, message = "Name must be at least 2 characters long."))]
    pub name: String,
}

impl Validatable for super::_entities::accounts::ActiveModel {
    fn validator(&self) -> Box<dyn Validate> {
        Box::new(Validator {
            phone: self.phone.as_ref().to_owned(),
            name: self.name.as_ref().to_owned(),
        })
    }
}

#[async_trait::async_trait]
impl ActiveModelBehavior for super::_entities::accounts::ActiveModel {
    async fn before_save<C>(self, _db: &C, insert: bool) -> Result<Self, DbErr>
    where
        C: ConnectionTrait,
    {
        self.validate()?;
        if insert {
            let this = self;
            // this.id = ActiveValue::Set(Uuid::new_v4());
            // this.api_key = ActiveValue::Set(format!("lo-{}", Uuid::new_v4()));
            Ok(this)
        } else {
            Ok(self)
        }
    }
}

impl super::_entities::accounts::ActiveModel {
    /// Sets the phone verification information for the account and
    /// updates it in the database.
    ///
    /// This method is used to record the timestamp when the phone verification
    /// was sent and generate a unique verification token for the account.
    ///
    /// # Errors
    ///
    /// when has DB query error
    pub async fn set_phone_verification_sent(
        mut self,
        db: &DatabaseConnection,
    ) -> ModelResult<Model> {
        self.phone_verification_sent_at = ActiveValue::set(Some(Local::now().into()));
        self.phone_verification_token = ActiveValue::Set(Some(Uuid::new_v4().to_string()));
        Ok(self.update(db).await?)
    }

    /// Sets the information for a reset password request,
    /// generates a unique reset password token, and updates it in the
    /// database.
    ///
    /// This method records the timestamp when the reset password token is sent
    /// and generates a unique token for the account.
    ///
    /// # Arguments
    ///
    /// # Errors
    ///
    /// when has DB query error
    pub async fn set_forgot_password_sent(mut self, db: &DatabaseConnection) -> ModelResult<Model> {
        self.reset_sent_at = ActiveValue::set(Some(Local::now().into()));
        self.reset_token = ActiveValue::Set(Some(Uuid::new_v4().to_string()));
        Ok(self.update(db).await?)
    }

    /// Records the verification time when a account verifies their
    /// email and updates it in the database.
    ///
    /// This method sets the timestamp when the account successfully verifies their
    /// email.
    ///
    /// # Errors
    ///
    /// when has DB query error
    pub async fn verified(mut self, db: &DatabaseConnection) -> ModelResult<Model> {
        self.phone_verified_at = ActiveValue::set(Some(Local::now().into()));
        Ok(self.update(db).await?)
    }

    /// Resets the current account password with a new password and
    /// updates it in the database.
    ///
    /// This method hashes the provided password and sets it as the new password
    /// for the account.
    ///
    /// # Errors
    ///
    /// when has DB query error or could not hashed the given password
    pub async fn reset_password(
        mut self,
        db: &DatabaseConnection,
        password: &str,
    ) -> ModelResult<Model> {
        self.password =
            ActiveValue::set(hash::hash_password(password).map_err(|e| ModelError::Any(e.into()))?);
        self.reset_token = ActiveValue::Set(None);
        self.reset_sent_at = ActiveValue::Set(None);
        Ok(self.update(db).await?)
    }
}
