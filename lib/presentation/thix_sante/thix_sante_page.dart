import 'package:flutter/material.dart';

class ThixSantePage extends StatelessWidget {
  const ThixSantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Fond légèrement gris clair
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========== EN-TÊTE ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, color: Colors.blue, size: 36),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "THIX SANTÉ",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "Votre santé, notre priorité.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _CompactIconButton(
                        icon: Icons.notifications_none,
                        onTap: () {},
                        hasBadge: true,
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ========== BANNIÈRE HÉRO ==========
              Container(
                height: 220,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF135EF2), Color(0xFF1FD6C1)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bonjour, Michel 👋",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Votre santé\nentre de bonnes mains",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Consultez, suivez et prenez soin de votre santé au quotidien.",
                            style: TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.folder),
                            label: const Text("Dossier de santé"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Image.network(
                        "https://img.freepik.com/free-photo/doctor.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ========== MENU RAPIDE (5 icônes) ==========
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _QuickIcon(Icons.calendar_month, "Rendez-vous"),
                    _QuickIcon(Icons.medical_services, "Consultation"),
                    _QuickIcon(Icons.science, "Examens"),
                    _QuickIcon(Icons.medication, "Ordonnances"),
                    _QuickIcon(Icons.favorite, "Urgences"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ========== RÉSUMÉ DE SANTÉ ==========
              sectionTitle("Résumé de santé"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: const [
                    Expanded(child: _StatCard(title: "Consultations", value: "12")),
                    SizedBox(width: 10),
                    Expanded(child: _StatCard(title: "Examens", value: "7")),
                    SizedBox(width: 10),
                    Expanded(child: _StatCard(title: "Médicaments", value: "3")),
                    SizedBox(width: 10),
                    Expanded(child: _StatCard(title: "RDV", value: "2")),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ========== SERVICES RAPIDES (grille 2×4) ==========
              sectionTitle("Services rapides"),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  _ServiceTile(icon: Icons.person, title: "Consulter un médecin"),
                  _ServiceTile(icon: Icons.folder_open, title: "Dossier médical"),
                  _ServiceTile(icon: Icons.science, title: "Résultats examens"),
                  _ServiceTile(icon: Icons.medication, title: "Mes ordonnances"),
                  _ServiceTile(icon: Icons.local_hospital, title: "Trouver un hôpital"),
                  _ServiceTile(icon: Icons.local_pharmacy, title: "Pharmacies proches"),
                  _ServiceTile(icon: Icons.favorite, title: "Urgences proches"),
                  _ServiceTile(icon: Icons.smart_toy, title: "Conseils santé IA"),
                ],
              ),
              const SizedBox(height: 24),

              // ========== BANNIÈRE URGENCE ==========
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          color: Color(0xFFEF4444), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Besoin d’aide immédiate ?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Contactez les urgences en un clic",
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text("Appeler 15",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Text(
            "Voir tout",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== COMPOSANTS RÉUTILISABLES ==========

class _CompactIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  const _CompactIconButton(
      {required this.icon, required this.onTap, this.hasBadge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            icon: Icon(icon, color: const Color(0xFF1E293B), size: 22),
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickIcon extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickIcon(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.blue, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ServiceTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
