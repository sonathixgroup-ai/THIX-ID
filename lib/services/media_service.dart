import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_content.dart';

class MediaService {
  final SupabaseClient _supabase;

  MediaService(this._supabase);

  // ==================== MÉTHODES PUBLIQUES (page THIX MEDIA) ====================

  Future<List<MediaContent>> fetchPublishedMedia() async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .eq('is_published', true)
        .order('created_at', ascending: false);
    if (response is List) {
      return response.map((json) => MediaContent.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MediaContent>> fetchTrending() async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .eq('is_published', true)
        .eq('is_trending', true)
        .order('rank_position', ascending: true);
    if (response is List) {
      return response.map((json) => MediaContent.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MediaContent>> fetchNewReleases() async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .eq('is_published', true)
        .eq('is_new_release', true)
        .order('created_at', ascending: false);
    if (response is List) {
      return response.map((json) => MediaContent.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MediaContent>> fetchRecommendations() async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .eq('is_published', true)
        .eq('is_recommended', true)
        .order('created_at', ascending: false);
    if (response is List) {
      return response.map((json) => MediaContent.fromJson(json)).toList();
    }
    return [];
  }

  Future<MediaContent?> fetchById(String id) async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (response != null) {
      return MediaContent.fromJson(response);
    }
    return null;
  }

  // ==================== MÉTHODES D'ADMINISTRATION ====================

  /// Récupère tous les médias (publiés et non publiés) pour l'admin
  Future<List<MediaContent>> fetchAllMedia() async {
    final response = await _supabase
        .from('media_contents')
        .select('*')
        .order('created_at', ascending: false);
    if (response is List) {
      return response.map((json) => MediaContent.fromJson(json)).toList();
    }
    return [];
  }

  /// Insère un nouveau média (sans gestion d'upload de fichiers)
  Future<void> insert(MediaContent item) async {
    await _supabase.from('media_contents').insert(item.toJson());
  }

  /// Met à jour un média existant
  Future<void> update(MediaContent item) async {
    await _supabase.from('media_contents').update(item.toJson()).eq('id', item.id);
  }

  /// Supprime un média (option : supprime aussi les fichiers associés dans Storage)
  Future<void> deleteMedia(MediaContent item) async {
    // 1. Supprimer les fichiers dans Storage (si les URL pointent vers Supabase)
    try {
      if (item.coverUrl.contains('supabase.co')) {
        final coverPath = _extractStoragePath(item.coverUrl);
        if (coverPath != null) {
          await _supabase.storage.from('media_covers').remove([coverPath]);
        }
      }
      if (item.videoUrl.contains('supabase.co')) {
        final videoPath = _extractStoragePath(item.videoUrl);
        if (videoPath != null) {
          await _supabase.storage.from('media_videos').remove([videoPath]);
        }
      }
    } catch (e) {
      // Ignorer les erreurs de suppression de fichiers
      print('Erreur suppression fichiers: $e');
    }
    // 2. Supprimer l'entrée dans la base
    await _supabase.from('media_contents').delete().eq('id', item.id);
  }

  // ==================== OUTILS PRIVÉS ====================

  /// Extrait le chemin d'un fichier à partir de son URL publique Supabase
  String? _extractStoragePath(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    // Exemple : /storage/v1/object/public/media_covers/covers/123.jpg
    final publicIndex = segments.indexOf('public');
    if (publicIndex != -1 && publicIndex + 2 < segments.length) {
      // On ignore 'public' et le nom du bucket
      return segments.sublist(publicIndex + 2).join('/');
    }
    return null;
  }
}
