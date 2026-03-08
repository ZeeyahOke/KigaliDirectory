import 'package:flutter_test/flutter_test.dart';
import 'package:kigali_directory/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required validator returns error for empty string', () {
      expect(Validators.required('', 'Name'), 'Name is required');
    });

    test('required validator returns null for non-empty string', () {
      expect(Validators.required('Test', 'Name'), null);
    });

    test('email validator accepts valid email', () {
      expect(Validators.email('test@example.com'), null);
    });

    test('email validator rejects invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('password validator rejects short password', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('password validator accepts valid password', () {
      expect(Validators.password('123456'), null);
    });

    test('latitude validator accepts valid latitude', () {
      expect(Validators.latitude('-1.9403'), null);
    });

    test('latitude validator rejects out-of-range latitude', () {
      expect(Validators.latitude('91'), isNotNull);
    });

    test('longitude validator accepts valid longitude', () {
      expect(Validators.longitude('29.8739'), null);
    });

    test('phone validator accepts valid phone', () {
      expect(Validators.phone('+250 788 305 087'), null);
    });
  });
}
