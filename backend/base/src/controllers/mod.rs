use axum::debug_handler;
use loco_rs::prelude::*;
use tracing::debug;

#[debug_handler]
async fn test(State(_ctx): State<AppContext>) -> Result<Response> {
    debug!("test api");
    format::json(())
}

pub fn routes() -> Routes {
    Routes::new().prefix("/api/test").add("/", get(test))
}
