# App Icon Instructions

## Required Files

To generate the app icon, you need to create two PNG images:

### 1. `app_icon.png` (512x512px)
- **Size**: 512x512 pixels
- **Format**: PNG with transparency
- **Purpose**: Main app icon for all platforms

### 2. `app_icon_foreground.png` (432x432px)
- **Size**: 432x432 pixels
- **Format**: PNG with transparency
- **Purpose**: Foreground layer for Android adaptive icons
- **Note**: Should have transparent background, icon in center

## Design Recommendations

### Concept 1: Book with Stars (Recommended)
- Purple/deep purple open book silhouette
- 5 golden stars above or around it
- Simple, recognizable design
- Matches app theme color (#6750A4)

### Concept 2: Tier List Visual
- S/A/B letters in gradient
- Book silhouettes in background
- More complex but unique

### Concept 3: Simple Book Stack
- 3-4 stacked books
- Minimalist, clean
- Professional look

## Design Tools

You can create the icon using:
- **Figma** (free, online)
- **Canva** (free, easy templates)
- **GIMP** (free, desktop)
- **Adobe Illustrator** (paid, professional)
- **Icon generators** online

## Generating Icons

Once you have the PNG files:

1. Place `app_icon.png` and `app_icon_foreground.png` in this directory (`assets/icon/`)

2. Run the icon generator:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. The generator will create all necessary icon sizes automatically for Android

4. Rebuild the app:
   ```bash
   flutter build apk --release
   ```

## Color Scheme

Use these colors from the app theme:

- **Primary**: #6750A4 (Deep Purple)
- **Accent**: #FFD700 (Gold for stars)
- **Background**: White or transparent
- **Text/Shapes**: Dark gray (#424242) or black

## Icon Checklist

- [ ] Created `app_icon.png` (512x512px)
- [ ] Created `app_icon_foreground.png` (432x432px)
- [ ] Icons are recognizable at small sizes (48x48px)
- [ ] Icons work on both light and dark backgrounds
- [ ] Ran `flutter pub run flutter_launcher_icons`
- [ ] Tested APK on device

## Current Status

**Status**: ⚠️ Icons not yet created

**Next Steps**:
1. Design or commission app icon
2. Create PNG files with correct dimensions
3. Place in this directory
4. Run icon generator
5. Test on device

## Example Icon Services

If you want professionally designed icons:
- **Fiverr** - $5-50
- **99designs** - Contest-based
- **Flaticon** - Free/Premium templates
- **The Noun Project** - Icon components

## Quick Template

For a quick start, you can:
1. Use a book emoji 📚 as base
2. Add stars ⭐⭐⭐⭐⭐
3. Export as PNG at required sizes
4. Use online tools like "favicon.io" to resize

---

**Note**: The icon is currently using Flutter's default icon. Replace with custom design for production release.
