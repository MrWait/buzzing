use loco_rs::prelude::*;

use crate::models::installation::InstallationModel;
use crate::models::market_info::MarketInfoModel;
use crate::models::review::ReviewModel;
use crate::models::version::VersionModel;

/// Update rating average and count for an app
pub async fn update_rating_avg(
    db: &DatabaseConnection,
    app_id: i64,
) -> ModelResult<()> {
    let summary = ReviewModel::get_rating_summary(db, app_id).await?;
    let avg = summary["average"].as_f64().unwrap_or(0.0);
    let count = summary["total"].as_i64().unwrap_or(0) as i32;

    if let Some(info) = MarketInfoModel::find_by_app(db, app_id).await? {
        let mut active: base::models::_entities::open_app_market_info::ActiveModel = info.0.into();
        active.rating_avg = ActiveValue::set(avg);
        active.rating_count = ActiveValue::set(count);
        active.update(db).await?;
    }

    Ok(())
}

/// Process installation: create installation record, setup bot
pub async fn process_installation(
    db: &DatabaseConnection,
    app_id: i64,
    tenant_id: i64,
    installer_id: i64,
    scopes: Vec<String>,
) -> ModelResult<InstallationModel> {
    let inst = InstallationModel::create(db, app_id, tenant_id, installer_id, scopes).await?;

    // Increment install count in market info
    let _ = MarketInfoModel::increment_install_count(db, app_id).await;

    Ok(inst)
}

/// Process uninstallation
pub async fn process_uninstallation(
    db: &DatabaseConnection,
    installation_id: i64,
) -> ModelResult<bool> {
    InstallationModel::set_status(db, installation_id, 2i16).await
}
