import { fetchPublicCard } from '../lib/supabase.js';
import { renderProfile, renderUnavailable } from '../lib/render.js';

// Short edge cache so edits show within seconds (PRD 4.2), with a long
// stale-while-revalidate window so cards still load if Supabase is slow (PRD 5.1).
const CACHE = 'public, s-maxage=5, stale-while-revalidate=86400';

const CSP = "default-src 'none'; style-src 'unsafe-inline'; img-src 'self' data: https:; base-uri 'none'; form-action 'none'; frame-ancestors 'none'";

function html(body, status, extra = {}) {
  return new Response(body, {
    status,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Content-Security-Policy': CSP,
      ...extra,
    },
  });
}

export async function GET(request) {
  const url = new URL(request.url);
  const slug = (url.searchParams.get('slug') ?? '').toLowerCase();

  let card;
  try {
    card = await fetchPublicCard(slug);
  } catch (error) {
    console.error('profile lookup failed', error);
    return html(renderUnavailable(), 503, { 'Cache-Control': 'no-store', 'Retry-After': '30' });
  }

  if (!card) {
    return html(renderUnavailable(), 404, { 'Cache-Control': CACHE, 'X-Robots-Tag': 'noindex' });
  }

  const canonical = `${url.origin}/p/${card.slug}`;
  return html(renderProfile(card, { canonical }), 200, {
    'Cache-Control': CACHE,
    ...(card.indexable ? {} : { 'X-Robots-Tag': 'noindex' }),
  });
}
