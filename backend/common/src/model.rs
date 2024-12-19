use loco_rs::prelude::Result;
use rand::Rng;
use serde::{Deserialize, Serialize};
use strum::{EnumCount, FromRepr, IntoStaticStr};

#[derive(Debug, Default, Deserialize, Serialize)]
pub struct UserBrief {
    pub id: i64,
    pub pid: String,
    pub aid: i64,
    pub tenant_id: i64,
}
impl UserBrief {
    pub fn to_string(&self) -> String {
        serde_json::to_string(&self).unwrap_or("{}".to_owned())
    }

    pub fn from_string(str: &str) -> Result<Self> {
        let claim = serde_json::from_str::<Self>(str)?;
        Ok(claim)
    }
}

#[allow(dead_code)]
#[derive(Debug, Clone, Copy, EnumCount, IntoStaticStr, FromRepr)]
pub enum PresetColor {
    RoyalBlue,     // 0x4169e1
    BlueViolet,    // 0x8a2be2
    LightSeaGreen, // 0x20b2aa
    LimeGreen,     // 0x32cd32
    YellowGreen,   // 0x9acd32
    GoldenRod,     // 0xdaa520
    Chocolate,     // 0xd2691e
    DeepPink,      // 0xff1493
}
impl Default for PresetColor {
    fn default() -> Self {
        Self::RoyalBlue
    }
}

impl PresetColor {
    pub fn rand() -> Self {
        let i: usize = rand::thread_rng().r#gen::<usize>();
        let i: usize = i % Self::COUNT;
        Self::from_repr(i).unwrap_or(Self::RoyalBlue)
    }
}

impl Into<image::Rgb<u8>> for PresetColor {
    fn into(self) -> image::Rgb<u8> {
        match self {
            PresetColor::RoyalBlue => image::Rgb([0x41, 0x69, 0xe1]),
            PresetColor::BlueViolet => image::Rgb([0x8a, 0x2b, 0xe2]),
            PresetColor::LightSeaGreen => image::Rgb([0x20, 0xb2, 0xaa]),
            PresetColor::LimeGreen => image::Rgb([0x32, 0xcd, 0x32]),
            PresetColor::YellowGreen => image::Rgb([0x9a, 0xcd, 0x32]),
            PresetColor::GoldenRod => image::Rgb([0xda, 0xa5, 0x20]),
            PresetColor::Chocolate => image::Rgb([0xd2, 0x69, 0x1e]),
            PresetColor::DeepPink => image::Rgb([0xff, 0x14, 0x93]),
            // _ => image::Rgb([0x41, 0x69, 0xe1]),
        }
    }
}

impl Into<i32> for PresetColor {
    fn into(self) -> i32 {
        match self {
            PresetColor::RoyalBlue => 0x4169e1,
            PresetColor::BlueViolet => 0x8a2be2,
            PresetColor::LightSeaGreen => 0x20b2aa,
            PresetColor::LimeGreen => 0x32cd32,
            PresetColor::YellowGreen => 0x9acd32,
            PresetColor::GoldenRod => 0xdaa520,
            PresetColor::Chocolate => 0xd2691e,
            PresetColor::DeepPink => 0xff1493,
            // _ => 0x4169e1,
        }
    }
}
