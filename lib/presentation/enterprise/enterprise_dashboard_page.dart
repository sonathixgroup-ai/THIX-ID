import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/presentation/common/notifications_sheet.dart';
import 'package:thix_id/presentation/common/thix_identity_sheets.dart';
import 'package:thix_id/services/thix_id_service.dart';
import '../../theme.dart';

class DashboardStat extends StatelessWidget {
  final IconData icon;
  final String trend;
  final String value;
  final String label;

  const DashboardStat({
    super.key,
    required this.icon,
    required this.trend,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3D62).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: context.theme.colorScheme.primary, size: 22),
                ),
                Text(
                  trend,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: LightModeColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textStyles.bodySmall?.copyWith(
                color: LightModeColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final String photoDesc;
  final String name;
  final String thixId;
  final bool isVerified;
  final String docs;
  final bool selected;

  const CandidateCard({
    super.key,
    required this.photoDesc,
    required this.name,
    required this.thixId,
    required this.isVerified,
    required this.docs,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isVerified ? LightModeColors.accent : context.theme.dividerColor, width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: LightModeColors.background,
                  child: Icon(Icons.person, color: LightModeColors.hint),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          const Icon(Icons.verified, color: LightModeColors.accent, size: 16),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "ID: $thixId",
                      style: context.textStyles.labelSmall?.copyWith(
                        color: LightModeColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: context.theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search, size: 16, color: context.theme.colorScheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "Voir Profil",
                        style: context.textStyles.labelMedium?.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: LightModeColors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF0A2F5C)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "Écrire",
                        style: context.textStyles.labelMedium?.copyWith(
                          color: const Color(0xFF0A2F5C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (val) {},
                    activeColor: context.theme.colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    "Sélectionner",
                    style: context.textStyles.bodySmall?.copyWith(color: context.theme.colorScheme.onSurface),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.description, size: 14, color: LightModeColors.hint),
                  const SizedBox(width: 4),
                  Text(
                    "$docs Docs",
                    style: context.textStyles.labelSmall?.copyWith(
                      color: LightModeColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavTab extends StatelessWidget {
  final String label;
  final bool active;

  const NavTab({
    super.key,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? LightModeColors.accent : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        label,
        style: context.textStyles.labelLarge?.copyWith(
          color: active ? LightModeColors.accent : Colors.white.withValues(alpha: 0.69),
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

class EnterpriseDashboardPage extends StatelessWidget {
  const EnterpriseDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthController>().currentUser;
    if (me == null) {
      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: Center(child: Text('Connexion requise', style: context.textStyles.titleMedium?.copyWith(color: Colors.white))),
      );
    }

    // Hard-guard: never show Enterprise dashboard for Personal accounts.
    if (me.accountType == AccountType.personal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(AppRoutes.userDashboard);
      });
      return const SizedBox.shrink();
    }
    final companyName = me.displayName;
    final thixId = me.thixId;
    final isActivated = me.hasRealThixId;
    final hasActiveTrial = me.hasActiveTrial;
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: context.theme.colorScheme.primary,
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: LightModeColors.accent,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.business, color: context.theme.colorScheme.primary, size: 32),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    companyName,
                                    style: context.textStyles.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                     decoration: BoxDecoration(
                                       color: isActivated ? LightModeColors.success : LightModeColors.accent,
                                       borderRadius: BorderRadius.circular(AppRadius.full),
                                     ),
                                     child: Text(
                                       isActivated ? 'VÉRIFIÉE' : 'EN ATTENTE',
                                       style: context.textStyles.labelSmall?.copyWith(color: const Color(0xFF0A2F5C)),
                                     ),
                                   ),
                                ],
                              ),
                              Text(
                                thixId.isEmpty ? '—' : thixId,
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => ThixIdentitySheets.showVerifySheet(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_rounded, color: Colors.white),
                            onPressed: () => context.push(AppRoutes.settings),
                          ),
                          Badge(
                            label: const Text('3'),
                            backgroundColor: LightModeColors.accent,
                            textColor: const Color(0xFF0A2F5C),
                            child: IconButton(
                              icon: const Icon(Icons.chat_rounded, color: Colors.white),
                              onPressed: () => context.push(AppRoutes.chat),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: LightModeColors.accent, width: 2),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: LightModeColors.hint),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        NavTab(label: "Vue d'ensemble", active: false),
                        NavTab(label: "Candidats", active: true),
                        NavTab(label: "Offres d'Emploi", active: false),
                        NavTab(label: "Messages", active: false),
                        NavTab(label: "Analytiques", active: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isActivated && !hasActiveTrial) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: LightModeColors.accent.withValues(alpha: 0.35)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [LightModeColors.accent, Color(0xFFE5B13A)]),
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.verified_rounded, color: Color(0xFF0A2F5C)),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Activation requise', style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Votre compte entreprise est créé. Activez pour obtenir votre THIX ID officiel et débloquer les espaces protégés.',
                                        style: context.textStyles.bodySmall?.copyWith(color: LightModeColors.secondaryText, height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: LightModeColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: LightModeColors.accent.withValues(alpha: 0.22)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0A2F5C)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Paiement fictif (simulation) : aucune API réelle n\'est utilisée pour le moment.',
                                      style: context.textStyles.bodySmall?.copyWith(color: const Color(0xFF0A2F5C), fontWeight: FontWeight.w700, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final receiptReturn = Uri.encodeComponent(AppRoutes.activationReceipt);
                                  context.go('${AppRoutes.payment}?returnTo=$receiptReturn');
                                },
                                icon: const Icon(Icons.payments_rounded, color: Color(0xFF0A2F5C)),
                                label: Text('Activer (paiement fictif)', style: context.textStyles.labelLarge?.copyWith(color: const Color(0xFF0A2F5C), fontWeight: FontWeight.w900)),
                                style: ElevatedButton.styleFrom(backgroundColor: LightModeColors.accent, foregroundColor: const Color(0xFF0A2F5C), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: LightModeColors.accent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "3 Candidats Sélectionnés",
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "Actions groupées disponibles",
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: LightModeColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.send_rounded, color: Color(0xFF0A2F5C)),
                                label: const Text("Message Groupé"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LightModeColors.accent,
                                  foregroundColor: const Color(0xFF0A2F5C),
                                  textStyle: context.textStyles.labelMedium,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: LightModeColors.error),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Gestion des Postulants",
                          style: context.textStyles.headlineMedium?.copyWith(
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.filter_list),
                              label: const Text("Filtres"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.theme.colorScheme.primary,
                                side: BorderSide(color: context.theme.colorScheme.primary),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.sort),
                              label: const Text("Trier"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.theme.colorScheme.primary,
                                side: BorderSide(color: context.theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "Pipeline de Recrutement",
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 320,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "NOUVEAUX",
                                      style: context.textStyles.labelLarge?.copyWith(
                                        color: LightModeColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: context.theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Text(
                                        "14",
                                        style: context.textStyles.labelSmall?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const CandidateCard(name: "Jean-Paul Mukendi", thixId: "TX-9928", photoDesc: "congolese man", isVerified: true, docs: "5", selected: false),
                                const CandidateCard(name: "Sarah Kabamba", thixId: "TX-4410", photoDesc: "african woman", isVerified: true, docs: "3", selected: true),
                                const CandidateCard(name: "Idriss Luvumbu", thixId: "TX-2291", photoDesc: "young african man", isVerified: false, docs: "2", selected: false),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Container(
                            width: 320,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ENTRETIEN",
                                      style: context.textStyles.labelLarge?.copyWith(
                                        color: LightModeColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: LightModeColors.accent,
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Text(
                                        "5",
                                        style: context.textStyles.labelSmall?.copyWith(color: const Color(0xFF0A2F5C)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const CandidateCard(name: "Marc Zola", thixId: "TX-1102", photoDesc: "man portrait", isVerified: true, docs: "8", selected: true),
                                const CandidateCard(name: "Arlette Itula", thixId: "TX-8832", photoDesc: "smiling woman", isVerified: true, docs: "4", selected: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Container(
                            width: 320,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "OFFRE",
                                      style: context.textStyles.labelLarge?.copyWith(
                                        color: LightModeColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: LightModeColors.success,
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Text(
                                        "2",
                                        style: context.textStyles.labelSmall?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const CandidateCard(name: "Felix Mwamba", thixId: "TX-0041", photoDesc: "senior man", isVerified: true, docs: "12", selected: false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: context.theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vérifier un Candidat via THIX ID",
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Builder(
                            builder: (context) {
                              final thixId = ValueNotifier<String>('');
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (v) => thixId.value = v,
                                      decoration: InputDecoration(
                                        hintText: "Entrez le THIX ID (ex: ${ThixIdService.exampleV2})",
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  ElevatedButton(
                                    onPressed: () => ThixIdentitySheets.showVerifySheet(context, initialUidOrThixId: thixId.value.trim()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    ),
                                    child: const Text("Vérifier Profil"),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
}