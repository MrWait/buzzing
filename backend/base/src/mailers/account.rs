// auth mailer
#![allow(non_upper_case_globals)]

use loco_rs::prelude::*;
use serde_json::json;

use crate::models::accounts;

static welcome: Dir<'_> = include_dir!("base/src/mailers/account/welcome");
static forgot: Dir<'_> = include_dir!("base/src/mailers/account/forgot");
// #[derive(Mailer)] // -- disabled for faster build speed. it works. but lets
// move on for now.

#[allow(clippy::module_name_repetitions)]
pub struct AccountMailer {}
impl Mailer for AccountMailer {}
impl AccountMailer {
    /// Sending welcome phone the the given user
    ///
    /// # Errors
    ///
    /// When phone sending is failed
    pub async fn send_welcome(ctx: &AppContext, account: &accounts::Model) -> Result<()> {
        Self::mail_template(
            ctx,
            &welcome,
            mailer::Args {
                to: account.phone.to_string(),
                locals: json!({
                  "phone": account.phone,
                  "verifyToken": account.phone_verification_token,
                  "domain": ctx.config.server.full_url()
                }),
                ..Default::default()
            },
        )
        .await?;

        Ok(())
    }

    /// Sending forgot password phone
    ///
    /// # Errors
    ///
    /// When phone sending is failed
    pub async fn forgot_password(ctx: &AppContext, user: &accounts::Model) -> Result<()> {
        Self::mail_template(
            ctx,
            &forgot,
            mailer::Args {
                to: user.phone.to_string(),
                locals: json!({
                  "phone": user.phone,
                  "resetToken": user.reset_token,
                  "domain": ctx.config.server.full_url()
                }),
                ..Default::default()
            },
        )
        .await?;

        Ok(())
    }
}
