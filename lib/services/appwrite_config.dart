import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Client? _client;

// One shared client for the whole app, so the login session is shared too
Client getClient() {
  return _client ??= Client()
      .setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
      .setProject(dotenv.env['APPWRITE_PROJECT_ID']!);
}