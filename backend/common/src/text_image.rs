use ab_glyph::{FontRef, PxScale};
use anyhow::Result;
use image::{Rgb, RgbImage};
use imageproc::drawing::{draw_text_mut, text_size};
use std::path::Path;

use std::sync::LazyLock;

static FONT_CACHE: LazyLock<Option<FontRef>> =
    LazyLock::new(|| FontRef::try_from_slice(include_bytes!("../msyh.ttc")).ok());

pub fn text_to_image(content: &str, dest: &Path) -> Result<()> {
    let width = 128;
    let height = 128;

    let content: String = content.chars().take(2).collect();
    let font = FONT_CACHE
        .as_ref()
        .ok_or(anyhow::anyhow!("font not load"))?;

    let mut image = RgbImage::new(width, height);
    let color = crate::PresetColor::rand().into();
    for x in 0..width {
        for y in 0..height {
            *image.get_pixel_mut(x, y) = color;
        }
    }

    let inteded_text_height = 40.0;
    let scale = PxScale {
        x: inteded_text_height * 2.0,
        y: inteded_text_height * 2.0,
    };

    let red = 255 as u8;
    let green = 255;
    let blue = 255;

    let (text_width, text_height) = text_size(scale, &font, &content);
    // debug!("text size: {}x{}", text_width, text_height);
    let text_start_x = ((width - text_width as u32) / 2) as i32;
    let text_start_y = ((height - text_height as u32) / 2) as i32;

    draw_text_mut(
        &mut image,
        Rgb([red, green, blue]),
        text_start_x,
        text_start_y,
        scale,
        &font,
        &content,
    );
    image.save(dest)?;
    Ok(())
}

pub fn extra_name(content: &str, len: usize) -> String {
    content.chars().rev().take(len).collect::<Vec<_>>().into_iter().rev().collect()
}

pub fn extra(content: &str, len: usize) -> String {
    content.chars().take(len).collect()
}
