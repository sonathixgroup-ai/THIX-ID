// ==================== THIX MEDIA PAGE (version complète) ====================
import 'package:flutter/material.dart';

class ThixMediaPage extends StatelessWidget {
  const ThixMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'THIX MEDIA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un film, une série, un artiste...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.tune, size: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation horizontale
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _MediaChip(label: 'Accueil', selected: true),
                  _MediaChip(label: 'Vidéos'),
                  _MediaChip(label: 'Films'),
                  _MediaChip(label: 'Séries'),
                  _MediaChip(label: 'Musique'),
                  _MediaChip(label: 'Playlists'),
                  _MediaChip(label: 'En direct', icon: Icons.live_tv),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bannière Nouveauté
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A2E6B), Color(0xFF134BC5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('NOUVEAUTÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "L’HÉRITAGE SAISON 1",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Une histoire. Un combat. Un héritage.",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Regarder maintenant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Ma liste'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tendance
            const _SectionHeader(title: 'Tendance'),
            const SizedBox(height: 12),
            const _TrendingList(),
            const SizedBox(height: 24),

            // Recommandé pour vous
            const _SectionHeader(title: 'Recommandé pour vous', seeAll: true),
            const SizedBox(height: 12),
            const _RecommendationGrid(),
            const SizedBox(height: 24),

            // Premium banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('THIX MEDIA Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Accédez à tout le contenu sans publicité, téléchargez et regardez hors ligne.', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    child: const Text('Passer Premium'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nouveautés
            const _SectionHeader(title: 'Nouveautés', seeAll: true),
            const SizedBox(height: 12),
            const _NewReleasesList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Téléchargements'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

// ========== COMPOSANTS RÉUTILISABLES ==========

class _MediaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  const _MediaChip({required this.label, this.selected = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF475569),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool seeAll;
  const _SectionHeader({required this.title, this.seeAll = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        if (seeAll) const Text('Voir tout >', style: TextStyle(fontSize: 12, color: Colors.blue)),
      ],
    );
  }
}

class _TrendingList extends StatelessWidget {
  const _TrendingList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> trending = [
      {'rank': '#1', 'title': 'Fally l’upa – Amore', 'artist': 'Fally l’upa Officiel', 'views': '1,2 M vues • il y a 2 jours'},
      {'rank': '#2', 'title': 'Innoss’B – Yo Pe', 'artist': 'Innoss’B Officiel', 'views': '980 k vues • il y a 3 jours'},
      {'rank': '#3', 'title': 'Héritage – Épisode 1', 'artist': 'THIX Originals', 'views': '850 k vues • il y a 1 jour'},
      {'rank': '#4', 'title': 'Résumé : RDC vs Maroc', 'artist': 'THIX Sports', 'views': '650 k vues • il y a 5 jours'},
    ];

    return Column(
      children: trending.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 32, child: Text(item['rank'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey))),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(item['artist'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(item['views'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recos = [
      {'title': 'INNOSS’B – Yo Pe', 'type': 'Musique • 2024'},
      {'title': 'Black Flag', 'type': 'Action • 2023'},
      {'title': 'Coeur battant', 'type': 'Drame • 2024'},
      {'title': 'Le Dernier Combat', 'type': 'Film • 2022'},
      {'title': 'Rêves d’Afrique', 'type': 'Documentaire • 2023'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recos.length,
      itemBuilder: (context, index) {
        final item = recos[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Icon(Icons.play_circle_filled, color: Colors.blue)),
              ),
              const SizedBox(height: 6),
              Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(item['type']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}

class _NewReleasesList extends StatelessWidget {
  const _NewReleasesList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> newReleases = [
      {'title': 'Le prix du silence', 'type': 'Film • 2024'},
      {'title': 'Dance Challenge', 'type': 'Vidéo • 2024'},
      {'title': 'Horizon', 'type': 'Série • Saison 2'},
      {'title': 'Énergie', 'type': 'Musique • 2024'},
    ];

    return Column(
      children: newReleases.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(width: 60, height: 40, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(item['type']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_outline, color: Colors.blue),
            ],
          ),
        );
      }).toList(),
    );
  }
}
