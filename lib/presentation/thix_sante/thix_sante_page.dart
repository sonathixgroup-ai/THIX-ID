import 'package:flutter/material.dart';

class ThixSantePage extends StatelessWidget {
  const ThixSantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========== EN-TÊTE ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'THIX ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'SANTÉ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00A896),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Votre santé, notre priorité.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _CompactIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                        hasBadge: true,
                      ),
                      const SizedBox(width: 8),
                      _CompactIconButton(
                        icon: Icons.person_outline_rounded,
                        onTap: () {},
                        hasBadge: false,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ========== BANNIÈRE HÉRO ==========
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052CC), Color(0xFF00A8E8), Color(0xFF00F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052CC).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(Icons.shield_outlined, size: 100, color: Colors.white.withOpacity(0.15)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bonjour, Daniel Mwana Longo 🎉',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Votre santé\nentre de bonnes mains',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Consultez, suivez et prenez soin de\nvotre santé au quotidien.',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9), height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0052CC),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.assignment_outlined, size: 16),
                              SizedBox(width: 6),
                              Text('Dossier de santé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios_rounded, size: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ========== ACTIONS RAPIDES (5 items) ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TinyActionItem(icon: Icons.calendar_today_rounded, label: 'Rendez-vous', color: const Color(0xFF2563EB)),
                  _TinyActionItem(icon: Icons.health_and_safety_outlined, label: 'Consultation', color: const Color(0xFF10B981)),
                  _TinyActionItem(icon: Icons.biotech_rounded, label: 'Examens', color: const Color(0xFF8B5CF6)),
                  _TinyActionItem(icon: Icons.medication_rounded, label: 'Ordonnances', color: const Color(0xFF1D4ED8)),
                  _TinyActionItem(icon: Icons.favorite_rounded, label: 'Urgences', color: const Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(height: 12),

              // ========== RÉSUMÉ DE SANTÉ (ultra compact) ==========
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.favorite_border_rounded, color: Color(0xFF10B981), size: 14),
                            SizedBox(width: 4),
                            Text('Résumé de santé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2), minimumSize: Size.zero),
                          child: const Row(
                            children: [
                              Text('Voir tout ', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600, fontSize: 9)),
                              Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Color(0xFF2563EB)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 2.2,
                      children: [
                        _MiniStatCard(title: 'Consultations', value: '12', subtitle: 'Cette année', color: const Color(0xFFEFF6FF), textColor: const Color(0xFF2563EB)),
                        _MiniStatCard(title: 'Examens', value: '7', subtitle: 'Complétés', color: const Color(0xFFECFDF5), textColor: const Color(0xFF10B981)),
                        _MiniStatCard(title: 'Médicaments', value: '3', subtitle: 'En cours', color: const Color(0xFFF5F3FF), textColor: const Color(0xFF8B5CF6)),
                        _MiniStatCard(title: 'Rendez-vous', value: '2', subtitle: 'À venir', color: const Color(0xFFFFF7ED), textColor: const Color(0xFFF97316)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ========== SERVICES RAPIDES (ultra compact, grille 2×4) ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bolt, color: Color(0xFF2563EB), size: 14),
                      SizedBox(width: 2),
                      Text('Services rapides', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2), minimumSize: Size.zero),
                    child: const Row(
                      children: [
                        Text('Voir tout ', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600, fontSize: 9)),
                        Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.9,
                children: [
                  _MiniServiceCard(
                    icon: Icons.person_search_rounded,
                    title: 'Consulter médecin',
                    bgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                  ),
                  _MiniServiceCard(
                    icon: Icons.add_box_rounded,
                    title: 'Dossier médical',
                    bgColor: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                  ),
                  _MiniServiceCard(
                    icon: Icons.science_outlined,
                    title: 'Résultats examens',
                    bgColor: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  _MiniServiceCard(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Mes ordonnances',
                    bgColor: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFF97316),
                  ),
                  _MiniServiceCard(
                    icon: Icons.domain_rounded,
                    title: 'Trouver hôpital',
                    bgColor: const Color(0xFFFFF1F0),
                    iconColor: const Color(0xFFEF4444),
                  ),
                  _MiniServiceCard(
                    icon: Icons.local_pharmacy_rounded,
                    title: 'Trouver médicament',
                    bgColor: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                  ),
                  _MiniServiceCard(
                    icon: Icons.storefront_rounded,
                    title: 'Pharmacies proches',
                    bgColor: const Color(0xFFE6F9F9),
                    iconColor: const Color(0xFF0891B2),
                  ),
                  _MiniServiceCard(
                    icon: Icons.emergency_rounded,
                    title: 'Urgences proches',
                    bgColor: const Color(0xFFFFF1F0),
                    iconColor: const Color(0xFFDC2626),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ========== BANNIÈRE URGENCE ==========
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.local_hospital_rounded, color: Color(0xFFEF4444), size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Besoin d’aide immédiate ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
                          Text('Contactez les urgences en un clic', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call, size: 12),
                      label: const Text('Appeler 15', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}

// ========== COMPOSANTS ULTRA COMPACTS ==========

class _CompactIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  const _CompactIconButton({required this.icon, required this.onTap, this.hasBadge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            icon: Icon(icon, color: const Color(0xFF1E293B), size: 18),
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
          ),
      ],
    );
  }
}

class _TinyActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TinyActionItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color color, textColor;
  const _MiniStatCard({required this.title, required this.value, required this.subtitle, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: textColor)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text(subtitle, style: const TextStyle(fontSize: 7, color: Color(0xFF94A3B8))),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(Icons.circle, size: 8, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _MiniServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color bgColor, iconColor;
  const _MiniServiceCard({required this.icon, required this.title, required this.bgColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
