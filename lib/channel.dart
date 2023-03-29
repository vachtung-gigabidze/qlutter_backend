import 'package:conduit_common/conduit_common.dart';
import 'package:conduit_core/conduit_core.dart';
// import 'package:qlutter_backend/controllers/user.dart';
import 'package:conduit_open_api/v3.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';
import 'package:intl/intl.dart';
import 'package:qlutter_backend/controllers/auth_controller.dart';
import 'package:qlutter_backend/controllers/level_comment.dart';
import 'package:qlutter_backend/controllers/level_controller.dart';
import 'package:qlutter_backend/controllers/room_controller.dart';
import 'package:qlutter_backend/controllers/token_controller.dart';
import 'package:qlutter_backend/controllers/user_controller.dart';
import 'package:qlutter_backend/controllers/user_progress_controller.dart';
import 'package:qlutter_backend/qlutter_backend.dart';

// import 'controllers/comment.dart';

class QlutterBackendChannel extends ApplicationChannel {
  late ManagedContext context;

  @override
  void documentComponents(APIDocumentContext registry) {
    super.documentComponents(registry);
    registry.schema.register(
      "Status",
      APISchemaObject.object(
        {
          "status": APISchemaObject.string(),
        },
      ),
    );
    registry.schema.register(
      "Error",
      APISchemaObject.object(
        {
          "error": APISchemaObject.string(),
        },
      ),
    );
    registry.schema.register(
      "Token",
      APISchemaObject.object(
        {
          "token": APISchemaObject.string(),
        },
      ),
    );
  }

  String dateToString(DateTime inputDate) {
    final outputFormat = DateFormat('MM/dd/yyyy HH:mm');
    final outputDate = outputFormat.format(inputDate);
    return '${outputDate}';
  }

  @override
  Future prepare() async {
    CORSPolicy.defaultPolicy.allowedOrigins = [
      "*", "172.20.20.4:8888", "0.0.0.0",
      "https://dart.nvavia.ru",
      // "localhost:8888",
    ];
    options?.address = "0.0.0.0";
    logger.onRecord.listen((rec) => print(
        "${rec} ${dateToString(rec.time)} ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistence = PostgreSQLPersistentStore(
        "admin", "root", "127.0.0.1", 5432, "postgres");
    context = ManagedContext(dataModel, persistence);
  }

  @override
  Controller get entryPoint {
    final router = Router()
      ..route("token/[:refresh]").link(
        () => AppAuthController(context),
      )
      ..route("/user")
          .link(() => TokenController())!
          .link(() => UserController(context))
      ..route("/levels").link(() => LevelController(context))
      ..route("/comment").link(() => LevelCommentController(context))
      ..route("/progress").link(() => UserProgressController(context))
      ..route("/best").link(() => BestProgressController(context))
      ..route('/rooms').link(() => RoomsController())
      ..route('/game').link(() => GameController());

    return router;
  }
}
