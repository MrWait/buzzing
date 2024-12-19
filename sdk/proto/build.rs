use prost_build_config::{BuildConfig, Builder};
use shadow_rs::ShadowBuilder;
use std::io::Result;

fn main() -> Result<()> {
    let config: BuildConfig = serde_yaml::from_str(include_str!("./proto.yaml")).unwrap();
    Builder::from(config).build_protos();
    ShadowBuilder::builder().build().unwrap();

    Ok(())
}
