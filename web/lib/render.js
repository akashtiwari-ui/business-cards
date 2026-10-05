// Server-rendered HTML for public profiles (PRD 4.7). Plain strings, no
// framework: the page must paint fast on 4G and work in any mobile browser.

export function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

/** Only http(s) links are rendered, so stored values can never run script. */
export function safeHttpUrl(value) {
  try {
    const url = new URL(String(value ?? '').trim());
    return url.protocol === 'https:' || url.protocol === 'http:' ? url.href : null;
  } catch {
    return null;
  }
}

function initials(name) {
  return name.trim().split(/\s+/).slice(0, 2).map((part) => part[0]?.toUpperCase() ?? '').join('');
}

function displayUrl(href) {
  return href.replace(/^https?:\/\/(www\.)?/, '').replace(/\/$/, '');
}

const STYLES = `
:root{--bg:#f4f6f9;--card:#fff;--ink:#17202b;--muted:#5c6773;--line:#e2e7ee;--brand:#1b5e8c;--brand-ink:#fff;--soft:#e3eef7}
@media (prefers-color-scheme:dark){:root{--bg:#10161d;--card:#18212b;--ink:#e7edf3;--muted:#9aa8b6;--line:#2a3542;--brand:#7fb6e3;--brand-ink:#0b2236;--soft:#1f2e3c}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.5 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;-webkit-text-size-adjust:100%}
main{max-width:480px;margin:0 auto;padding:16px 16px 40px}
.banner{background:var(--soft);border-radius:12px;padding:10px 14px;font-size:14px;color:var(--muted);margin-bottom:16px}
.banner strong{color:var(--ink)}
.card{background:var(--card);border:1px solid var(--line);border-radius:20px;padding:24px}
.head{display:flex;gap:16px;align-items:center}
.avatar{flex:none;width:72px;height:72px;border-radius:50%;background:var(--brand);color:var(--brand-ink);display:grid;place-items:center;font-size:28px;font-weight:600}
h1{margin:0;font-size:24px;line-height:1.25;overflow-wrap:anywhere}
.headline,.location{margin:2px 0 0;color:var(--muted)}
.bio{margin:16px 0 0;white-space:pre-line}
.actions{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:20px}
.btn{display:flex;align-items:center;justify-content:center;min-height:48px;border-radius:12px;font-weight:600;text-decoration:none;border:1px solid var(--line);color:var(--ink);background:var(--card)}
.btn.primary{grid-column:1/-1;background:var(--brand);color:var(--brand-ink);border-color:var(--brand)}
.links{list-style:none;margin:20px 0 0;padding:0;border-top:1px solid var(--line)}
.links a{display:flex;flex-direction:column;padding:12px 0;border-bottom:1px solid var(--line);color:var(--ink);text-decoration:none;min-height:48px}
.links span{font-size:13px;color:var(--muted)}
.links b{font-weight:500;overflow-wrap:anywhere}
footer{text-align:center;color:var(--muted);font-size:13px;margin-top:24px}
.empty{text-align:center;padding:48px 24px}
`;

function page({ title, description, canonical, indexable, body }) {
  const meta = [
    `<meta property="og:title" content="${escapeHtml(title)}">`,
    `<meta property="og:description" content="${escapeHtml(description)}">`,
    `<meta property="og:type" content="profile">`,
    canonical ? `<meta property="og:url" content="${escapeHtml(canonical)}">` : '',
    `<meta name="twitter:card" content="summary">`,
    `<meta name="robots" content="${indexable ? 'index,follow' : 'noindex,nofollow'}">`,
    canonical ? `<link rel="canonical" href="${escapeHtml(canonical)}">` : '',
  ].filter(Boolean).join('\n');

  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${escapeHtml(title)}</title>
<meta name="description" content="${escapeHtml(description)}">
<meta name="theme-color" content="#1b5e8c">
${meta}
<style>${STYLES}</style>
</head>
<body>
<main>
${body}
<footer>Made with B Card · One tap to share who you are</footer>
</main>
</body>
</html>`;
}

export function renderProfile(card, { canonical } = {}) {
  const headline = [card.title, card.company].filter(Boolean).join(' · ');
  const vcardHref = `/p/${encodeURIComponent(card.slug)}/vcard`;
  const tel = card.phone ? card.phone.replace(/[^\d+]/g, '') : '';

  const links = [
    ['Website', card.website],
    ['LinkedIn', card.linkedin],
    ...(Array.isArray(card.links) ? card.links.map((l) => [l?.label || 'Link', l?.url]) : []),
  ]
    .map(([label, url]) => [label, safeHttpUrl(url)])
    .filter(([, href]) => href);

  const body = `
<p class="banner"><strong>No app needed.</strong> This is a web profile anyone can view.</p>
<article class="card">
  <div class="head">
    <div class="avatar" aria-hidden="true">${escapeHtml(initials(card.name))}</div>
    <div>
      <h1>${escapeHtml(card.name)}</h1>
      ${headline ? `<p class="headline">${escapeHtml(headline)}</p>` : ''}
      ${card.location ? `<p class="location">${escapeHtml(card.location)}</p>` : ''}
    </div>
  </div>
  ${card.bio ? `<p class="bio">${escapeHtml(card.bio)}</p>` : ''}
  <div class="actions">
    <a class="btn primary" href="${vcardHref}">Save to contacts</a>
    ${tel ? `<a class="btn" href="tel:${escapeHtml(tel)}">Call</a>` : ''}
    ${card.email ? `<a class="btn" href="mailto:${escapeHtml(card.email)}">Email</a>` : ''}
  </div>
  ${links.length ? `<ul class="links">${links.map(([label, href]) => `
    <li><a href="${escapeHtml(href)}" rel="noopener nofollow" target="_blank"><span>${escapeHtml(label)}</span><b>${escapeHtml(displayUrl(href))}</b></a></li>`).join('')}
  </ul>` : ''}
</article>`;

  return page({
    title: `${card.name} · B Card`,
    description: headline || `Contact details for ${card.name}`,
    canonical,
    indexable: card.indexable === true,
    body,
  });
}

/** Neutral page for unknown, hidden or deleted profiles (PRD 4.2, 4.8). */
export function renderUnavailable() {
  return page({
    title: 'Profile unavailable · B Card',
    description: 'This profile is not available.',
    indexable: false,
    body: `<article class="card empty"><h1>Profile unavailable</h1><p class="headline">This profile is hidden or no longer exists.</p></article>`,
  });
}
