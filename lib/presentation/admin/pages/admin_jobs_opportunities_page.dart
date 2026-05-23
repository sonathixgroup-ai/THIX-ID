import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thix_id/supabase/supabase_config.dart';
import 'package:thix_id/theme.dart';

class AdminJobsOpportunitiesPage extends StatefulWidget {
  const AdminJobsOpportunitiesPage({super.key});

  @override
  State<AdminJobsOpportunitiesPage> createState() => _AdminJobsOpportunitiesPageState();
}

class _AdminJobsOpportunitiesPageState extends State<AdminJobsOpportunitiesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _opps = const [];
  int _tab = 0; // 0=jobs, 1=opportunities
  bool _loggedFabDebug = false;

  bool get _forceFabForSona {
    final email = SupabaseConfig.currentUser?.email?.trim().toLowerCase();
    return email == 'sonathixgroup@gmail.com';
  }

  bool get _shouldShowFab {
    // The FAB was reported as not visible on mobile web.
    // We keep it enabled for everyone by default, and explicitly force it for this account.
    final email = SupabaseConfig.currentUser?.email?.trim().toLowerCase();
    if (_forceFabForSona) return true;
    // If we later re-introduce RBAC gating per module, keep SUPER_ADMIN/admin here.
    return email != null && email.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // NOTE: thix_job_offers may not exist in generated types yet; we query dynamically.
      final res = await SupabaseService.select(
        'thix_job_offers',
        select: '*',
        orderBy: 'created_at',
        ascending: false,
        limit: 200,
      );
      final oppRes = await SupabaseService.select(
        'thix_opportunities',
        select: '*',
        orderBy: 'created_at',
        ascending: false,
        limit: 200,
      );
      if (!mounted) return;
      setState(() {
        _offers = res;
        _opps = oppRes;
      });
    } catch (e) {
      debugPrint('AdminJobsOpportunitiesPage: fetch failed err=$e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createOffer() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateOfferSheet(),
    );
    if (created == true) await _load();
  }

  Future<void> _createOpportunity() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateOpportunitySheet(),
    );
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isJobs = _tab == 0;

    // Debug visibility (helps validate in Dreamflow logs).
    if (!_loggedFabDebug) {
      _loggedFabDebug = true;
      debugPrint(
        'AdminJobsOpportunitiesPage: email=${SupabaseConfig.currentUser?.email} showFab=$_shouldShowFab forceFab=$_forceFabForSona tab=$_tab',
      );
    }

    // Use an inner Scaffold to ensure the FAB is laid out correctly on all breakpoints.
    // (Positioned in a Stack can end up off-screen on mobile web due to padding / browser UI.)
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            tab: _tab,
            onTabChanged: (v) => setState(() => _tab = v),
            onRefresh: _load,
            count: isJobs ? _offers.length : _opps.length,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : (_error != null)
                    ? _ErrorState(error: _error!, onRetry: _load)
                    : (isJobs ? _OffersList(items: _offers) : _OpportunitiesList(items: _opps)),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: !_shouldShowFab
          ? null
          : SafeArea(
              minimum: const EdgeInsets.only(right: 6, bottom: 6),
              child: FloatingActionButton.extended(
                heroTag: isJobs ? 'create_offer_fab' : 'create_opportunity_fab',
                backgroundColor: AdminCyberColors.electricBlue,
                foregroundColor: Colors.white,
                onPressed: isJobs ? _createOffer : _createOpportunity,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(isJobs ? 'Créer une offre' : 'Créer une opportunité'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  final int count;
  final int tab;
  final ValueChanged<int> onTabChanged;
  const _Header({required this.onRefresh, required this.count, required this.tab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final isJobs = tab == 0;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jobs & Opportunities', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AdminCyberColors.text)),
              const SizedBox(height: 4),
              Text(
                isJobs ? 'Source: thix_job_offers • $count offre(s)' : 'Source: thix_opportunities • $count opportunité(s)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
              ),
              const SizedBox(height: 10),
              _Tabs(tab: tab, onChanged: onTabChanged),
            ],
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
            foregroundColor: AdminCyberColors.text,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, color: AdminCyberColors.neonCyan),
          label: const Text('Fetch Data'),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip({required String label, required int value, required IconData icon}) {
      final selected = tab == value;
      return InkWell(
        onTap: () => onChanged(value),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? AdminCyberColors.neonCyan.withValues(alpha: 0.16) : AdminCyberColors.black.withValues(alpha: 0.18),
            border: Border.all(color: selected ? AdminCyberColors.neonCyan.withValues(alpha: 0.55) : AdminCyberColors.stroke.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? AdminCyberColors.neonCyan : AdminCyberColors.textDim),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AdminCyberColors.text, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        chip(label: 'Offres', value: 0, icon: Icons.work_rounded),
        chip(label: 'Opportunités', value: 1, icon: Icons.auto_awesome_rounded),
      ],
    );
  }
}

class _OpportunitiesList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _OpportunitiesList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('Aucune opportunité pour le moment.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.textDim)));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _OpportunityTile(row: items[index]),
    );
  }
}

class _OpportunityTile extends StatelessWidget {
  final Map<String, dynamic> row;
  const _OpportunityTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final id = row['id']?.toString();
    final title = _OfferTile._pick(row, const ['title', 'name']) ?? '—';
    final organizer = _OfferTile._pick(row, const ['organizer', 'organization', 'company']) ?? '';
    final category = _OfferTile._pick(row, const ['category', 'type']) ?? '';
    final status = _OfferTile._pick(row, const ['status', 'state']) ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AdminCyberColors.panel.withValues(alpha: 0.78),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: AdminCyberGradients.glowBlue(),
              boxShadow: [BoxShadow(color: AdminCyberColors.neonCyan.withValues(alpha: 0.14), blurRadius: 18, spreadRadius: 2)],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AdminCyberColors.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (status.trim().isNotEmpty) _StatusPill(status: status),
                    if (id != null && id.trim().isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _StatusMenu(table: 'thix_opportunities', id: id, current: status),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (organizer.trim().isNotEmpty) _Meta(icon: Icons.apartment_rounded, text: organizer),
                    if (category.trim().isNotEmpty) _Meta(icon: Icons.sell_rounded, text: category),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateOpportunitySheet extends StatefulWidget {
  const _CreateOpportunitySheet();

  @override
  State<_CreateOpportunitySheet> createState() => _CreateOpportunitySheetState();
}

class _CreateOpportunitySheetState extends State<_CreateOpportunitySheet> {
  final _title = TextEditingController();
  final _organizer = TextEditingController();
  final _location = TextEditingController();
  final _category = TextEditingController(text: 'Bourse');
  final _reward = TextEditingController();
  final _deadlineLabel = TextEditingController();
  final _applyUrl = TextEditingController();
  final _description = TextEditingController();
  String _status = 'pending';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _organizer.dispose();
    _location.dispose();
    _category.dispose();
    _reward.dispose();
    _deadlineLabel.dispose();
    _applyUrl.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Le titre est obligatoire.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = <String, dynamic>{
        'title': title,
        if (_organizer.text.trim().isNotEmpty) 'organizer': _organizer.text.trim(),
        if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
        'category': _category.text.trim().isEmpty ? 'Opportunité' : _category.text.trim(),
        if (_reward.text.trim().isNotEmpty) 'reward_label': _reward.text.trim(),
        if (_deadlineLabel.text.trim().isNotEmpty) 'deadline_label': _deadlineLabel.text.trim(),
        if (_applyUrl.text.trim().isNotEmpty) 'apply_url': _applyUrl.text.trim(),
        if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
        'status': _status,
      };
      await SupabaseService.insert('thix_opportunities', payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('CreateOpportunitySheet: insert failed err=$e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
          color: AdminCyberColors.panel.withValues(alpha: 0.92),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Créer une opportunité', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AdminCyberColors.text))),
                IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close_rounded, color: AdminCyberColors.textDim)),
              ],
            ),
            const SizedBox(height: 10),
            _Field(controller: _title, label: 'Titre *', icon: Icons.auto_awesome_rounded),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Field(controller: _organizer, label: 'Organisateur', icon: Icons.apartment_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Field(controller: _location, label: 'Lieu', icon: Icons.place_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Field(controller: _category, label: 'Catégorie', icon: Icons.sell_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Field(controller: _reward, label: 'Récompense', icon: Icons.card_giftcard_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Field(controller: _deadlineLabel, label: 'Deadline label', icon: Icons.schedule_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Field(controller: _applyUrl, label: 'Lien candidature', icon: Icons.link_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            _Field(controller: _description, label: 'Description', icon: Icons.subject_rounded, maxLines: 4),
            const SizedBox(height: 10),
            _StatusPicker(value: _status, onChanged: (v) => setState(() => _status = v)),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.danger)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AdminCyberColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.publish_rounded, color: Colors.white),
                label: const Text('Publier'),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Table attendue: thix_opportunities. Si insert/select bloque: vérifie RLS + colonnes NOT NULL.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _OffersList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('Aucune offre pour le moment.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.textDim)),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _OfferTile(row: items[index]),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final Map<String, dynamic> row;
  const _OfferTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final id = row['id']?.toString();
    final title = _pick(row, const ['title', 'position', 'job_title', 'name']) ?? '—';
    final company = _pick(row, const ['company', 'employer', 'organization']) ?? '';
    final location = _pick(row, const ['location', 'city', 'address']) ?? '';
    final status = _pick(row, const ['status', 'state']) ?? '';
    final createdAt = _pick(row, const ['created_at', 'createdAt']) ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AdminCyberColors.panel.withValues(alpha: 0.78),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: AdminCyberGradients.glowViolet(),
              boxShadow: [BoxShadow(color: AdminCyberColors.neonViolet.withValues(alpha: 0.14), blurRadius: 18, spreadRadius: 2)],
            ),
            child: const Icon(Icons.work_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AdminCyberColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (status.trim().isNotEmpty) _StatusPill(status: status),
                    if (id != null && id.trim().isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _StatusMenu(
                        table: 'thix_job_offers',
                        id: id,
                        current: status,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (company.trim().isNotEmpty) _Meta(icon: Icons.apartment_rounded, text: company),
                    if (location.trim().isNotEmpty) _Meta(icon: Icons.place_rounded, text: location),
                    if (createdAt.trim().isNotEmpty) _Meta(icon: Icons.schedule_rounded, text: _ellipsis(createdAt, 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _pick(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static String _ellipsis(String s, int max) => s.length <= max ? s : '${s.substring(0, max)}…';
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AdminCyberColors.black.withValues(alpha: 0.22),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminCyberColors.textDim),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AdminCyberColors.textDim)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    final Color c;
    if (s.contains('approve') || s.contains('valid') || s.contains('verified')) {
      c = AdminCyberColors.success;
    } else if (s.contains('reject') || s.contains('denied')) {
      c = AdminCyberColors.danger;
    } else {
      c = AdminCyberColors.neonCyan;
    }
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.9)),
        color: c.withValues(alpha: 0.12),
      ),
      child: Text(status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AdminCyberColors.text)),
    );
  }
}

class _StatusMenu extends StatefulWidget {
  final String table;
  final String id;
  final String current;
  const _StatusMenu({required this.table, required this.id, required this.current});

  @override
  State<_StatusMenu> createState() => _StatusMenuState();
}

class _StatusMenuState extends State<_StatusMenu> {
  bool _loading = false;

  Future<void> _set(String status) async {
    setState(() => _loading = true);
    try {
      await SupabaseService.update(widget.table, {'status': status}, filters: {'id': widget.id});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Statut mis à jour: $status')));
    } catch (e) {
      debugPrint('StatusMenu: update failed table=${widget.table} id=${widget.id} err=$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Modifier le statut',
      enabled: !_loading,
      icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AdminCyberColors.neonCyan)) : const Icon(Icons.more_horiz_rounded, color: AdminCyberColors.textDim),
      onSelected: _set,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'pending', child: Text('En attente')),
        PopupMenuItem(value: 'approved', child: Text('Approuver')),
        PopupMenuItem(value: 'rejected', child: Text('Rejeter')),
      ],
    );
  }
}

class _CreateOfferSheet extends StatefulWidget {
  const _CreateOfferSheet();

  @override
  State<_CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<_CreateOfferSheet> {
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  String _status = 'pending';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Le titre est obligatoire.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final payload = <String, dynamic>{
        // Best-effort columns (adapt if your schema differs)
        'title': title,
        if (_company.text.trim().isNotEmpty) 'company': _company.text.trim(),
        if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
        if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
        'status': _status,
      };
      await SupabaseService.insert('thix_job_offers', payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('CreateOfferSheet: insert failed err=$e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
          color: AdminCyberColors.panel.withValues(alpha: 0.92),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Créer une offre', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AdminCyberColors.text))),
                IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close_rounded, color: AdminCyberColors.textDim)),
              ],
            ),
            const SizedBox(height: 10),
            _Field(controller: _title, label: 'Titre *', icon: Icons.badge_rounded),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Field(controller: _company, label: 'Entreprise', icon: Icons.apartment_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Field(controller: _location, label: 'Lieu', icon: Icons.place_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            _Field(controller: _description, label: 'Description', icon: Icons.subject_rounded, maxLines: 4),
            const SizedBox(height: 10),
            _StatusPicker(value: _status, onChanged: (v) => setState(() => _status = v)),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.danger)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AdminCyberColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                label: const Text('Publier'),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Note: si ta table thix_job_offers impose d’autres colonnes obligatoires, Supabase retournera une erreur ici (à adapter à ton schéma).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  const _Field({required this.controller, required this.label, required this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
        prefixIcon: Icon(icon, color: AdminCyberColors.neonCyan),
        filled: true,
        fillColor: AdminCyberColors.black.withValues(alpha: 0.22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdminCyberColors.electricBlue, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _StatusPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AdminCyberColors.black.withValues(alpha: 0.22),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AdminCyberColors.neonCyan, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text('Statut', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim))),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AdminCyberColors.panel,
              iconEnabledColor: AdminCyberColors.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.text),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('En attente')),
                DropdownMenuItem(value: 'approved', child: Text('Approuvée')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejetée')),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
            color: AdminCyberColors.panel.withValues(alpha: 0.78),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Supabase error', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AdminCyberColors.text)),
              const SizedBox(height: 8),
              Text(error, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim, height: 1.4)),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
                  foregroundColor: AdminCyberColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, color: AdminCyberColors.neonCyan),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              Text(
                'Si tu es SUPER_ADMIN mais que ça bloque: vérifie les RLS policies sur thix_job_offers (select/insert) et assure-toi que la table existe.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
