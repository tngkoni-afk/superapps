import os
from PIL import Image

def generate_icons(source_image_path):
    if not os.path.exists(source_image_path):
        print(f"Error: Source image {source_image_path} not found.")
        return

    try:
        img = Image.open(source_image_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    # Android configurations
    android_res_path = 'android/app/src/main/res/'
    android_icons = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    print("Generating Android icons...")
    for folder, size in android_icons.items():
        folder_path = os.path.join(android_res_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        resized_img.save(icon_path, 'PNG')
        print(f"Created {icon_path} ({size}x{size})")

    # iOS configurations
    ios_res_path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
    ios_icons = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024,
    }

    print("Generating iOS icons...")
    for filename, size in ios_icons.items():
        os.makedirs(ios_res_path, exist_ok=True)
        icon_path = os.path.join(ios_res_path, filename)
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        resized_img.save(icon_path, 'PNG')
        print(f"Created {icon_path} ({size}x{size})")

    print("Successfully generated all icons!")

if __name__ == "__main__":
    generate_icons("assets/koni_logo.png")
