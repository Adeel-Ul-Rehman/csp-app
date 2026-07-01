// // lib/core/services/local/hive_service.dart
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:css_mastery_app/models/syllabus/day_model.dart';
// import 'package:css_mastery_app/models/user/user_model.dart';

// class HiveService {
//   static const String userBox = 'user_box';
//   static const String settingsBox = 'settings_box';
//   static const String progressBox = 'progress_box';
//   static const String cacheBox = 'cache_box';

//   static Future<void> init() async {
//     await Hive.initFlutter();
    
//     // Register adapters
//     Hive.registerAdapter(DayModelAdapter());
//     Hive.registerAdapter(UserModelAdapter());
//     Hive.registerAdapter(TopicModelAdapter());
//     Hive.registerAdapter(ProgressModelAdapter());
    
//     // Open boxes
//     await Hive.openBox<UserModel>(userBox);
//     await Hive.openBox<Map>(settingsBox);
//     await Hive.openBox<Map>(progressBox);
//     await Hive.openBox<Map>(cacheBox);
//   }

//   static Box<UserModel> getUserBox() => Hive.box<UserModel>(userBox);
//   static Box<Map> getSettingsBox() => Hive.box<Map>(settingsBox);
//   static Box<Map> getProgressBox() => Hive.box<Map>(progressBox);
//   static Box<Map> getCacheBox() => Hive.box<Map>(cacheBox);
// }