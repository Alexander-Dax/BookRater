# Theme Customization

The Book Rater app provides a comprehensive theme customization system allowing users to personalize the app's color scheme according to their preferences.

## Overview

Users can choose from 8 carefully curated color schemes, each designed to provide optimal readability and visual appeal in both light and dark modes. The selected theme is automatically persisted and applied across the entire application.

## Available Color Schemes

The app includes the following pre-defined themes:

1. **Deep Purple** (`#6750A4`)
   - Default theme
   - Professional and elegant
   - Material Design 3 recommended color

2. **Ocean Blue** (`#0077BE`)
   - Calm and professional
   - Ideal for extended reading sessions

3. **Forest Green** (`#2E7D32`)
   - Nature-inspired
   - Easy on the eyes

4. **Sunset Orange** (`#E65100`)
   - Warm and energetic
   - High contrast for accessibility

5. **Crimson Red** (`#C62828`)
   - Bold and passionate
   - Perfect for book enthusiasts

6. **Royal Indigo** (`#283593`)
   - Classic and sophisticated
   - Traditional literary feel

7. **Teak Brown** (`#5D4037`)
   - Book-inspired
   - Reminiscent of old libraries

8. **Slate Gray** (`#455A64`)
   - Neutral and modern
   - Minimalist aesthetic

## User Interface

### Accessing Theme Selection

Users can access the theme selection screen via:
- **Home Screen**: Tap the palette icon (🎨) in the app bar
- **Location**: Top-right corner of the main screen

### Theme Selection Screen

The theme selection screen displays:
- **Grid Layout**: 2-column grid of theme cards
- **Visual Preview**: Each theme shows a colored circle with its primary color
- **Theme Name**: Descriptive name below each preview
- **Selection Indicator**:
  - Selected theme has a colored border matching the theme
  - Checkmark icon inside the color circle
  - Elevated card with increased shadow

### Changing Themes

1. Navigate to the theme selection screen
2. Tap on any theme card
3. The app immediately applies the new theme
4. Selection is automatically saved
5. Navigate back to see the new theme in action

## Technical Implementation

### Architecture

The theme system uses a service-based architecture with the following components:

#### ThemeService

**Location**: `lib/services/theme_service.dart`

**Responsibilities**:
- Manages theme state using `ChangeNotifier`
- Provides singleton access pattern
- Handles theme persistence via `SharedPreferences`
- Generates `ThemeData` objects for light and dark modes

**Key Methods**:
```dart
// Initialize service and load saved preferences
Future<void> init()

// Change the active theme
Future<void> setTheme(String themeId)

// Get current theme configuration
AppTheme get currentTheme

// Generate Material 3 ThemeData
ThemeData getLightTheme()
ThemeData getDarkTheme()
```

**Theme Storage**:
- Uses `SharedPreferences` for persistence
- Storage key: `selected_theme`
- Default theme: `deepPurple`

#### AppTheme Model

Represents a single theme configuration:

```dart
class AppTheme {
  final String id;          // Unique identifier
  final String name;        // Display name
  final Color seedColor;    // Primary color for Material 3
}
```

#### ThemeSelectionScreen

**Location**: `lib/screens/theme_selection_screen.dart`

**Features**:
- Grid-based theme picker
- Real-time theme preview
- Responsive layout (2 columns)
- Visual feedback for selection

**Components**:
- `ThemeSelectionScreen`: Main screen widget
- `_ThemeCard`: Individual theme option card

### Integration with Main App

**Location**: `lib/main.dart`

The main app initializes and listens to the theme service:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();  // Load saved theme
  runApp(const BookRaterApp());
}

class _BookRaterAppState extends State<BookRaterApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeService.getLightTheme(),
      darkTheme: _themeService.getDarkTheme(),
      // ...
    );
  }
}
```

### Material 3 Color System

All themes use Material 3's `ColorScheme.fromSeed()` method, which:
- Generates a complete color palette from the seed color
- Creates harmonious color combinations
- Ensures accessibility standards (WCAG contrast ratios)
- Provides automatic light and dark mode variants

**Generated Colors Include**:
- Primary, secondary, tertiary colors
- Surface and background colors
- Error colors
- Container variants
- On-color variants (for text on colored backgrounds)

## Persistence

### Storage Mechanism

**Technology**: `shared_preferences` package

**Data Stored**:
- Key: `selected_theme`
- Value: Theme ID (e.g., `"deepPurple"`, `"oceanBlue"`)
- Type: String

**Persistence Flow**:
1. User selects theme
2. `ThemeService.setTheme()` called
3. Theme ID saved to `SharedPreferences`
4. `notifyListeners()` triggers UI rebuild
5. New theme applied immediately

**Loading on App Start**:
1. `main()` calls `ThemeService().init()`
2. Service loads theme ID from storage
3. Defaults to `"deepPurple"` if no saved preference
4. UI renders with saved theme

## Dependencies

```yaml
dependencies:
  shared_preferences: ^2.2.2  # Theme persistence
  flutter:
    sdk: flutter               # Material 3 theming
```

## Usage Examples

### For Users

**Scenario 1: First-time setup**
1. App launches with default Deep Purple theme
2. User taps palette icon
3. Selects "Forest Green"
4. App immediately changes to green theme
5. Theme persists across app restarts

**Scenario 2: Switching between themes**
1. User wants a change from current theme
2. Opens theme selection
3. Previews different options by tapping
4. Each tap immediately applies the theme
5. Can switch back and forth freely

### For Developers

**Adding a new theme**:

```dart
// In ThemeService.themes map
'customTheme': AppTheme(
  id: 'customTheme',
  name: 'Custom Theme Name',
  seedColor: const Color(0xFFHEXCODE),
)
```

**Accessing current theme**:

```dart
final themeService = ThemeService();
final currentTheme = themeService.currentTheme;
print(currentTheme.name); // "Deep Purple"
```

**Programmatically changing theme**:

```dart
await ThemeService().setTheme('oceanBlue');
```

## Accessibility

### Visual Considerations

- **High Contrast**: All themes meet WCAG AA standards
- **Color Blindness**: Material 3 ensures distinguishable UI elements
- **Dark Mode**: All themes provide dark variants for low-light environments

### Touch Targets

- Theme cards are large (grid aspect ratio 1.2)
- 16px spacing between cards
- Clear visual feedback on selection

## Best Practices

### For Users

1. **Choose based on lighting**:
   - Bright environments: Use lighter themes (Ocean Blue, Forest Green)
   - Low light: Enable dark mode with any theme

2. **Reading sessions**:
   - Long sessions: Cooler tones (Blue, Green, Purple)
   - Quick access: Warmer tones (Orange, Red)

3. **Personal preference**:
   - Experiment with different themes
   - Changes are instant and reversible

### For Developers

1. **Never hardcode colors**: Always use `Theme.of(context).colorScheme`
2. **Test all themes**: Ensure UI works with all 8 color schemes
3. **Respect Material 3**: Use semantic colors (primary, secondary, etc.)
4. **Dark mode support**: Use `Theme.of(context).brightness` for conditional styling

## Testing

### Manual Testing Checklist

- [ ] All 8 themes can be selected
- [ ] Theme persists after app restart
- [ ] Light and dark modes work with all themes
- [ ] UI elements are readable in all themes
- [ ] Theme changes apply immediately
- [ ] No visual glitches during theme switch

### Test Scenarios

1. **Fresh install**: Default theme loads
2. **Theme switching**: All themes apply correctly
3. **Persistence**: Selected theme survives app restart
4. **Dark mode toggle**: Works with all themes
5. **Navigation**: Theme persists across screens

## Future Enhancements

Potential improvements to the theme system:

1. **Custom colors**: Allow users to create custom themes with color pickers
2. **Theme previews**: Show full app preview before applying
3. **Import/Export**: Share themes between devices
4. **Scheduled themes**: Auto-switch based on time of day
5. **Per-screen themes**: Different themes for different sections
6. **Gradient support**: More complex color schemes
7. **Animation**: Smooth color transitions when switching themes

## Troubleshooting

### Theme doesn't persist

**Problem**: Selected theme resets to default after restarting app

**Solutions**:
- Check `SharedPreferences` permissions
- Verify `ThemeService().init()` is called in `main()`
- Clear app data and try again

### Colors look wrong

**Problem**: Theme colors don't match preview

**Solutions**:
- Restart app to apply changes
- Check for custom color overrides in specific widgets
- Verify Material 3 is enabled (`useMaterial3: true`)

### Theme button not visible

**Problem**: Palette icon missing from home screen

**Solutions**:
- Update to latest version
- Check screen width (icon may be in overflow menu on small screens)
- Verify `ThemeSelectionScreen` import in `home_screen.dart`

## Version History

- **v1.2.0** (2026-07-17): Initial theme customization release
  - 8 pre-defined color schemes
  - Persistent theme selection
  - Material 3 integration
  - Light and dark mode support
