import assert from 'node:assert/strict';
import { test } from 'node:test';

import { escapeHtml, renderProfile, renderUnavailable, safeHttpUrl } from '../lib/render.js';
import { isValidSlug } from '../lib/supabase.js';

const card = {
  slug: 'aarav',
  name: 'Aarav Shah',
  title: 'Founder',
  company: 'Acme',
  location: 'Pune',
  bio: 'Builds things.',
  phone: '+91 98765 43210',
  email: 'aarav@acme.in',
  website: 'https://acme.in',
  linkedin: '',
  links: [{ label: 'Portfolio', url: 'https://acme.in/work' }],
  indexable: false,
};

test('renders the card with save, call and email actions', () => {
  const html = renderProfile(card, { canonical: 'https://bcard.link/p/aarav' });
  assert.match(html, /<h1>Aarav Shah<\/h1>/);
  assert.match(html, /Founder · Acme/);
  assert.match(html, /href="\/p\/aarav\/vcard"/);
  assert.match(html, /href="tel:\+919876543210"/);
  assert.match(html, /href="mailto:aarav@acme.in"/);
  assert.match(html, /No app needed\./);
  assert.match(html, /og:url" content="https:\/\/bcard.link\/p\/aarav"/);
});

test('hidden phone and email (null from the view) render no buttons', () => {
  const html = renderProfile({ ...card, phone: null, email: null });
  assert.doesNotMatch(html, /tel:/);
  assert.doesNotMatch(html, /mailto:/);
});

test('search engines are blocked unless the owner opted in', () => {
  assert.match(renderProfile(card), /noindex,nofollow/);
  assert.match(renderProfile({ ...card, indexable: true }), /index,follow/);
});

test('user content is escaped and only http(s) links are rendered', () => {
  const html = renderProfile({
    ...card,
    name: '<script>alert(1)</script>',
    links: [{ label: 'x', url: 'javascript:alert(1)' }],
  });
  assert.doesNotMatch(html, /<script>/);
  assert.doesNotMatch(html, /javascript:/);
  assert.equal(safeHttpUrl('javascript:alert(1)'), null);
  assert.equal(escapeHtml(`"'<>&`), '&quot;&#39;&lt;&gt;&amp;');
});

test('unavailable page is neutral and not indexable', () => {
  const html = renderUnavailable();
  assert.match(html, /Profile unavailable/);
  assert.match(html, /noindex/);
});

test('slug validation matches the app and database rules', () => {
  assert.ok(isValidSlug('aarav-shah'));
  assert.ok(!isValidSlug('Aarav'));
  assert.ok(!isValidSlug('ab'));
  assert.ok(!isValidSlug('a--b'));
  assert.ok(!isValidSlug('../etc'));
});
