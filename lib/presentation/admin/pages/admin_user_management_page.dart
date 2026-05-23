import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thix_id/supabase/supabase_config.dart';
import 'package:thix_id/theme.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Primary: order by last_update if present.
      List<Map<String, dynamic>> res;
      try {
        res = await SupabaseService.select(
          'thix_public_profiles',
          select: 'id,user_id,display_name,avatar_url,identity_preview_url,last_update',
          orderBy: 'last_update',
          ascending: false,
          limit: 250,
        );
      } catch (e) {
        debugPrint('AdminUserManagementPage: last_update order failed, fallback err=$e');
        res = await SupabaseService.select(
          'thix_public_profiles',
          select: 'id,user_id,display_name,avatar_url,identity_preview_url,last_update',
          orderBy: 'id',
          ascending: false,
          limit: 250,
        );
      }
      if (!mounted) return;
      setState(() => _rows = res);
    } catch (e) {
      debugPrint('AdminUserManagementPage: fetch failed err=$e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _rows
        : _rows.where((r) {
            final display = (r['display_name'] ?? '').toString().toLowerCase();
            final userId = (r['user_id'] ?? '').toString().toLowerCase();
            final id = (r['id'] ?? '').toString().toLowerCase();
            return display.contains(q) || userId.contains(q) || id.contains(q);
          }).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(search: _search, onRefresh: _load, count: filtered.length),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : (_error != null)
                  ? _ErrorState(error: _error!, onRetry: _load)
                  : _UserList(rows: filtered),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController search;
  final VoidCallback onRefresh;
  final int count;
  const _Header({required this.search, required this.onRefresh, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Management', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AdminCyberColors.text)),
              const SizedBox(height: 4),
              Text('Source: thix_public_profiles • $count résultat(s)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim)),
            ],
          ),
        ),
        SizedBox(
          width: 320,
          child: TextField(
            controller: search,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.text),
            decoration: InputDecoration(
              hintText: 'Search users, UID, name…',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
              prefixIcon: const Icon(Icons.search_rounded, color: AdminCyberColors.neonCyan),
              filled: true,
              fillColor: AdminCyberColors.panel.withValues(alpha: 0.72),
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
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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

class _UserList extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  const _UserList({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Text('Aucun profil.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.textDim)),
      );
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _UserTile(row: rows[index]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> row;
  const _UserTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final displayName = (row['display_name'] ?? '—').toString().trim();
    final userId = (row['user_id'] ?? '').toString().trim();
    final avatarUrl = (row['avatar_url'] ?? '').toString().trim();
    final lastUpdate = (row['last_update'] ?? '').toString().trim();
    final identityPreview = (row['identity_preview_url'] ?? '').toString().trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AdminCyberColors.panel.withValues(alpha: 0.78),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          _Avatar(url: avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName.isEmpty ? '—' : displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AdminCyberColors.text)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _MetaChip(icon: Icons.person_rounded, label: userId.isEmpty ? 'user_id: —' : 'user_id: ${_ellipsis(userId, 16)}'),
                    if (lastUpdate.isNotEmpty) _MetaChip(icon: Icons.update_rounded, label: 'update: ${_ellipsis(lastUpdate, 20)}'),
                    if (identityPreview.isNotEmpty) _MetaChip(icon: Icons.badge_rounded, label: 'identity: ready'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (identityPreview.isNotEmpty)
            IconButton(
              tooltip: 'Preview identité',
              onPressed: () => _showIdentityPreview(context, identityPreview),
              icon: const Icon(Icons.open_in_new_rounded, color: AdminCyberColors.neonCyan),
            ),
        ],
      ),
    );
  }

  static String _ellipsis(String s, int max) => s.length <= max ? s : '${s.substring(0, max)}…';

  static Future<void> _showIdentityPreview(BuildContext context, String url) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                  Expanded(child: Text('Identity preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AdminCyberColors.text))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, color: AdminCyberColors.textDim)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text('Impossible de charger l’image.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminCyberColors.textDim)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(url, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim)),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminCyberColors.stroke.withValues(alpha: 0.9)),
        gradient: hasUrl ? null : AdminCyberGradients.glowBlue(),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Colors.white),
            )
          : const Icon(Icons.person_rounded, color: Colors.white),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

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
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AdminCyberColors.textDim)),
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
        constraints: const BoxConstraints(maxWidth: 720),
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
              Row(
                children: [
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vérifie aussi les RLS policies (thix_public_profiles) pour SUPER_ADMIN.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminCyberColors.textDim),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
