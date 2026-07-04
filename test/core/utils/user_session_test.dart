import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wello_frontend/core/utils/user_session.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('UserSession save, retrieve and clear session details', () async {
    // Verify initial state
    expect(await UserSession.getUserId(), isNull);
    expect(await UserSession.getToken(), isNull);
    expect(await UserSession.getEmail(), isNull);

    // Save mock details
    await UserSession.saveUserId(123);
    await UserSession.saveToken('mock_auth_token_xyz');
    await UserSession.saveEmail('user@wello.com');

    // Verify retrieval
    expect(await UserSession.getUserId(), 123);
    expect(await UserSession.getToken(), 'mock_auth_token_xyz');
    expect(await UserSession.getEmail(), 'user@wello.com');

    // Clear session
    await UserSession.clearSession();

    // Verify keys were deleted
    expect(await UserSession.getUserId(), isNull);
    expect(await UserSession.getToken(), isNull);
    expect(await UserSession.getEmail(), isNull);
  });
}
