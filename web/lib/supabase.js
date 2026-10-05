// Reads a live card from the public_cards view. That view already drops hidden
// cards and hidden phone/email, so nothing private can reach the page.

const SLUG = /^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$/;

export function isValidSlug(slug) {
  return typeof slug === 'string' && SLUG.test(slug) && !slug.includes('--');
}

/** Returns the card, or null when the slug is unknown or the profile is hidden. */
export async function fetchPublicCard(slug, env = process.env) {
  if (!isValidSlug(slug)) return null;
  const { SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY } = env;
  if (!SUPABASE_URL || !SUPABASE_PUBLISHABLE_KEY) {
    throw new Error('SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be set');
  }

  const url = `${SUPABASE_URL}/rest/v1/public_cards?slug=eq.${slug}&select=*&limit=1`;
  const response = await fetch(url, {
    headers: { apikey: SUPABASE_PUBLISHABLE_KEY, Accept: 'application/json' },
    signal: AbortSignal.timeout(4000),
  });
  if (!response.ok) throw new Error(`Supabase responded ${response.status}`);
  const rows = await response.json();
  return rows[0] ?? null;
}
