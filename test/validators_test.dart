import 'package:campus_incident_app/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ALU email check', () {
    test('accepts student and staff ALU emails', () {
      expect(Validators.isAluEmail('e.atigbi@alustudent.com'), isTrue);
      expect(Validators.isAluEmail('  Someone@ALUSTUDENT.com '), isTrue);
      expect(Validators.isAluEmail('staff@alueducation.com'), isTrue);
    });

    test('rejects other domains and look-alikes', () {
      expect(Validators.isAluEmail('someone@gmail.com'), isFalse);
      expect(Validators.isAluEmail('someone@alustudent.com.fake.io'), isFalse);
      expect(Validators.isAluEmail('someone@notalustudent.com'), isFalse);
      expect(Validators.isAluEmail('no-at-sign'), isFalse);
    });

    test('only alueducation.com counts as a staff email', () {
      expect(Validators.isStaffEmail('lecturer@alueducation.com'), isTrue);
      expect(Validators.isStaffEmail('e.atigbi@alustudent.com'), isFalse);
      expect(Validators.isStaffEmail('fake@alueducation.com.evil.io'), isFalse);
    });

    test('form validator gives a clear message', () {
      expect(Validators.aluEmail(''), 'Please enter your email');
      expect(Validators.aluEmail('a@gmail.com'), contains('ALU email'));
      expect(Validators.aluEmail('a@alustudent.com'), isNull);
    });
  });

  group('Other validators', () {
    test('password needs 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('confirm password must match', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), 'Passwords do not match');
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('text length limits', () {
      expect(Validators.text('   ', label: 'Title'), 'Title is required');
      expect(Validators.text('Hi', label: 'Title', min: 5), contains('at least 5'));
      expect(Validators.text('Broken tap', label: 'Title', min: 5), isNull);
    });
  });
}
