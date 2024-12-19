use crate::prelude::{params, Connection, Error, Result};

pub struct MetaTable<'a> {
    table: &'a str,
    conn: &'a Connection,
}

const META: &str = "meta";

impl<'a> MetaTable<'a> {
    pub fn new(table: &'a str, conn: &'a Connection) -> Self {
        MetaTable { table, conn }
    }

    pub fn meta(conn: &'a Connection) -> Self {
        MetaTable { table: META, conn }
    }

    pub fn init_table(&self) -> Result<()> {
        self.conn.execute(
            &format!(
                "CREATE TABLE IF NOT EXISTS {} (
key TEXT PRIMARY KEY,
value TEXT
)",
                self.table
            ),
            (),
        )?;
        Ok(())
    }

    pub fn insert(&self, key: &str, value: &str) -> Result<()> {
        let query = format!("REPLACE INTO {} (key, value) VALUES (?1, ?2)", self.table);
        let mut stmt = self.conn.prepare(&query)?;
        stmt.execute(params![key, value])?;
        Ok(())
    }

    pub fn get(&self, key: &str) -> Result<String> {
        let query = format!("SELECT value from {} where key=?1", self.table);
        let mut stmt = self.conn.prepare(&query)?;
        let mut rows = stmt.query(params![key])?;
        while let Some(row) = rows.next()? {
            return row.get(0);
        }
        Err(Error::QueryReturnedNoRows)
    }

    pub fn get_with<F, T>(&self, key: &str, f: F) -> Option<T>
    where
        F: FnOnce(String) -> anyhow::Result<T>,
    {
        if let Ok(str) = self.get(key) {
            if let Ok(t) = f(str) {
                return Some(t);
            }
        }
        None
    }

    pub fn delete(&self, key: &str) -> Result<()> {
        let query = format!("DELETE FROM {} where key = ?1", self.table);
        let mut stmt = self.conn.prepare(&query)?;
        stmt.execute(params![key])?;
        Ok(())
    }

    pub fn search(&self, key: &str) -> Result<Vec<(String, String)>> {
        let mut records = Vec::new();
        let query = format!("SELECT key, value FROM {} WHERE key like ?1", self.table);
        let mut stmt = self.conn.prepare(&query)?;
        stmt.query(params![key]).and_then(|mut rows| {
            while let Some(row) = rows.next()? {
                records.push((row.get(0)?, row.get(1)?));
            }
            Ok(())
        })?;
        Ok(records)
    }

    pub fn get_all(&self) -> Result<Vec<(String, String)>> {
        let mut records = Vec::new();
        let query = format!("SELECT key, value FROM {}", self.table);
        let mut stmt = self.conn.prepare(&query)?;
        stmt.query([]).and_then(|mut rows| {
            while let Some(row) = rows.next()? {
                records.push((row.get(0)?, row.get(1)?));
            }
            Ok(())
        })?;
        Ok(records)
    }
}
