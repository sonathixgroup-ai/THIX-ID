import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_player_page.dart';

// Couleurs
const Color kBackgroundColor = Color(0xFFFBFBFD);
const Color kAccentColor = Color(0xFF7A4DF3);
const Color kHeaderIconColor = Color(0xFF6A7788);

// Modèle de contenu média (identique à la structure de la table)
class MediaItem {
  final String id;
  final String title;
  final String? subtitle;
  final String type;
  final String? year;
  final String coverUrl;
  final String videoUrl;
  final int viewCount;
  final int? rankPosition; // pour les tendances

  MediaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.year,
    required this.coverUrl,
    required this.videoUrl,
    this.viewCount = 0,
    this.rankPosition,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      type: json['type'] ?? '',
      year: json['year'],
      coverUrl: json['cover_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      viewCount: json['view_count'] ?? 0,
      rankPosition: json['rank_position'],
    );
  }

  // Pour l'affichage du rang (#1, #2...)
  String get rankDisplay => rankPosition != null ? '#$rankPosition' : '';
}

class ThixMediaPage extends StatefulWidget {
  const ThixMediaPage({super.key});

  @override
  State<ThixMediaPage> createState() => _ThixMediaPageState();
}

class _ThixMediaPageState extends State<ThixMediaPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<MediaItem> _allMedia = [];
  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'Accueil';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      final response = await _supabase
          .from('media_contents')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false);
      if (response is List) {
        final items = response.map((json) => MediaItem.fromJson(json)).toList();
        setState(() {
          _allMedia = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Format de données invalide';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Filtrage selon la catégorie et la recherche
  List<MediaItem> get _filteredTrending {
    var list = _allMedia.where((item) => item.rankPosition != null).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  List<MediaItem> get _filteredRecommendations {
    var list = _allMedia.where((item) => item.rankPosition == null && item.type != 'Vidéo').toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  List<MediaItem> get _filteredNewReleases {
    var list = _allMedia.where((item) => item.year == '2024').toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  void _navigateToVideo(MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(title: item.title, videoUrl: item.videoUrl),
      ),
    );
  }

  void _showAll(String section) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voir tout : $section')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: Text('Erreur : $_error')),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'THIX MEDIA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: kAccentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Regardez. Écoutez. Vibrez.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Rechercher un film, une série...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.tune, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person_outline, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips de catégories
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _MediaChip(
                    label: 'Accueil',
                    selected: _selectedCategory == 'Accueil',
                    onTap: () => setState(() => _selectedCategory = 'Accueil'),
                  ),
                  _MediaChip(
                    label: 'Vidéos',
                    icon: Icons.video_library_outlined,
                    selected: _selectedCategory == 'Vidéos',
                    onTap: () => setState(() => _selectedCategory = 'Vidéos'),
                  ),
                  _MediaChip(
                    label: 'Films',
                    icon: Icons.movie_outlined,
                    selected: _selectedCategory == 'Films',
                    onTap: () => setState(() => _selectedCategory = 'Films'),
                  ),
                  _MediaChip(
                    label: 'Séries',
                    icon: Icons.tv_outlined,
                    selected: _selectedCategory == 'Séries',
                    onTap: () => setState(() => _selectedCategory = 'Séries'),
                  ),
                  _MediaChip(
                    label: 'Musique',
                    icon: Icons.music_note_outlined,
                    selected: _selectedCategory == 'Musique',
                    onTap: () => setState(() => _selectedCategory = 'Musique'),
                  ),
                  _MediaChip(
                    label: 'Playlists',
                    icon: Icons.playlist_play_outlined,
                    selected: _selectedCategory == 'Playlists',
                    onTap: () => setState(() => _selectedCategory = 'Playlists'),
                  ),
                  _MediaChip(
                    label: 'En direct',
                    icon: Icons.live_tv_outlined,
                    selected: _selectedCategory == 'En direct',
                    onTap: () => setState(() => _selectedCategory = 'En direct'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bannière (seulement pour Accueil)
            if (_selectedCategory == 'Accueil') ...[
              _buildFeatureBanner(),
              const SizedBox(height: 24),
            ],

            // Tendances (uniquement pour Accueil)
            if (_selectedCategory == 'Accueil') ...[
              const _SectionHeader(title: 'Tendances', showSeeAll: true, onSeeAll: () => _showAll('Tendances')),
              const SizedBox(height: 12),
              _TrendingList(
                items: _filteredTrending,
                onItemTap: _navigateToVideo,
              ),
              const SizedBox(height: 24),
            ],

            // Recommandations (selon catégorie)
            if (_selectedCategory == 'Accueil')
              const _SectionHeader(title: 'Recommandé pour vous', showSeeAll: true, onSeeAll: () => _showAll('Recommandations')),
            else
              _SectionHeader(
                title: 'Recommandations ($_selectedCategory)',
                showSeeAll: true,
                onSeeAll: () => _showAll('Recommandations'),
              ),
            const SizedBox(height: 12),
            _RecommendationGrid(
              items: _filteredRecommendations.where((item) => _selectedCategory == 'Accueil' || item.type == _selectedCategory).toList(),
              onItemTap: _navigateToVideo,
            ),
            const SizedBox(height: 24),

            // Bannière Premium (seulement pour Accueil)
            if (_selectedCategory == 'Accueil') ...[
              _buildPremiumBanner(),
              const SizedBox(height: 24),
            ],

            // Nouveautés (selon catégorie)
            if (_selectedCategory == 'Accueil')
              const _SectionHeader(title: 'Nouveautés', showSeeAll: true, onSeeAll: () => _showAll('Nouveautés')),
            else
              _SectionHeader(
                title: 'Nouveautés ($_selectedCategory)',
                showSeeAll: true,
                onSeeAll: () => _showAll('Nouveautés'),
              ),
            const SizedBox(height: 12),
            _NewReleasesGrid(
              items: _filteredNewReleases.where((item) => _selectedCategory == 'Accueil' || item.type == _selectedCategory).toList(),
              onItemTap: _navigateToVideo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBanner() {
    final heritageItem = _allMedia.firstWhere(
      (e) => e.title.contains('Héritage'),
      orElse: () => _allMedia.isNotEmpty ? _allMedia.first : null,
    );
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/id/20/800/400'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const Spacer(),
              _buildSliderDot(true),
              _buildSliderDot(false),
              _buildSliderDot(false),
              _buildSliderDot(false),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('NOUVEAUTÉ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "L’HÉRITAGE SAISON 1",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Une histoire. Un combat. Un héritage.",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (heritageItem != null) _navigateToVideo(heritageItem);
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Regarder maintenant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text('Ma liste', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/id/30/800/300'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('THIX MEDIA Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                SizedBox(height: 6),
                Text('Accédez à tout le contenu sans publicité,\ntéléchargez et regardez hors ligne.', style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kAccentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderDot(bool active) {
    return Container(
      width: active ? 16 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? kAccentColor : Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ==================== WIDGETS PRIVÉS (inchangés sauf l'utilisation de rankDisplay) ====================

class _MediaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  const _MediaChip({required this.label, this.selected = false, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kAccentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 16, color: selected ? Colors.white : kHeaderIconColor),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : kHeaderIconColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.showSeeAll = false, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5)),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: const [
                Text('Voir tout', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrendingList extends StatelessWidget {
  final List<MediaItem> items;
  final Function(MediaItem) onItemTap;
  const _TrendingList({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Aucune donnée pour les tendances.'));
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(image: NetworkImage(item.coverUrl), fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.rankDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${(item.viewCount / 1000).round()} k vues • il y a ${index + 2} jours', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationGrid extends StatelessWidget {
  final List<MediaItem> items;
  final Function(MediaItem) onItemTap;
  const _RecommendationGrid({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Aucune recommandation disponible.'));
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(image: NetworkImage(item.coverUrl), fit: BoxFit.cover),
                        ),
                      ),
                      if (item.year == '2024')
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('NOUVEAU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white)),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${item.type} • ${item.year ?? ''}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NewReleasesGrid extends StatelessWidget {
  final List<MediaItem> items;
  final Function(MediaItem) onItemTap;
  const _NewReleasesGrid({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Aucune nouveauté pour cette catégorie.'));
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: DecorationImage(image: NetworkImage(item.coverUrl), fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${item.type} • ${item.year ?? ''}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
