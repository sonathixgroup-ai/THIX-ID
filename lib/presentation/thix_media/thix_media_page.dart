import 'package:flutter/material.dart';

// Color constants from the provided image
const Color kBackgroundColor = Color(0xFFFBFBFD); // Off-white/very light gray
const Color kAccentColor = Color(0xFF7A4DF3);     // Purple/Violet (used for active states and banners)
const Color kHeaderIconColor = Color(0xFF6A7788);  // Gray for unselected icons

class ThixMediaPage extends StatelessWidget {
  const ThixMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Completely redesigned AppBar to include logo, search, notifications, and profile
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
                  // Logo + Slogan
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
                  // Search bar (now in the appBar and wider)
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
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
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
                  // Notifications + Profile
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
                    backgroundColor: Colors.grey, // Placeholder
                    child: Icon(Icons.person_outline, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Use SingleChildScrollView for vertical scrolling, but specific sections handle horizontal scrolling
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation Chips (purple when active)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: const [
                  _MediaChip(label: 'Accueil', selected: true),
                  _MediaChip(label: 'Vidéos', icon: Icons.video_library_outlined),
                  _MediaChip(label: 'Films', icon: Icons.movie_outlined),
                  _MediaChip(label: 'Séries', icon: Icons.tv_outlined),
                  _MediaChip(label: 'Musique', icon: Icons.music_note_outlined),
                  _MediaChip(label: 'Playlists', icon: Icons.playlist_play_outlined),
                  _MediaChip(label: 'En direct', icon: Icons.live_tv_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Redesigned Feature Banner ("L’HÉRITAGE")
            // This is just a styled container now, as requested. For a real app,
            // this would contain a PageView with the proper image background.
            Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/banner_image.png'), // Need to add image asset
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Slider dot indicator
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
                  // Feature content
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
                              onPressed: () {},
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
            ),
            const SizedBox(height: 24),

            // Horizontal scrolling sections
            const _SectionHeader(title: 'Tendances', showSeeAll: true),
            const SizedBox(height: 12),
            const _TrendingList(),

            const SizedBox(height: 24),

            const _SectionHeader(title: 'Recommandé pour vous', showSeeAll: true),
            const SizedBox(height: 12),
            const _RecommendationGrid(),

            const SizedBox(height: 24),

            // Redesigned Premium Banner
            Container(
              height: 130,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/premium_banner.png'), // Need asset image
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
            ),
            const SizedBox(height: 24),

            // Changed from Column to horizontal scrolling grid/list
            const _SectionHeader(title: 'Nouveautés', showSeeAll: true),
            const SizedBox(height: 12),
            const _NewReleasesGrid(),
          ],
        ),
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

// Composants réutilisables

class _MediaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;

  const _MediaChip({required this.label, this.selected = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;

  const _SectionHeader({required this.title, this.showSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5)),
        if (showSeeAll)
          Row(
            children: const [
              Text('Voir tout', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
      ],
    );
  }
}

class _TrendingList extends StatelessWidget {
  const _TrendingList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> trending = [
      {'rank': '#1', 'title': 'Fally l’upa – Amore', 'artist': 'Fally l’upa Officiel', 'views': '1,2 M vues', 'time': '• il y a 2 jours', 'cover': 'assets/trend1.png'},
      {'rank': '#2', 'title': 'Innoss’B – Yo Pe', 'artist': 'Innoss’B Officiel', 'views': '980 k vues', 'time': '• il y a 3 jours', 'cover': 'assets/trend2.png'},
      {'rank': '#3', 'title': 'Héritage – Épisode 1', 'artist': 'THIX Originals', 'views': '850 k vues', 'time': '• il y a 1 jour', 'cover': 'assets/trend3.png'},
      {'rank': '#4', 'title': 'Résumé : RDC vs Maroc', 'artist': 'THIX Sports', 'views': '650 k vues', 'time': '• il y a 5 jours', 'cover': 'assets/trend4.png'},
    ];

    return SizedBox(
      height: 130, // Taller for ranked number over image
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: trending.length,
        itemBuilder: (context, index) {
          final item = trending[index];
          return Container(
            width: 140, // Wider cards
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
                      decoration: const BoxDecoration(
                        color: Colors.grey, // Placeholder
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(image: AssetImage('assets/placeholder.png'), fit: BoxFit.cover), // Need images
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item['rank'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${item['views']} ${item['time']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid();

  @override
  Widget build(BuildContext context) {
    // The design is a list that shows a grid of thumbnails, not a strict grid.
    final List<Map<String, String>> recos = [
      {'title': 'INNOSS’B – Yo Pe', 'type': 'Musique', 'year': '• 2024', 'tag': 'NOUVEAU', 'cover': 'assets/reco1.png'},
      {'title': 'Black Flag', 'type': 'Action', 'year': '• 2023', 'cover': 'assets/reco2.png'},
      {'title': 'Coeur battant', 'type': 'Drame', 'year': '• 2024', 'tag': 'SÉRIE', 'cover': 'assets/reco3.png'},
      {'title': 'Le Dernier Combat', 'type': 'Film', 'year': '• 2022', 'cover': 'assets/reco4.png'},
      {'title': 'Rêves d’Afrique', 'type': 'Documentaire', 'year': '• 2023', 'cover': 'assets/reco5.png'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recos.length,
        itemBuilder: (context, index) {
          final item = recos[index];
          return Container(
            width: 130, // Specific width
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
                      height: 120, // Tall thumbnail
                      decoration: const BoxDecoration(
                        color: Colors.grey, // Placeholder
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(image: AssetImage('assets/placeholder.png'), fit: BoxFit.cover), // Need images
                      ),
                    ),
                    if (item['tag'] != null)
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item['tag']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white)),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${item['type']} ${item['year']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Replaced _NewReleasesList (Vertical) with _NewReleasesGrid (Horizontal)
class _NewReleasesGrid extends StatelessWidget {
  const _NewReleasesGrid();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> newReleases = [
      {'title': 'Le prix du silence', 'type': 'Film', 'year': '• 2024', 'cover': 'assets/new1.png'},
      {'title': 'Dance Challenge', 'type': 'Vidéo', 'year': '• 2024', 'cover': 'assets/new2.png'},
      {'title': 'Horizon', 'type': 'Série', 'year': '• Saison 2', 'cover': 'assets/new3.png'},
      {'title': 'Énergie', 'type': 'Musique', 'year': '• 2024', 'cover': 'assets/new4.png'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: newReleases.length,
        itemBuilder: (context, index) {
          final item = newReleases[index];
          return Container(
            width: 130, // Specific width
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
                  height: 120, // Tall thumbnail
                  decoration: const BoxDecoration(
                    color: Colors.grey, // Placeholder
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(image: AssetImage('assets/placeholder.png'), fit: BoxFit.cover), // Need images
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${item['type']} ${item['year']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
