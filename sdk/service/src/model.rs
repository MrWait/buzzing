#[derive(Debug, Default, Clone)]
pub struct Setting {
    pub key: String,
    pub value: String,
    pub version: i64,
    pub dirty: bool,
}
