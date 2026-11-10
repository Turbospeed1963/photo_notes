import 'dart:typed_data';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart' as models;

// Fill these in from your Appwrite console.
const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
const String projectId = '6af255ec0025db6995b6';
const String databaseId = '6af25b220001e986c328';
const String collectionId = '6af25b3500107f51ba3d';
const String bucketId = '6af25b4a0028b8f5f2ce';

// The API key is NOT written here, so it never gets pushed to GitHub.
// Pass it when you run or build:
//   flutter run --dart-define=APPWRITE_API_KEY=your_key
const String apiKey = String.fromEnvironment('APPWRITE_API_KEY');

class AppwriteService {
  AppwriteService._();
  static final AppwriteService instance = AppwriteService._();

  final Client client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setKey(apiKey);

  late final Databases databases = Databases(client);
  late final Storage storage = Storage(client);

  // ---------- Notes ----------

  Future<models.Document> createNote({
    required String title,
    String content = '',
    String? photoId,
  }) {
    return databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: {
        'title': title,
        'content': content,
        if (photoId != null) 'photoId': photoId,
        'isFavorite': false,
      },
    );
  }

  Future<List<models.Document>> listNotes() async {
    final res = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [Query.orderDesc('\$createdAt')],
    );
    return res.documents;
  }

  Future<void> deleteNote(String noteId) async {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: noteId,
    );
  }

  // ---------- Photos ----------

  /// Uploads a photo and returns its file ID.
  Future<String> uploadPhoto(String filePath) async {
    final file = await storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: filePath),
    );
    return file.$id;
  }

  /// Downloads a small preview of a photo (use with Image.memory).
  Future<Uint8List> photoPreview(String fileId) {
    return storage.getFilePreview(
      bucketId: bucketId,
      fileId: fileId,
      width: 600,
    );
  }
}
