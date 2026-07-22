use axum::extract::State;
use axum::Json;
use loco_rs::prelude::*;
use sea_orm::EntityTrait;
use serde::Deserialize;
use serde_json::{json, Value};

use crate::error::OpenAppError;
use crate::middleware::AppBrief;
use crate::services::auth;

#[derive(Deserialize)]
pub struct TenantAccessTokenReq {
    pub app_id: String,
    pub app_secret: String,
}

pub async fn tenant_access_token(
    State(ctx): State<AppContext>,
    Json(req): Json<TenantAccessTokenReq>,
) -> Result<Json<Value>> {
    let db = &ctx.db;

    let app = base::models::_entities::open_apps::Entity::find()
        .filter(
            sea_orm::Condition::all()
                .add(base::models::_entities::open_apps::Column::AppId.eq(&req.app_id))
                .add(base::models::_entities::open_apps::Column::Status.eq(1))
                .add(base::models::_entities::open_apps::Column::DeletedAt.is_null()),
        )
        .one(db)
        .await
        .map_err(|e| {
            tracing::error!("db error querying app: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::Unauthorized("app not found or disabled".into()))?;

    if !auth::verify_secret(&req.app_secret, &app.app_secret) {
        return Err(loco_rs::Error::Unauthorized("invalid app_secret".into()));
    }

    let brief = AppBrief {
        app_id: app.app_id.clone(),
        app_db_id: app.id,
        tenant_id: app.tenant_id,
        scopes: app.scopes.clone(),
    };

    let token = auth::generate_tenant_token(&ctx, &brief)
        .map_err(|e: OpenAppError| loco_rs::Error::InternalServerError)?;

    let jwt_config = ctx
        .config
        .get_jwt_config()
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    Ok(Json(json!({
        "code": 0,
        "message": "ok",
        "data": {
            "token": token,
            "expire": jwt_config.expiration,
        }
    })))
}
