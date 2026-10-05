import assert from 'node:assert/strict';
import { test } from 'node:test';

import { buildVCard, escapeValue, foldLine } from '../lib/vcard.js';

test('builds a vCard 3.0 with CRLF line endings', () => {
  const vcf = buildVCard(
    { name: 'Aarav Kumar Shah', company: 'Acme', title: 'Founder', phone: '+91 98765 43210', email: 'a@acme.in', website: 'https://acme.in', links: [] },
    { profileUrl: 'https://bcard.link/p/aarav' },
  );
  const lines = vcf.split('\r\n');
  assert.equal(lines[0], 'BEGIN:VCARD');
  assert.equal(lines[1], 'VERSION:3.0');
  assert.ok(lines.includes('N:Shah;Aarav Kumar;;;'));
  assert.ok(lines.includes('FN:Aarav Kumar Shah'));
  assert.ok(lines.includes('TEL;TYPE=CELL:+91 98765 43210'));
  assert.ok(lines.includes('URL:https://bcard.link/p/aarav'));
  assert.ok(vcf.endsWith('END:VCARD\r\n'));
});

test('hidden fields are left out', () => {
  const vcf = buildVCard({ name: 'Priya', phone: null, email: null, links: [] });
  assert.doesNotMatch(vcf, /TEL|EMAIL/);
  assert.match(vcf, /N:;Priya;;;/);
});

test('escapes special characters', () => {
  assert.equal(escapeValue('a,b;c\\d\ne'), 'a\\,b\\;c\\\\d\\ne');
});

test('folds long lines at 75 octets without breaking UTF-8', () => {
  const folded = foldLine('NOTE:' + 'नमस्ते '.repeat(20));
  for (const line of folded.split('\r\n')) {
    assert.ok(Buffer.byteLength(line) <= 75);
  }
  assert.equal(folded.split('\r\n ').join(''), 'NOTE:' + 'नमस्ते '.repeat(20));
});
