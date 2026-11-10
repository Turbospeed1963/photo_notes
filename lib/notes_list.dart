import 'dart:typed_data';

import 'package:dart_appwrite/models.dart' as models;
import 'package:flutter/material.dart';

import 'appwrite_service.dart';
import 'main.dart' show kSurface, kMuted, kText, EmptyNotes;

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late Future<List<models.Document>> _future =
      AppwriteService.instance.listNotes();

  Future<void> _reload() async {
    final f = AppwriteService.instance.listNotes();
    setState(() => _future = f);
    try {
      await f;
    } catch (_) {}
  }

  Future<void> _confirmDelete(models.Document doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text('The note will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AppwriteService.instance.deleteNote(doc.$id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<models.Document>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Could not load your notes. Check your connection and Appwrite settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kMuted),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final notes = snapshot.data ?? [];
        if (notes.isEmpty) return const EmptyNotes();

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => NoteCard(
              key: ValueKey(notes[i].$id),
              doc: notes[i],
              onDelete: () => _confirmDelete(notes[i]),
            ),
          ),
        );
      },
    );
  }
}

class NoteCard extends StatefulWidget {
  final models.Document doc;
  final VoidCallback onDelete;
  const NoteCard({super.key, required this.doc, required this.onDelete});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  Future<Uint8List>? _photo;

  @override
  void initState() {
    super.initState();
    final photoId = widget.doc.data['photoId'];
    if (photoId is String && photoId.isNotEmpty) {
      _photo = AppwriteService.instance.photoPreview(photoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data;
    final title = (data['title'] ?? '') as String;
    final content = (data['content'] ?? '') as String;
    final date = widget.doc.$createdAt.split('T').first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: kSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_photo != null)
              FutureBuilder<Uint8List>(
                future: _photo,
                builder: (context, snap) {
                  if (snap.hasData) {
                    return Image.memory(
                      snap.data!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: snap.hasError
                          ? const Icon(Icons.broken_image_outlined,
                              color: kMuted)
                          : const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: kText,
                          ),
                        ),
                        if (content.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: kText),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          date,
                          style: const TextStyle(color: kMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: kMuted),
                    tooltip: 'Delete note',
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
