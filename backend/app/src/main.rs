#![feature(lazy_get)]
use loco_rs::cli;
use migration::Migrator;
use mimalloc::MiMalloc;
use std::sync::Arc;

use base::app::App;
use calendar::AppCalendar;
use common::{AppHub, BizCalendar, BizGateway, BizHub, BizOffice, BizSetting, BizStore, BizUser, ExternApp};
use gateway::AppGateway;
use im::AppIm;
use office::AppOffice;
use rtc::AppRtc;
use setting::AppSetting;
use store::AppStore;
use todo::AppTodo;
use user::AppUser;

#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

#[tokio::main]
async fn main() -> loco_rs::Result<()> {
    let calendar = Box::new(AppCalendar);
    let gateway = Box::new(AppGateway);
    let im = Box::new(AppIm);
    let office = Box::new(AppOffice);
    let rtc = Box::new(AppRtc);
    let store = Box::new(AppStore);
    let setting = Box::new(AppSetting::default());
    let todo = Box::new(AppTodo);
    let user = Box::new(AppUser);

    let hub = AppHub {
        calendar: Arc::new(calendar.clone() as Box<dyn ExternApp + Send + Sync>),
        gateway: Arc::new(gateway.clone() as Box<dyn ExternApp + Send + Sync>),
        im: Arc::new(im.clone() as Box<dyn ExternApp + Send + Sync>),
        office: Arc::new(office.clone() as Box<dyn ExternApp + Send + Sync>),
        rtc: Arc::new(rtc.clone() as Box<dyn ExternApp + Send + Sync>),
        store: Arc::new(store.clone() as Box<dyn ExternApp + Send + Sync>),
        setting: Arc::new(setting.clone() as Box<dyn ExternApp + Send + Sync>),
        todo: Arc::new(todo.clone() as Box<dyn ExternApp + Send + Sync>),
        user: Arc::new(user.clone() as Box<dyn ExternApp + Send + Sync>),

        gateway_handlers: Arc::new(dashmap::DashMap::new()),
    };

    let services = BizHub {
        store_impl: Arc::new(store as Box<dyn BizStore + Send + Sync>),
        gateway: Arc::new(gateway as Box<dyn BizGateway + Send + Sync>),
        setting: Arc::new(setting as Box<dyn BizSetting + Send + Sync>),
        calendar: Arc::new(calendar as Box<dyn BizCalendar + Send + Sync>),
        office: Arc::new(office as Box<dyn BizOffice + Send + Sync>),
        user: Arc::new(user as Box<dyn BizUser + Send + Sync>),
    };

    AppHub::set(Arc::new(hub));
    BizHub::set(Arc::new(services));

    cli::main::<App, Migrator>().await
}
