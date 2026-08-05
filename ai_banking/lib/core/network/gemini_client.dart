import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'env.dart';

part 'gemini_client.g.dart';

/// A custom HTTP client that correctly handles Google AI Studio API keys.
///
/// Both classic (AIzaSy...) and newer (AQ...) key formats are API keys —
/// they must be sent as `?key=` query parameters, NOT as Bearer tokens.
/// This client also strips the `x-goog-api-key` header that the SDK adds
/// to avoid duplicate/conflicting authentication headers.
class WebSafeHttpClient extends http.BaseClient {
  final String apiKey;
  final http.Client _inner = http.Client();

  WebSafeHttpClient(this.apiKey);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Always pass the API key as a query parameter (works for both AIzaSy and AQ keys).
    final uri = request.url.replace(
      queryParameters: {
        ...request.url.queryParameters,
        'key': apiKey,
      },
    );

    final newRequest = http.Request(request.method, uri)
      ..bodyBytes = (request as http.Request).bodyBytes;

    // Copy existing headers, then remove any conflicting auth headers.
    // The SDK may add x-goog-api-key or authorization — both must be stripped
    // since we're authenticating via the ?key= query parameter instead.
    newRequest.headers.addAll(request.headers);
    newRequest.headers.remove('x-goog-api-key');
    newRequest.headers.remove('authorization');

    final maskedUri = uri.toString().replaceRange(
      uri.toString().indexOf('key=') + 4,
      null,
      '***',
    );
    print('[GeminiAI] Requesting (v1beta) [ApiKey]: $maskedUri');

    return _inner.send(newRequest);
  }
}

@riverpod
GenerativeModel geminiClient(GeminiClientRef ref) {
  final key = Env.geminiApiKey;

  return GenerativeModel(
    model: 'gemini-2.0-flash-lite',
    apiKey: key,
    httpClient: WebSafeHttpClient(key),
    requestOptions: const RequestOptions(apiVersion: 'v1beta'),
  );
}
