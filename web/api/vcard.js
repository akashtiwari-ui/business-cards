import { fetchPublicCard } from '../lib/supabase.js';
import { buildVCard } from '../lib/vcard.js';

export async function GET(request) {
  const url = new URL(request.url);
  const slug = (url.searchParams.get('slug') ?? '').toLowerCase();

  let card;
  try {
    card = await fetchPublicCard(slug);
  } catch (error) {
    console.error('vcard lookup failed', error);
    return new Response('Profile temporarily unavailable', { status: 503, headers: { 'Cache-Control': 'no-store' } });
  }
  if (!card) {
    return new Response('Profile unavailable', { status: 404, headers: { 'X-Robots-Tag': 'noindex' } });
  }

  const body = buildVCard(card, { profileUrl: `${url.origin}/p/${card.slug}` });
  return new Response(body, {
    headers: {
      'Content-Type': 'text/vcard; charset=utf-8',
      'Content-Disposition': `attachment; filename="${card.slug}.vcf"`,
      'Cache-Control': 'public, s-maxage=5, stale-while-revalidate=86400',
      'X-Robots-Tag': 'noindex',
    },
  });
}
