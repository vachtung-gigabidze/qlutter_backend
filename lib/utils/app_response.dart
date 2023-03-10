import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:qlutter_backend/model/response_model.dart' as rm;

class AppResponse extends Response {
  AppResponse.unauthorized(dynamic error, {String? message})
      : super.unauthorized(body: _getResponseModel(error, message));

  AppResponse.badRequest({String? message})
      : super.badRequest(
            body: rm.ResponseModel(message: message ?? "Ошибка запроса"));

  AppResponse.ok({dynamic body, String? message, Map<String, dynamic>? headers})
      : super.ok(rm.ResponseModel(data: body, message: message),
            headers: headers);
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static rm.ResponseModel _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return rm.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return rm.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    return rm.ResponseModel(
        error: error.toString(), message: message ?? "Неизвестная ошибка");
  }
}
