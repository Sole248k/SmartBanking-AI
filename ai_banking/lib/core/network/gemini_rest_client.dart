import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'env.dart';

part 'gemini_rest_client.g.dart';

@riverpod
Dio geminiRestClient(GeminiRestClientRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': Env.geminiApiKey,
      },
      // Increase timeouts for AI responses
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // Add simple logging for development
  dio.interceptors.add(LogInterceptor(
    requestHeader: false,
    responseHeader: false,
    requestBody: true,
    responseBody: false,
  ));

  return dio;
}
