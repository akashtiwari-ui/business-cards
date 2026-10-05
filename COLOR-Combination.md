Here is a palette and type system taken from your concept screens. The hex values are my estimates of the colors in the image, so adjust them once you sample the real file.

## Colors

| Role | Name | Hex | Used for |
| --- | --- | --- | --- |
| Primary | B Blue | `#0B5FFF` | Main buttons (Share my card, Review contact), active tab, links |
| Brand dark | Midnight Navy | `#0A1F44` | Card background, public profile header, scanner sheet |
| Primary tint | Sky Tint | `#E8F0FF` | Icon backgrounds, Client tag, selected chips |
| Background | Cloud | `#F7F8FB` | App background |
| Surface | White | `#FFFFFF` | Cards, sheets, inputs |
| Text primary | Ink | `#101828` | Titles and body text |
| Text secondary | Slate | `#667085` | Subtitles, hints, inactive tab icons |
| Border | Mist | `#E4E7EC` | Dividers, outlined buttons |
| Success | Green | `#12B76A` on `#E7F8EF` | "Public profile - Live", "Synced" |
| Partner tag | Mint | `#16A34A` on `#E6F6EA` | Partner chips |
| Lead / warning | Amber | `#F79009` on `#FFF1DB` | Lead tag, offline warnings |
| Error | Red | `#D92D20` | Failed scan, delete |

For avatar initials, use soft pastels (pink `#FAD1E6`, yellow `#FDEFB2`, lavender `#E1DBFF`, mint `#CDEFD9`) with dark text, picked by hashing the contact name.

**Dark mode:** use `#0B1220` as the background, `#151C2C` for surfaces, `#5B93FF` for the primary, and `#F2F4F7` for text.

**In Flutter (Material 3):**
```dart
ColorScheme.fromSeed(seedColor: Color(0xFF0B5FFF))
  .copyWith(primary: Color(0xFF0B5FFF), surface: Colors.white,
            onSurface: Color(0xFF101828), tertiary: Color(0xFF0A1F44));
```

## Font family

Use **Inter** for everything. It is clean and very legible at small sizes, which suits a contact list, and it is free through the `google_fonts` package. If you want a bit more personality on the card name and screen titles, pair it with **Plus Jakarta Sans** for headings.

| Style | Font | Size / weight |
| --- | --- | --- |
| Screen title ("Contacts") | Inter or Plus Jakarta Sans | 24 / 700 |
| Card name | Plus Jakarta Sans | 22 / 700 |
| Section heading | Inter | 18 / 600 |
| Body | Inter | 14-16 / 400 |
| Button | Inter | 15 / 600 |
| Caption, tag chip | Inter | 12 / 500 |

## Shape and spacing
- Corner radius is 16 for cards and sheets, 12 for buttons and inputs, and fully rounded for tag chips.
- Use a 4/8 px spacing grid, with a minimum touch target of 48 dp.
- Keep shadows soft and use borders instead where you can.

I can add this to the PRD as a design section if you'd like.