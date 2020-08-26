
import 'package:get_it/get_it.dart';
import 'package:pfa_project_cloudhpc/services/aute_repo.dart';
import 'package:pfa_project_cloudhpc/services/storage_repo.dart';
import 'package:pfa_project_cloudhpc/views/user_controller.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerSingleton<AuthRepo>(AuthRepo());
  locator.registerSingleton<StorageRepo>(StorageRepo());
  locator.registerSingleton<UserController>(UserController());
}
