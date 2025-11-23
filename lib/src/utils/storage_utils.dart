import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';

class StorageUtils {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localMoviesFile async {
    final path = await _localPath;
    return File('$path/movies.json');
  }

  static Future<File> get _localSeriesFile async {
    final path = await _localPath;
    return File('$path/series.json');
  }

  static Future<File> get _localFavoritesFile async {
    final path = await _localPath;
    return File('$path/favorites.json');
  }

  // Save a single movie to storage
  static Future<void> saveMovie(MediaItem movie) async {
    try {
      // Clear all existing movie data first
      await clearAllMovies();

      final file = await _localMoviesFile;
      final jsonString = jsonEncode(movie.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      // Handle error silently or log it
      print('Error saving movie: $e');
    }
  }

  // Load a movie from storage
  static Future<MediaItem?> loadMovie() async {
    try {
      final file = await _localMoviesFile;
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return MediaItem.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      // Handle error silently or log it
      print('Error loading movie: $e');
      return null;
    }
  }

  // Clear all movies from storage
  static Future<void> clearAllMovies() async {
    try {
      final file = await _localMoviesFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error clearing movies: $e');
    }
  }

  // Save a single series to storage
  static Future<void> saveSeries(MediaItem series) async {
    try {
      // Clear all existing series data first
      await clearAllSeries();

      final file = await _localSeriesFile;
      final jsonString = jsonEncode(series.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      // Handle error silently or log it
      print('Error saving series: $e');
    }
  }

  // Load a series from storage
  static Future<MediaItem?> loadSeries() async {
    try {
      final file = await _localSeriesFile;
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return MediaItem.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      // Handle error silently or log it
      print('Error loading series: $e');
      return null;
    }
  }

  // Clear all series from storage
  static Future<void> clearAllSeries() async {
    try {
      final file = await _localSeriesFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error clearing series: $e');
    }
  }

  // Add a media item to favorites
  static Future<void> addToFavorites(MediaItem mediaItem) async {
    try {
      final favorites = await loadFavorites();
      // Check if item already exists
      final existingIndex = favorites.indexWhere((item) => item.id == mediaItem.id && item.type == mediaItem.type);
      if (existingIndex == -1) {
        favorites.add(mediaItem);
      }
      await _saveFavorites(favorites);
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Remove a media item from favorites
  static Future<void> removeFromFavorites(int id, String type) async {
    try {
      final favorites = await loadFavorites();
      favorites.removeWhere((item) => item.id == id && item.type == type);
      await _saveFavorites(favorites);
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Load all favorites
  static Future<List<MediaItem>> loadFavorites() async {
    try {
      final file = await _localFavoritesFile;
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonArray = jsonDecode(jsonString) as List<dynamic>;
        return jsonArray.map((item) => MediaItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  // Clear all favorites
  static Future<void> clearAllFavorites() async {
    try {
      final file = await _localFavoritesFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // Save favorites to file
  static Future<void> _saveFavorites(List<MediaItem> favorites) async {
    try {
      final file = await _localFavoritesFile;
      final jsonString = jsonEncode(favorites.map((item) => item.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Check if a media item is in favorites
  static Future<bool> isFavorite(int id, String type) async {
    try {
      final favorites = await loadFavorites();
      return favorites.any((item) => item.id == id && item.type == type);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}

bool containsFarsiOrArabic(String text) {
  final farsiArabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  return farsiArabicRegex.hasMatch(text);
}