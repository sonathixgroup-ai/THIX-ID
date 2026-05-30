import 'package:flutter/material.dart';

// Palette de couleurs optimisée
const Color kBackgroundColor = Color(0xFFF9F9FB);
const Color kAccentColor = Color(0xFF6C5DD3);
const Color kHeaderIconColor = Color(0xFF8E9AAF);

class ThixMediaPage extends StatelessWidget {
  const ThixMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildNavigationChips(),
            const SizedBox(height: 16),
            _buildBanner(), // Section "L'HÉRITAGE"
            const SizedBox(height: 16),
            _buildIconMenuGrid(), // Grille des catégories (Vidéos, Films, etc.)
            const SizedBox(height: 20),
            _buildSectionTitle('Tendances'),
            const SizedBox(height: 10),
            _buildHorizontalList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() => PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        children: [
          const Text('THIX MEDIA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kAccentColor)),
          const Spacer(),
          const Icon(Icons.notifications_none, size: 22, color: kHeaderIconColor),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
        ],
      ),
    ),
  );

  Widget _buildNavigationChips() => SizedBox(
    height: 35,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: const [
        _Chip(label: 'Accueil', selected: true),
        _Chip(label: 'Vidéos'),
        _Chip(label: 'Films'),
        _Chip(label: 'Séries'),
        _Chip(label: 'Musique'),
      ],
    ),
  );

  Widget _buildBanner() => Container(
    height: 180,
    decoration: BoxDecoration(color: Colors.indigo.shade300, borderRadius: BorderRadius.circular(16)),
    child: const Center(child: Text("Bannière L'Héritage", style: TextStyle(color: Colors.white))),
  );

  Widget _buildIconMenuGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 4,
    childAspectRatio: 0.9,
    children: const [
      _MenuIcon(icon: Icons.play_circle_fill, label: 'Vidéos'),
      _MenuIcon(icon: Icons.movie, label: 'Films'),
      _MenuIcon(icon: Icons.tv, label: 'Séries'),
      _MenuIcon(icon: Icons.music_note, label: 'Musique'),
      _MenuIcon(icon: Icons.sensors, label: 'Direct'),
      _MenuIcon(icon: Icons.grid_view, label: 'Genres'),
      _MenuIcon(icon: Icons.more_horiz, label: 'Plus'),
    ],
  );

  Widget _buildSectionTitle(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Text('Voir tout >', style: TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );

  Widget _buildHorizontalList() => SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: kAccentColor,
    unselectedItemColor: kHeaderIconColor,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Vidéos'),
      BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ],
  );
}

// Composants simplifiés
class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  const _Chip({required this.label, this.selected = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: selected ? kAccentColor : Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : kHeaderIconColor)),
  );
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuIcon({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 24, color: kAccentColor),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: kHeaderIconColor)),
  ]);
}
