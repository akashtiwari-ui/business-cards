# B Card — Digital Business Card & Contact CRM: Feature PRD

Oct 5, 2026 · @Akash

## 1. Overview

B Card replaces paper business cards with a personal QR code and web profile, and turns every card you scan into a saved, searchable contact. It is a Flutter (Material Design 3) mobile app for Android and iOS, backed by a lightweight public profile page that works without the app.

**Problem.** Paper cards get lost, go out of date and never reach a phone's contacts. Existing digital card tools are either expensive, locked to one brand, or make the receiver install an app. Small business owners also have no simple place to remember where and when they met someone.

**Vision.** One tap to share who you are; one scan to remember who you met.

**Target users.**

- Founders, freelancers and small business owners who meet clients at events and meetups
- Sales and business-development professionals who need a lightweight contact CRM
- Agencies and shops that want a branded, always-current card for customers

**Goals.**

1. Let a user create a branded digital card in under 3 minutes.
2. Let anyone receive that card by scanning a QR code or opening a link, with no app install.
3. Let a user scan another B Card and save the contact in under 10 seconds.
4. Keep all saved contacts searchable, taggable and available offline.

**Non-goals for v1.**

- Scanning paper cards with OCR (candidate for v1.2)
- Team or company-wide shared card directories
- In-app messaging or email campaigns
- Payments or monetisation beyond a simple free tier

## 2. Success metrics and release scope

The MVP succeeds if new users reach a shareable card fast and actually use scanning. Targets below are proposed starting points to validate after the first 500 installs.

| Metric | Definition | Target (first 90 days) |
| --- | --- | --- |
| Activation | Signups that publish a card within 24 hours | 60% |
| Time to first card | Signup to published public profile | under 3 min (median) |
| Share rate | Users who share their card at least once in week 1 | 50% |
| Scan-to-save rate | Successful scans that end in a saved contact | 85% |
| Scan speed | Camera open to profile found | under 3 s (median) |
| Retention | Users who open the app in week 4 | 25% |
| Profile views per card | Average public profile opens per user per month | 8 |

**Release scope.**

| Release | Scope | Features |
| --- | --- | --- |
| MVP (v1.0) | Create, share, scan, save | Account and onboarding, card editor, QR share, link share, QR scanner with auto-save, contact list with search, contact details with notes, public web profile, offline contacts, basic settings |
| v1.1 | Retention and CRM | NFC write and tap, tags and filters, follow-up reminders, vCard export and Save to phone contacts, multiple cards, card themes |
| v1.2 | Growth | Paper-card OCR scan, lead capture form on public profile, analytics dashboard, CSV export, Apple and Google Wallet pass |
| Later | Teams | Team cards, shared contact pool, CRM integrations such as HubSpot or Zoho |

## 3. Personas and key user flows

Two roles drive the MVP: the person who shares a card and the person who collects cards.

| Persona | Context | Core need |
| --- | --- | --- |
| Founder, shares often | Meets 10-20 people at a meetup or client visit | Share details instantly and look polished, with no paper |
| Sales professional, collects often | Gathers many cards at conferences and follows up later | Capture contacts fast, with where and when each person was met |
| Visitor with no app | Scans the QR with the stock phone camera | See the profile and save it without installing anything |

&#91;embedded content: core flows · share and scan, 1 decision\]

Sharing needs no app on the receiving side, and scanning saves the contact as soon as the profile is found. An unreadable code never creates a contact, and a scan made offline is stored as pending and completes on reconnect.

## 4. Feature requirements

Priority: P0 = must ship in MVP, P1 = v1.1, P2 = later. Each feature maps to a screen in the UI concept.

### 4.1 Onboarding and account (P0)

- Sign up with phone OTP, Google or Apple; email optional.
- Three-step setup: name and photo, role and company, contact details. Only name is mandatory.
- Choose a profile link slug (example.com/p/aarav); check availability live and suggest alternatives.
- Camera and notification permissions are requested in context, not at launch.

**Acceptance criteria:** a new user can publish a card in under 3 minutes; slug collisions are rejected with suggestions; skipping optional fields never blocks publishing.

### 4.2 My Card (P0)

The home screen shows the user's digital card, its public status and the main actions.

| Requirement | Detail | Priority |
| --- | --- | --- |
| Card preview | Renders photo, name, title, company, email, location and logo exactly as the public profile shows them | P0 |
| Edit card | Fields: photo, name, title, company, phone, email, website, LinkedIn and other links, location, short bio, logo | P0 |
| Public status pill | Shows Public profile - Live or Hidden; tap to toggle visibility | P0 |
| Share my card | Opens the Share screen (4.3) | P0 |
| Preview profile | Opens the public profile exactly as a visitor sees it | P0 |
| NFC setup entry | Row that opens the NFC card writing flow | P1 |
| Card theme | Colour, accent and layout presets; brand colour picker | P1 |
| Multiple cards | Personal and business cards under one account | P1 |

**Acceptance criteria:** edits appear on the public profile within 5 seconds; hiding the profile makes the public URL return a neutral Profile unavailable page; the QR code and link never change when the card is edited.

### 4.3 Share card (P0)

- **QR code tab:** a scannable QR code with the brand logo in the centre, the user's name beneath it and the line Scan to view my profile. The QR encodes the permanent public profile URL, so it keeps working after edits.
- **Link row:** shows the short link with a Copy link button and a confirmation toast.
- **Share link:** opens the system share sheet with the link and a short message.
- **NFC card tab (P1):** write the profile link to a writable NFC tag, with clear states for ready, writing, success and failure, and a tap-to-share mode where the phone supports it.
- **Save QR as image (P1):** export a high-resolution QR for print or email signatures.
- Screen brightness is raised automatically while the QR is shown, and restored on exit.

**Acceptance criteria:** the QR scans from 1 metre on a phone screen in normal indoor light; works fully offline once generated; error correction level is at least M so the centre logo does not break scanning.

### 4.4 Scan a card (P0)

- Full-screen camera with a framing guide, a torch toggle and the hint Align a profile QR code within the frame.
- Decodes B Card QR codes and any QR that holds a vCard or a profile URL, so cards from other tools are also accepted.
- On a valid B Card QR, the app fetches the profile and shows a Profile found sheet with photo, name, title and company, plus Review contact.
- Review contact shows all fetched fields, editable, with tag and note inputs, then Save. The default is auto-save: the contact is stored the moment the profile is found, and the review screen is an optional edit step.
- Duplicate detection: if the same profile or email already exists, offer Update existing instead of creating a second entry.
- Records source (scanned via QR), date and time, and, if the user allows, approximate location.
- Failure states: unreadable code, non-contact QR, offline (queue the scan and complete it when back online), camera permission denied (link to settings).
- Import from gallery (P1): pick a photo or screenshot that contains a QR code.

**Acceptance criteria:** median time from camera open to Profile found is under 3 seconds on a mid-range Android phone; a scan with no network is saved as a pending contact with the scanned URL and completes automatically on reconnect; the same code scanned twice never creates two contacts.

### 4.5 Contacts (P0)

- List of saved contacts with avatar or initials, name, company and a tag chip (Client, Partner, Lead, custom).
- Search by name, company, email, phone, tag and note text; results update as the user types.
- Filter chips: All, Clients, Partners, plus user-defined tags (P1); sort by recent, name or company.
- Sync status badge (Synced, Syncing, Offline); an offline banner confirms contacts remain available.
- Floating add button: scan a card, or add a contact manually.
- Swipe actions: call, email, delete with undo.
- Empty state with a prompt to scan the first card.

**Acceptance criteria:** list opens in under 1 second with 1,000 contacts; search returns in under 300 ms; all contacts are readable and editable with no network and sync without data loss when the connection returns.

### 4.6 Contact details (P0)

| Block | Detail | Priority |
| --- | --- | --- |
| Header | Photo, name, title, company, location | P0 |
| Quick actions | Call, Email, Website; open the phone dialer, mail app and browser | P0 |
| Fields | Email, phone, company, links; tap to copy, long-press to edit | P0 |
| Tags | Add or remove tags; tag colours | P0 |
| Notes | Free-text notes, for example where and why they met; autosave | P0 |
| Provenance | Added via QR scan, with date; shown on every scanned contact | P0 |
| Save to phone contacts | Writes a standard vCard entry to the device address book | P0 |
| Follow-up reminder | Set a date and get a push notification | P1 |
| Live update | If the contact edits their B Card, offer a one-tap refresh | P1 |
| Share contact, delete | Overflow menu; delete requires confirmation | P0 |

**Acceptance criteria:** Save to phone contacts requests permission only on first use, maps every field correctly to the address book, and never creates a duplicate if tapped twice.

### 4.7 Public profile web page (P0)

This is what anyone sees after scanning the QR code with their normal camera or opening the link. It must work in any mobile browser without an app.

- Server-rendered, fast page showing photo, name, title, company, location, bio and link rows (website, LinkedIn and others).
- Primary actions: Save to Contacts (downloads a vCard), Call, Email.
- Banner: No app needed. This is a web profile anyone can view, with a soft prompt to get B Card.
- Clean URL under the user's slug, proper Open Graph preview when the link is shared in chat apps.
- Honours the visibility toggle and the per-field privacy settings (4.8).
- Lead capture form so visitors can send their details back (P1).

**Acceptance criteria:** first contentful paint under 1.5 s on a 4G connection; the vCard imports correctly on both iOS and Android; the page is indexable only if the user opts in.

### 4.8 Settings and privacy (P0)

- Account: profile slug, phone, email, linked sign-in methods, sign out, delete account.
- Privacy: profile visibility, per-field visibility (hide phone or email from the public page), search-engine indexing off by default, and whether scan location is recorded.
- Data: export all contacts as vCard or CSV (P1), backup and sync status.
- Preferences: auto-save versus review-before-save on scan, default tag for new contacts, theme (light, dark, system).
- Support: help, feedback, terms and privacy policy, app version.

**Acceptance criteria:** deleting an account removes the profile, QR and all stored contacts within 30 days and the public URL returns Profile unavailable immediately.

## 5. Non-functional requirements, data model and technology

The app must feel instant, work offline and keep personal data safe; Flutter with a small managed backend keeps the MVP cheap to build and run.

### 5.1 Non-functional requirements

| Area | Requirement |
| --- | --- |
| Performance | Cold start under 2 s; scan to result under 3 s; list scroll at 60 fps with 1,000 contacts |
| Offline | Contacts, own card and own QR fully usable offline; writes queued and synced later with last-write-wins per field |
| Platforms | Android 8+ and iOS 15+; phones first, tablet layout later |
| Accessibility | Screen-reader labels, minimum 48 dp touch targets, contrast AA, dynamic text sizes |
| Reliability | 99.5% uptime for the public profile; static caching so cards still load if the API is slow |
| Localisation | English at launch; strings externalised for Hindi and Marathi |
| Privacy | Data encrypted in transit and at rest; no contact data used for ads or sold |

### 5.2 Core data model

| Entity | Key fields |
| --- | --- |
| User | id, auth providers, phone, email, created\_at |
| Card | id, user\_id, slug, name, title, company, bio, photo\_url, logo\_url, links\[\], theme, visibility, field\_visibility |
| Contact | id, owner\_id, source (qr, manual, nfc), source\_card\_id, name, title, company, email, phone, links\[\], tags\[\], notes, scanned\_at, scan\_location, sync\_state |
| Tag | id, owner\_id, name, colour |
| ScanEvent | id, card\_id, type (view, scan, save), timestamp, coarse\_region |
| Reminder (P1) | id, contact\_id, due\_at, status |

A contact scanned from a B Card stores a copy of the fields at scan time plus a reference to the source card, so the owner's later edits can be offered as an update instead of silently changing the saved record.

### 5.3 Technology choices

- **App:** Flutter with Material Design 3; mobile\_scanner for QR decoding, qr\_flutter for QR generation, nfc\_manager for NFC (P1), local database such as Drift or Isar for offline contacts.
- **Backend:** Supabase or Firebase for auth, Postgres or Firestore, file storage and row-level security; one small serverless function renders the public profile page and vCard download.
- **QR content:** a short, permanent HTTPS URL, never raw personal data, so profiles can be updated or hidden after a code is printed.
- **Sync:** local-first with a sync queue; conflicts resolved per field by latest edit time.
- **Open decision:** buy a short domain for profile links before launch, since QR codes in print cannot be changed later.

## 6. Privacy, analytics, risks and open questions

The app stores other people's contact details, so privacy choices are product requirements, not afterthoughts.

### 6.1 Privacy and security

- A person's card is shared by them, so scanning it is consent to receive those details; the app stores only what the profile publicly shows.
- Owners control visibility per field and can hide or delete their profile at any time.
- Scan location is off by default and only coarse; scanned contacts are private to the scanning user.
- Comply with India's DPDP Act and, if launched abroad, GDPR: clear consent text, export and deletion on request, a published privacy policy.
- Rate-limit profile fetches and add basic bot protection on the public page to prevent scraping.
- Profile slugs avoid reserved words and offensive terms.

### 6.2 Analytics events

card\_published, card\_shared (qr, link, nfc), scan\_started, scan\_succeeded, scan\_failed (reason), contact\_saved, contact\_duplicate\_found, search\_used, tag\_added, vcard\_saved\_to\_phone, profile\_viewed (public, aggregate only). No contact content is ever sent to analytics.

### 6.3 Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Scanned person has no B Card | Scanner is useless at events | Accept any vCard or URL QR; add paper-card OCR in v1.2 |
| Network effect is weak | Low viral growth | Public web profile with a soft app prompt; no install needed to receive |
| Printed QR codes break if the domain changes | Lost trust | Own the domain from day one; permanent redirects |
| Privacy complaints about stored contacts | Legal and reputation risk | Minimal data, clear consent, deletion flow |
| Crowded market of card apps | Low differentiation | Lead with the built-in contact CRM and offline reliability |

### 6.4 Open questions

- Should the scanner auto-save silently, or show a one-tap confirmation by default? The concept assumes auto-save with an optional review.
- Is the free tier limited by contacts, cards or themes, and what does a paid plan add?
- Is the first target market India only, or global from launch?
- Which sign-in method matters most for the first users: phone OTP, Google or Apple?

### 6.5 Delivery plan

1. **Weeks 1-2:** design system, card editor, public profile page and vCard download.
2. **Weeks 3-4:** QR share screen, scanner, auto-save, contact list and details.
3. **Weeks 5-6:** offline sync, search, settings, privacy controls and onboarding.
4. **Week 7:** beta with 20-50 users from real meetups; fix scan reliability.
5. **Week 8:** store submission and launch; then v1.1 (NFC, tags, reminders).
