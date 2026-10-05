import 'package:b_card/features/card/domain/card_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateSlug', () {
    test('accepts lowercase letters, digits and single hyphens', () {
      expect(validateSlug('aarav'), isNull);
      expect(validateSlug('aarav-shah-2'), isNull);
    });

    test('rejects empty, short, long, uppercase and edge hyphens', () {
      expect(validateSlug(''), isNotNull);
      expect(validateSlug('ab'), isNotNull);
      expect(validateSlug('a' * 31), isNotNull);
      expect(validateSlug('Aarav'), isNotNull);
      expect(validateSlug('-aarav'), isNotNull);
      expect(validateSlug('aarav-'), isNotNull);
      expect(validateSlug('aa--rav'), isNotNull);
    });

    test('rejects reserved words', () {
      expect(validateSlug('admin'), 'This link is reserved');
    });
  });

  test('suggestSlug turns a name into a valid slug', () {
    expect(suggestSlug('Aarav Shah'), 'aarav-shah');
    expect(suggestSlug('  Dr. Priya  K. '), 'dr-priya-k');
    expect(validateSlug(suggestSlug('Aarav Shah')), isNull);
    expect(suggestSlug('x' * 40).length, 30);
  });

  test('validateName requires a name', () {
    expect(validateName('  '), isNotNull);
    expect(validateName('Aarav'), isNull);
  });

  test('optional fields accept empty input', () {
    expect(validateEmail(''), isNull);
    expect(validatePhone(''), isNull);
    expect(validateUrl(''), isNull);
  });

  test('validateEmail and validatePhone reject malformed input', () {
    expect(validateEmail('aarav@example.com'), isNull);
    expect(validateEmail('aarav@'), isNotNull);
    expect(validatePhone('+91 98765 43210'), isNull);
    expect(validatePhone('call me'), isNotNull);
  });

  test('normalizeUrl adds https to bare domains', () {
    expect(normalizeUrl('example.com'), 'https://example.com');
    expect(normalizeUrl('http://example.com'), 'http://example.com');
    expect(normalizeUrl(' '), '');
    expect(validateUrl('example.com'), isNull);
    expect(validateUrl('not a url'), isNotNull);
  });
}
