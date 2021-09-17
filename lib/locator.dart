import 'package:get_it/get_it.dart';
import 'package:suhu_tubuh/core/service.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';
import 'package:suhu_tubuh/viewmodel/user_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // load type api
   locator.registerLazySingleton(() => Services());

// // load view model;
  locator.registerFactory(() => UserModel());
  locator.registerFactory(() => DashBoardModel());
//   locator.registerFactory(() => AdminModel());
}
