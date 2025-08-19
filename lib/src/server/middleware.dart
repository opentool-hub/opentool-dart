import 'package:shelf/shelf.dart';

/// Check 'Authorization' header against a list of valid API keys
Middleware checkAuthorization(List<String> validApiKeys) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authorizationHeader = request.headers['Authorization'];
      const tokenPrefix = "Bearer ";

      if (authorizationHeader == null ||
          !authorizationHeader.startsWith(tokenPrefix)) {
        return Response.unauthorized('Missing or malformed authorization header');
      }

      final token = authorizationHeader.substring(tokenPrefix.length);

      if (!validApiKeys.contains(token)) {
        return Response.unauthorized('Invalid authorization token');
      }

      return innerHandler(request);
    };
  };
}