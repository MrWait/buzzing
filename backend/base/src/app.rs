use async_trait::async_trait;
use loco_rs::{
    app::{AppContext, Hooks, Initializer},
    bgworker::{BackgroundWorker, Queue},
    boot::{create_app, shutdown_signal, BootResult, ServeParams, StartMode},
    config::Config,
    controller::AppRoutes,
    db::{self, truncate_table},
    environment::Environment,
    task::Tasks,
    Result,
};
use migration::Migrator;
use tokio::signal;
use std::{net::SocketAddr, time::Duration};
use std::path::Path;

use crate::workers::downloader::DownloadWorker;
use crate::{controllers, initializers, models::_entities::users, tasks};
use common::AppHub;

pub struct App;
#[async_trait]
impl Hooks for App {
    fn app_name() -> &'static str {
        env!("CARGO_CRATE_NAME")
    }

    fn app_version() -> String {
        format!(
            "{} ({})",
            env!("CARGO_PKG_VERSION"),
            option_env!("BUILD_SHA")
                .or(option_env!("GITHUB_SHA"))
                .unwrap_or("dev")
        )
    }

    async fn boot(
        mode: StartMode,
        environment: &Environment,
        config: Config,
    ) -> Result<BootResult> {
        create_app::<Self, Migrator>(mode, environment, config).await
    }

    async fn initializers(_ctx: &AppContext) -> Result<Vec<Box<dyn Initializer>>> {
        let mut initializers = Vec::new();

        if let Ok(hub) = AppHub::get() {
            let apps = hub.get_all();
            for app in apps.iter() {
                initializers.extend(app.initializers(_ctx));
            }
        }
        initializers.push(Box::new(initializers::view_engine::ViewEngineInitializer));

        Ok(initializers)
    }

    fn routes(_ctx: &AppContext) -> AppRoutes {
        let mut app_route = AppRoutes::with_default_routes(); // controller routes below
        app_route = app_route.add_route(controllers::routes());
        if let Ok(hub) = AppHub::get() {
            let apps = hub.get_all();
            for app in apps.iter() {
                app_route = app_route.add_routes(app.routes(_ctx));
            }
        }
        app_route
    }

    async fn connect_workers(ctx: &AppContext, queue: &Queue) -> Result<()> {
        queue.register(DownloadWorker::build(ctx)).await?;
        Ok(())
    }

    fn register_tasks(tasks: &mut Tasks) {
        tasks.register(tasks::seed::SeedData);
    }

    /*
        fn register_channels(_ctx: &AppContext) -> AppChannels {
            let messages = channels::state::MessageStore {
                messages: Arc::new(RwLock::new(HashMap::new())),
                ctx: _ctx.clone().into(),
            };
            let channels: AppChannels = AppChannels::builder().with_state(messages).into();
            channels.register.ns("/", channels::application::on_connect);
            channels
                .register
                .ns("/conn", channels::connection::on_connect);
            channels
    }
         */

    async fn truncate(ctx: &AppContext) -> Result<()> {
        truncate_table(&ctx.db, users::Entity).await?;
        Ok(())
    }

    async fn seed(ctx: &AppContext, base: &Path) -> Result<()> {
        db::seed::<users::ActiveModel>(&ctx.db, &base.join("users.yaml").display().to_string())
            .await?;
        Ok(())
    }

    async fn serve(
        mut app: axum::Router,
        ctx: &AppContext,
        _server_params: &ServeParams,
    ) -> Result<()> {
        if let Ok(hub) = AppHub::get() {
            let apps = hub.get_all();
            for ext_app in apps.iter() {
                ext_app.serve(ctx);
            }
        }

        // Root SPA catch-all (must be after all API routes)
        app = app
            .route("/", axum::routing::get(crate::embed::spa_index_handler))
            .route("/{*path}", axum::routing::get(crate::embed::spa_handler));

        let handle = axum_server::Handle::new();
        let handle_clone = handle.clone();

        let addr = SocketAddr::from(([0, 0, 0, 0], ctx.config.server.port as u16));
        tracing::info!("listen on addr: {:?}", addr);
        // let listener = tokio::net::TcpListener::bind(&addr).await?;

        let settings = ctx
            .config
            .settings
            .as_ref()
            .and_then(|v| serde_json::from_value::<common::Settings>(v.clone()).ok())
            .expect("config settings not found");

        let cert_path = settings.cert.as_deref().expect("config settings.cert not found");
        let key_path = settings.cert_key.as_deref().expect("config settings.cert_key not found");

        let config = axum_server::tls_rustls::RustlsConfig::from_pem_file(
            cert_path,
            key_path,
        )
        .await?;

        axum_server::bind_rustls(addr, config)
            .handle(handle)
            .serve(app.into_make_service_with_connect_info::<SocketAddr>())
            .await?;

        tokio::spawn(async move {
            let _ = shutdown_task(handle_clone).await;
        });

        Ok(())
    }
}

async fn shutdown_task(handle: axum_server::Handle) {
    let ctrl_c = async {
        let _ = signal::ctrl_c().await;
    };

    #[cfg(unix)]
    let terminate = async {

    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {}
        _ = terminate => {},
    }

    handle.graceful_shutdown(Some(Duration::from_secs(10)));
}
