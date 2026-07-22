#![allow(dead_code)]
use anyhow::Result;
use std::any::{Any, TypeId};
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use parking_lot::{MappedMutexGuard, Mutex, MutexGuard, RwLock};

static SERVICE: LazyLock<RwLock<HashMap<TypeId, Arc<Box<dyn Any + Send + Sync>>>>> =
    LazyLock::new(|| RwLock::new(HashMap::new()));

pub fn reg_service<T>(svc: T)
where
    T: Any + Send + Sync + Clone + 'static,
{
    let mut s = SERVICE.write();
    let _ = s.insert(TypeId::of::<T>(), Arc::new(Box::new(svc)));
}

pub fn get_service<T>() -> Result<Arc<Box<T>>>
where
    T: Any + Send + Sync + Clone + 'static,
{
    let s = SERVICE.read();
    let value_any = s
        .get(&TypeId::of::<T>())
        .cloned()
        .ok_or(anyhow::anyhow!("Type not reg"))?;
    value_any
        .downcast_ref::<T>()
        .map(|t| Arc::new(Box::new(t.clone())))
        .ok_or(anyhow::anyhow!("Type mismatch"))
}

pub fn del_service<T: Send + Sync + 'static>() -> Result<()> {
    let mut s = SERVICE.write();
    s.remove(&TypeId::of::<T>());
    Ok(())
}
