import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:qlutter_backend/utils/app_env.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final jwtClaim = verifyJwtHS256Signature(token, AppEnv.secretKey);
      return int.parse(jwtClaim["id"].toString());
    } catch (_) {
      rethrow;
    }
  }

  static int getIdFromHeader(String header) {
    try {
      final token = const AuthorizationBearerParser().parse(header);
      return getIdFromToken(token ?? "");
    } catch (_) {
      rethrow;
    }
  }
}
