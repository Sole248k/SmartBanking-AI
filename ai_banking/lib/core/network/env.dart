import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static final String geminiApiKey = _Env.geminiApiKey;

  @EnviedField(varName: 'GROQ_API_KEY', obfuscate: true)
  static final String groqApiKey = _Env.groqApiKey;

  @EnviedField(varName: 'FIREBASE_WEB_API_KEY', obfuscate: true)
  static final String firebaseWebApiKey = _Env.firebaseWebApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY', obfuscate: true)
  static final String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_API_KEY', obfuscate: true)
  static final String firebaseIosApiKey = _Env.firebaseIosApiKey;

  @EnviedField(varName: 'FIREBASE_MACOS_API_KEY', obfuscate: true)
  static final String firebaseMacosApiKey = _Env.firebaseMacosApiKey;

  @EnviedField(varName: 'FIREBASE_WINDOWS_API_KEY', obfuscate: true)
  static final String firebaseWindowsApiKey = _Env.firebaseWindowsApiKey;
}
