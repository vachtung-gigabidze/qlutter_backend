import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:qlutter_backend/model/response_model.dart' as rm;
import 'package:qlutter_backend/utils/app_env.dart';
import 'package:qlutter_backend/utils/app_response.dart';
import 'package:qlutter_backend/utils/app_utils.dart';

import '../model/user.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);
  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
          body:
              rm.ResponseModel(message: "Поля password username обязательны"));
    }

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties(
            (table) => [table.id, table.salt, table.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input("Пользователь не найден", []);
      }
      final requestHasPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if (requestHasPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);

        final alowCORS = <String, dynamic>{
          'content-Type': 'text/plain; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': 'GET , POST'
        };
        // CORSPolicy.defaultPolicy.allowedMethods = [
        //   "POST",
        //   "PUT",
        //   "DELETE",
        //   "GET"
        // ];
        // CORSPolicy.defaultPolicy.allowedOrigins = [
        //   "dart.nvavia.ru",
        //   "https://wb.nvavia.ru"
        // ];

        return AppResponse.ok(
          body: newUser?.backing.contents,
          message: "Успешная авторизация",
          headers: alowCORS,
        );
      } else {
        throw QueryException.input("Пароль не верный", []);
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка авторизации");
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
          body: rm.ResponseModel(
              message: "Поля password username email обязательны"));
    }
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);
    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.id!; //.asMap()["id"];
        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
          body: userData?.backing.contents, message: "Успешная регистрация");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка регистрации");
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"].toString()
      ..values.refreshToken = tokens["refresh"].toString();
    await qUpdateTokens.updateOne();
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken) {
        return Response.unauthorized(
            body: rm.ResponseModel(message: "Token is not valid"));
      } else {
        await _updateTokens(id, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(id);
        return AppResponse.ok(
            body: user?.backing.contents,
            message: "Успешное обновление токенов");
      }
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Ошибка обновления токенов");
    }
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = AppEnv.secretKey;
    final accessClaimSet =
        JwtClaim(maxAge: Duration(hours: AppEnv.time), otherClaims: {"id": id});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
