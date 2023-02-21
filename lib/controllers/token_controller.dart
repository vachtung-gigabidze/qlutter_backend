import 'dart:async';
import 'dart:io';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:qlutter_backend/utils/app_env.dart';
import 'package:qlutter_backend/utils/app_response.dart';

class TokenController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    try {
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      final token = const AuthorizationBearerParser().parse(header);
      final jwtClaim = verifyJwtHS256Signature(token ?? "", AppEnv.secretKey);
      jwtClaim.validate();
      return request;
    } catch (error) {
      return AppResponse.unauthorized(error);
    }
  }
}
