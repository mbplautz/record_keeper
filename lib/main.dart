// lib/main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db/app_database.dart';
import 'providers/saved_search_provider.dart';
import 'repositories/album_repository.dart';
import 'repositories/saved_search_repository.dart';
import 'repositories/sqlite/saved_search_repository_impl.dart';
import 'repositories/track_repository.dart';
import 'repositories/tag_repository.dart';
import 'repositories/sqlite/album_repository_impl.dart';
import 'repositories/sqlite/track_repository_impl.dart';
import 'repositories/sqlite/tag_repository_impl.dart';
import 'providers/album_provider.dart';
import 'providers/track_provider.dart';
import 'providers/tag_provider.dart';
import 'views/main_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database instance
  
  // ✅ Platform-specific initialization
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // On mobile (Android/iOS), sqflite initializes automatically
  }
  final appDatabase = AppDatabase();

  // Create repository instances (inject the database)
  final albumRepository = AlbumRepositoryImpl(appDatabase);
  final trackRepository = TrackRepositoryImpl(appDatabase);
  final tagRepository = TagRepositoryImpl(appDatabase);
  final savedSearchRepository = SavedSearchRepositoryImpl(appDatabase);

  runApp(MyApp(
    albumRepository: albumRepository,
    trackRepository: trackRepository,
    tagRepository: tagRepository,
    savedSearchRepository: savedSearchRepository,
    appDatabase: appDatabase,
  ));
}

class MyApp extends StatelessWidget {
  final AlbumRepository albumRepository;
  final TrackRepository trackRepository;
  final TagRepository tagRepository;
  final SavedSearchRepository savedSearchRepository;
  final AppDatabase appDatabase;

  const MyApp({
    super.key,
    required this.albumRepository,
    required this.trackRepository,
    required this.tagRepository,
    required this.savedSearchRepository,
    required this.appDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AlbumProvider(albumRepository, trackRepository, tagRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TrackProvider(trackRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TagProvider(tagRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SavedSearchProvider(savedSearchRepository),
        ),
        Provider<AppDatabase>.value(value: appDatabase),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Record Keeper',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainScreenView(),
      ),
    );
  }
}
