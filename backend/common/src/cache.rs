use loco_rs::{Error, Result, app::AppContext};
use moka::future::Cache;
use std::collections::HashMap;
use std::hash::Hash;
use std::sync::Arc;

#[async_trait::async_trait]
pub trait CacheLoader<K, T> {
    async fn load(&self, ctx: &AppContext, ids: &[K]) -> Result<HashMap<K, T>>;
    async fn get(&self, ctx: &AppContext, id: &K) -> Result<T>;
}

pub struct CommonCache<K, T>
where
    K: Hash + Eq + PartialEq + Clone + Sync + Sync + 'static,
    T: Send + Sync + Clone + 'static,
{
    pub cache: Cache<K, T>,
    pub loader: Arc<Box<dyn CacheLoader<K, T> + Send + Sync>>,
}

impl<K, T> CommonCache<K, T>
where
    K: Hash + Eq + PartialEq + Clone + Send + Sync + 'static,
    T: Send + Sync + Clone + 'static,
{
    pub fn new(limit: u64, loader: Arc<Box<dyn CacheLoader<K, T> + Send + Sync>>) -> Self {
        Self {
            cache: Cache::new(limit),
            loader,
        }
    }
    pub async fn load(&self, ctx: &AppContext, ids: &[K]) -> Result<HashMap<K, T>> {
        let mut missing = Vec::new();
        let mut caches = HashMap::new();

        for id in ids.iter() {
            if let Some(entry) = self.cache.get(id).await {
                caches.insert(id.clone(), entry);
            } else {
                missing.push(id.clone());
            }
        }

        if !missing.is_empty() {
            let mut entries = self.loader.load(ctx, missing.as_slice()).await?;
            for (id, entry) in entries.drain() {
                let e = self.cache.get_with(id.clone(), async move { entry }).await;
                caches.insert(id, e);
            }
        }
        Ok(caches)
    }

    pub async fn get(&self, ctx: &AppContext, id: &K) -> Result<T> {
        self.cache
            .try_get_with(id.clone(), async move { self.loader.get(ctx, id).await })
            .await
            .map_err(|_err: Arc<Error>| Error::NotFound)
    }

    pub async fn insert(&self, id: K, val: T) -> Result<()> {
        self.cache.insert(id, val).await;
        Ok(())
    }

    pub async fn remove(&self, id: &K) -> Result<()> {
        self.cache.remove(id).await;
        Ok(())
    }
}
