import 'package:conduit_core/conduit_core.dart';
import 'package:qlutter_backend/channel.dart';

Future main() async {
  final app = Application<QlutterBackendChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  await app.start(
      numberOfInstances: 3, consoleLogging: true); // startOnCurrentIsolate();

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
