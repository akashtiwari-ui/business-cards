// vCard 3.0 (RFC 2426): the version both iOS Contacts and Android import.

/** Escapes a property value: backslash, comma, semicolon and newlines. */
export function escapeValue(value) {
  return String(value ?? '')
    .replaceAll('\\', '\\\\')
    .replaceAll(',', '\\,')
    .replaceAll(';', '\\;')
    .replace(/\r\n|\r|\n/g, '\\n');
}

/** Folds a content line at 75 octets without splitting a UTF-8 character. */
export function foldLine(line) {
  const out = [];
  let current = '';
  let bytes = 0;
  for (const char of line) {
    const size = Buffer.byteLength(char);
    const limit = out.length === 0 ? 75 : 74; // continuation lines start with a space
    if (bytes + size > limit) {
      out.push(current);
      current = '';
      bytes = 0;
    }
    current += char;
    bytes += size;
  }
  out.push(current);
  return out.join('\r\n ');
}

function splitName(name) {
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return { given: parts[0], family: '' };
  return { given: parts.slice(0, -1).join(' '), family: parts.at(-1) };
}

export function buildVCard(card, { profileUrl } = {}) {
  const { given, family } = splitName(card.name);
  const urls = [
    card.website,
    card.linkedin,
    ...(Array.isArray(card.links) ? card.links.map((l) => l?.url) : []),
    profileUrl,
  ].filter((u) => typeof u === 'string' && /^https?:\/\//i.test(u));

  const lines = [
    'BEGIN:VCARD',
    'VERSION:3.0',
    `N:${escapeValue(family)};${escapeValue(given)};;;`,
    `FN:${escapeValue(card.name)}`,
    card.company && `ORG:${escapeValue(card.company)}`,
    card.title && `TITLE:${escapeValue(card.title)}`,
    card.phone && `TEL;TYPE=CELL:${escapeValue(card.phone)}`,
    card.email && `EMAIL;TYPE=INTERNET:${escapeValue(card.email)}`,
    card.location && `ADR;TYPE=WORK:;;;${escapeValue(card.location)};;;`,
    ...urls.map((u) => `URL:${escapeValue(u)}`),
    card.bio && `NOTE:${escapeValue(card.bio)}`,
    'END:VCARD',
  ].filter(Boolean);

  return lines.map(foldLine).join('\r\n') + '\r\n';
}
