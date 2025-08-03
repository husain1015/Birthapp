#!/usr/bin/env python3
"""
App Icon Generator for ReadyBirth Prep
Creates all required icon sizes from a 1024x1024 source image
"""

import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_placeholder_icon(size=1024):
    """Create a placeholder app icon if no source image exists"""
    # Create a new image with a gradient background
    img = Image.new('RGB', (size, size), color='#FF69B4')  # Pink background
    draw = ImageDraw.Draw(img)
    
    # Draw a simple baby footprint or pregnant woman silhouette
    # For now, just a simple circle with text
    margin = size // 10
    draw.ellipse([margin, margin, size-margin, size-margin], fill='white', outline='white')
    
    # Add text
    try:
        # Try to use a nice font, fallback to default if not available
        font_size = size // 4
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = None
    
    text = "RB"
    if font:
        # Get text bounding box
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        position = ((size - text_width) // 2, (size - text_height) // 2)
        draw.text(position, text, fill='#FF69B4', font=font)
    else:
        # Fallback to default font
        draw.text((size//2, size//2), text, fill='#FF69B4', anchor="mm")
    
    return img

def generate_icons(source_path=None):
    """Generate all required icon sizes"""
    
    # Icon sizes needed for iOS
    sizes = [
        (20, "Icon-20"),      # Notification 
        (29, "Icon-29"),      # Settings
        (40, "Icon-40"),      # Spotlight
        (58, "Icon-58"),      # Settings @2x
        (60, "Icon-60"),      # Notification @3x
        (76, "Icon-76"),      # iPad
        (80, "Icon-80"),      # Spotlight @2x
        (87, "Icon-87"),      # Settings @3x
        (120, "Icon-120"),    # iPhone @2x
        (152, "Icon-152"),    # iPad @2x
        (167, "Icon-167"),    # iPad Pro
        (180, "Icon-180"),    # iPhone @3x
        (1024, "Icon-1024"),  # App Store
    ]
    
    # Create output directory
    output_dir = "AppIcons"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Load or create source image
    if source_path and os.path.exists(source_path):
        source_img = Image.open(source_path)
        # Ensure it's 1024x1024
        if source_img.size != (1024, 1024):
            source_img = source_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    else:
        print("No source image found. Creating placeholder icon...")
        source_img = create_placeholder_icon(1024)
        # Save the placeholder as source
        source_img.save(os.path.join(output_dir, "Icon-1024.png"))
    
    # Generate all sizes
    for size, name in sizes:
        if size == 1024 and not source_path:
            continue  # Already saved
            
        resized = source_img.resize((size, size), Image.Resampling.LANCZOS)
        output_path = os.path.join(output_dir, f"{name}.png")
        resized.save(output_path, "PNG")
        print(f"Created {name}.png ({size}x{size})")
    
    # Create Contents.json for Xcode
    contents = {
        "images": [
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-40.png", "scale": "2x"},
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-60.png", "scale": "3x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-58.png", "scale": "2x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-87.png", "scale": "3x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-80.png", "scale": "2x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-120.png", "scale": "3x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-120.png", "scale": "2x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-180.png", "scale": "3x"},
            {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-1024.png", "scale": "1x"}
        ],
        "info": {"version": 1, "author": "xcode"}
    }
    
    import json
    with open(os.path.join(output_dir, "Contents.json"), 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"\nIcons generated in '{output_dir}' directory")
    print("To use in Xcode:")
    print("1. Open Assets.xcassets")
    print("2. Right-click and choose 'Import...'")
    print("3. Select the AppIcons folder")

if __name__ == "__main__":
    source_image = sys.argv[1] if len(sys.argv) > 1 else None
    
    try:
        generate_icons(source_image)
    except ImportError:
        print("Error: Pillow library not installed")
        print("Install with: pip3 install Pillow")
    except Exception as e:
        print(f"Error: {e}")