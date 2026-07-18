# Manga Series Support

## Overview

Version 1.5.0 introduces support for managing Manga series alongside books. Manga series are treated identically to books for rating and tier list purposes, with the main difference being the data source (MyAnimeList instead of ISBN lookup).

## Features

### Media Type System

The app now supports two types of media:
- **Books**: Traditional books with ISBN lookup
- **Manga**: Manga series with MyAnimeList integration

Both types:
- Use the same rating algorithm (PAVA)
- Appear in the same tier list
- Can be compared against each other
- Share the same database table

### MyAnimeList Integration

**API**: Jikan API v4 (unofficial MyAnimeList API)
- **Base URL**: `https://api.jikan.moe/v4`
- **Authentication**: None required
- **Rate Limit**: 1 request per second (enforced by app)

**Available Data**:
- Title (English and original)
- Author(s)
- Cover image (high quality)
- Synopsis
- Number of volumes
- MAL score (optional display)

## User Flows

### Adding a Manga Series

1. User taps the **+** (FAB) button
2. Dialog appears with two options:
   - **Buch** (Book with ISBN)
   - **Manga-Serie** (Manga with MAL search)
3. User selects "Manga-Serie"
4. **AddMangaScreen** opens
5. User searches for manga by name
6. Results appear from MyAnimeList
7. User selects desired manga
8. Fields auto-fill: Title, Author, Cover
9. User optionally adds: Year Read, Notes
10. User proceeds to rating (same as books)
11. Comparison screen for pairwise comparisons
12. Manga added to collection

### Searching MyAnimeList

**Search Interface**:
- Text input field for manga name
- Search button
- Real-time results display

**Search Results Display**:
- Cover thumbnail
- Title (English if available, else original)
- Author name
- Number of volumes (if known)
- MAL score badge

**Selection**:
- Tap any result to select
- Fields auto-populate
- Search results clear
- User can edit auto-filled data

### Editing Manga

Editing works the same as editing books:
- Tap manga in list
- Edit screen opens
- All fields editable
- Can re-search MAL if needed
- Rating can be adjusted

## Data Model

### MediaType Enum

```dart
enum MediaType {
  book,   // Traditional book
  manga;  // Manga series

  String toJson() => name;
  static MediaType fromJson(String json) => MediaType.values.byName(json);
}
```

### Book Model Extensions

```dart
class Book {
  // ... existing fields
  MediaType mediaType;  // NEW: Type of media
  String? malId;         // NEW: MyAnimeList ID (for manga)
}
```

### Database Schema

**Table**: `books` (shared by books and manga)

**New Columns**:
```sql
media_type TEXT NOT NULL DEFAULT 'book'
mal_id TEXT
```

**Migration**:
- Automatic on app start
- Version 2 → Version 3
- All existing entries get `media_type = 'book'`
- Zero data loss

## Technical Implementation

### MalService

**Location**: `lib/services/mal_service.dart`

**Responsibilities**:
- Search manga by query
- Get manga details by MAL ID
- Rate limiting
- Error handling

**Key Methods**:
```dart
// Search for manga
Future<List<MangaSearchResult>> searchManga(String query)

// Get detailed info
Future<Map<String, String?>> getMangaDetails(String malId)
```

**Rate Limiting**:
- Enforces 1 second delay between requests
- Prevents API throttling
- Transparent to user

### AddMangaScreen

**Location**: `lib/screens/add_manga_screen.dart`

**Features**:
- MAL search interface
- Results display with thumbnails
- Auto-fill from selected manga
- Manual entry fallback
- Cover preview
- Form validation

**Input Fields**:
- Title (required)
- Author (optional)
- Year Read (optional)
- Notes (optional)

**MAL-Specific**:
- Search box
- Results list
- MAL ID stored

### Media Type Selection Dialog

**Triggered By**: FAB button press

**Options**:
1. **Buch** (Book)
   - Icon: 📖 (book)
   - Subtitle: "Mit ISBN-Suche"
   - Action: Opens AddBookScreen

2. **Manga-Serie** (Manga)
   - Icon: 📚 (auto_stories)
   - Subtitle: "Mit MyAnimeList-Suche"
   - Action: Opens AddMangaScreen

## UI/UX Design

### Visual Indicators

Currently, books and manga look identical in the list. Future enhancements could include:
- Badge or icon showing media type
- Color-coded borders
- Filter to show only books or manga

### Navigation Changes

**Before v1.5.0**:
- FAB → AddBookScreen directly

**After v1.5.0**:
- FAB → Media Type Dialog → AddBookScreen OR AddMangaScreen

### App Bar Redesign

**Before v1.5.0**:
- 6 action buttons (cluttered)
- Language, Dark Mode, Tier List, Import/Export, Theme, Refresh

**After v1.5.0**:
- 2 action buttons (clean)
- **Tier List** (prominent, trophy icon, larger)
- **Menu** (hamburger, contains all secondary actions)

## API Integration Details

### Jikan API v4

**Documentation**: https://docs.api.jikan.moe/

**Endpoints Used**:

1. **Search Manga**:
   ```
   GET https://api.jikan.moe/v4/manga?q={query}&limit=10
   ```

2. **Get Manga Details**:
   ```
   GET https://api.jikan.moe/v4/manga/{mal_id}
   ```

**Response Format**:
```json
{
  "data": [
    {
      "mal_id": 13,
      "title": "One Piece",
      "title_english": "One Piece",
      "images": {
        "jpg": {
          "image_url": "https://...",
          "large_image_url": "https://..."
        }
      },
      "authors": [
        {"name": "Oda, Eiichiro"}
      ],
      "synopsis": "...",
      "volumes": 106,
      "score": 9.21
    }
  ]
}
```

### Error Handling

**Network Errors**:
- Graceful degradation
- Error messages to user
- Manual entry still possible

**API Errors**:
- Empty results → show "No results"
- Rate limit → auto-retry with delay
- Invalid response → log and skip

**Fallback**:
- User can always enter data manually
- API is convenience, not requirement

## Database Migration

### Migration Script

**Version**: 2 → 3

**SQL**:
```sql
ALTER TABLE books ADD COLUMN media_type TEXT NOT NULL DEFAULT 'book';
ALTER TABLE books ADD COLUMN mal_id TEXT;
```

**Execution**:
- Runs automatically on app start
- Only if database is version 2
- Safe and non-destructive

**Backward Compatibility**:
- Version 3 database works with old code (graceful degradation)
- Old entries have `media_type = 'book'`
- No null values in media_type

## Testing

### Manual Test Cases

1. **Add Manga**:
   - [ ] FAB → Select Manga → Search works
   - [ ] Results appear with correct data
   - [ ] Selection auto-fills fields
   - [ ] Can edit auto-filled data
   - [ ] Rating flow works same as books

2. **MAL Search**:
   - [ ] Search with valid manga name
   - [ ] Search with invalid name (no results)
   - [ ] Search with network error
   - [ ] Rate limiting doesn't block UI

3. **Database**:
   - [ ] Manga saves correctly
   - [ ] Manga loads from database
   - [ ] media_type field correct
   - [ ] mal_id stored

4. **Migration**:
   - [ ] Existing books not affected
   - [ ] Database version updates
   - [ ] Old books have media_type = 'book'

5. **Rating**:
   - [ ] Can rate manga vs books
   - [ ] Comparison screen works
   - [ ] Tier list shows manga

### Edge Cases

- Search with special characters
- Very long manga names
- Manga with no author
- Manga with multiple authors
- Manga with no cover image
- Network timeout during search
- API returns malformed JSON

## Future Enhancements

### Planned Features

1. **Visual Indicators**:
   - Badge on manga showing 📚 icon
   - Filter to show only books or manga
   - Separate counts in stats

2. **Enhanced MAL Integration**:
   - Show MAL score on manga cards
   - Link to MAL page
   - Import reading status from MAL
   - Sync ratings to MAL account

3. **Manga-Specific Fields**:
   - Volumes owned/read
   - Chapters read
   - Ongoing vs Completed status
   - Original language

4. **Import/Export**:
   - Import manga list from MAL
   - Export manga separately from books
   - CSV format includes media_type

5. **Statistics**:
   - Books vs Manga ratio
   - Average rating per type
   - Reading trends over time

## Troubleshooting

### "No results found"

**Cause**: Manga name not in MyAnimeList or misspelled

**Solution**:
- Try different spelling
- Use English or original Japanese title
- Try romanized version
- Enter data manually

### "Network error"

**Cause**: No internet connection or API down

**Solution**:
- Check internet connection
- Retry later
- Use manual entry

### Manga not saving

**Cause**: Database error or validation failure

**Solution**:
- Ensure title is not empty
- Check logs for errors
- Restart app

### Old manga showing as books

**Cause**: Migration didn't run or was interrupted

**Solution**:
- Reinstall app (will re-run migration)
- Or manually update in database

## Version History

- **v1.5.0** (2026-07-18): Initial manga support release
  - MyAnimeList integration
  - Media type system
  - AddMangaScreen
  - Database migration

---

**Status**: ✅ Stable (v1.5.0)
**Last Updated**: 2026-07-18
**Maintainer**: BookRater Team
