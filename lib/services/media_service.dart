import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_content.dart';

class MediaService {
  final SupabaseClient _supabase;

  MediaService(this._supabase);

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

  Future<void> insert(MediaContent item) async {
    await _supabase.from('media_contents').insert(item.toJson());
  }

  Future<void> update(MediaContent item) async {
    await _supabase.from('media_contents').update(item.toJson()).eq('id', item.id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('media_contents').delete().eq('id', id);
  }
}
