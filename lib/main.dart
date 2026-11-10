import 'package:flutter/material.dart';

import 'add_note_page.dart';
import 'notes_list.dart';

void main() => runApp(const PhotoNotesApp());

// Colors
const kInk = Color(0xFF12151C); // page background
const kSurface = Color(0xFF1B2030); // drawer, cards
const kAccent = Color(0xFF7FD1C0); // buttons, selected item
const kText = Color(0xFFE6E8EE);
const kMuted = Color(0xFF8B93A7);

class PhotoNotesApp extends StatelessWidget {
  const PhotoNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kAccent,
      brightness: Brightness.dark,
    ).copyWith(surface: kSurface, primary: kAccent, onPrimary: kInk);

    return MaterialApp(
      title: 'Photo Notes',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: kInk,
        appBarTheme: const AppBarTheme(
          backgroundColor: kInk,
          foregroundColor: kText,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: kSurface),
      ),
      home: const HomePage(),
    );
  }
}

class MenuItem {
  final String label;
  final IconData icon;
  const MenuItem(this.label, this.icon);
}

const menuItems = [
  MenuItem('All notes', Icons.photo_library_outlined),
  MenuItem('Favorites', Icons.favorite_border),
  MenuItem('Settings', Icons.settings_outlined),
  MenuItem('About', Icons.info_outline),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  int _refresh = 0; // changes after a note is saved, to reload the list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuItems[selected].label),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search notes',
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Photo Notes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
              ),
              for (int i = 0; i < menuItems.length; i++)
                ListTile(
                  leading: Icon(
                    menuItems[i].icon,
                    color: i == selected ? kAccent : kMuted,
                  ),
                  title: Text(
                    menuItems[i].label,
                    style: TextStyle(color: i == selected ? kAccent : kText),
                  ),
                  selected: i == selected,
                  onTap: () {
                    setState(() => selected = i);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
      body: selected == 0
          ? NotesList(key: ValueKey(_refresh))
          : Center(
              child: Text(
                menuItems[selected].label,
                style: const TextStyle(color: kMuted),
              ),
            ),
      floatingActionButton: selected == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final saved = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNotePage()),
                );
                if (saved == true) setState(() => _refresh++);
              },
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add note'),
            )
          : null,
    );
  }
}

class EmptyNotes extends StatelessWidget {
  const EmptyNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_outlined, size: 56, color: kMuted),
            SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: kText),
            ),
            SizedBox(height: 8),
            Text(
              'Tap Add note to attach a photo and write your first note.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}
