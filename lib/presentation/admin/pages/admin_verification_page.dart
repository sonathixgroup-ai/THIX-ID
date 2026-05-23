import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thix_id/services/admin_verification_service.dart';
import 'package:thix_id/services/verification_status.dart';
import 'package:thix_id/theme.dart';

class AdminVerificationPage extends StatefulWidget {
  const AdminVerificationPage({super.key});

  @override
  State<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends State<AdminVerificationPage> {
  final _svc = AdminVerificationService();
  bool _loading = true;
  String? _error;
  List<VerificationQueueItem> _items = const [];

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
      final list = await _svc.fetchQueue();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      debugPrint('AdminVerificationPage: load failed err=$e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(VerificationQueueItem item, VerificationStatus status) async {
    try {
      await _svc.setStatus(item: item, status: status);
      if (!mounted) return;
      setState(() => _items = _items.where((i) => i != item).toList(growable: false));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == VerificationStatus.verified ? 'Vérifié.' : 'Rejeté.')));
    } catch (e) {
      debugPrint('AdminVerificationPage: setStatus failed err=$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action impossible: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vérification', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Queue “En attente” (formations • cursus • expériences • identité nationale).', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('Rafraîchir', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.18)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full))),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70))))
          else if (_items.isEmpty)
            Expanded(child: Center(child: Text('Aucun élément en attente.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _QueueCard(
                  item: _items[i],
                  onVerify: () => _setStatus(_items[i], VerificationStatus.verified),
                  onReject: () => _setStatus(_items[i], VerificationStatus.rejected),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final VerificationQueueItem item;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  const _QueueCard({required this.item, required this.onVerify, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIdentity = item.table == AdminVerificationService.profilesTable;
    final bd = Colors.white.withValues(alpha: 0.12);
    final bg = Colors.white.withValues(alpha: 0.06);
    String short(String v) => v.trim().isEmpty ? '—' : (v.length > 52 ? '${v.substring(0, 52)}…' : v);

    final subtitle = isIdentity ? 'Identité nationale • user=${item.userId}' : '${item.table} • id=${item.linkedRowId} • user=${item.userId}';
    final details = <String>[];
    if (!isIdentity) {
      final t = (item.payload['type'] ?? '').toString();
      final org = (item.payload['organized_by'] ?? item.payload['organizer'] ?? item.payload['company'] ?? '').toString();
      if (t.trim().isNotEmpty) details.add('Type: $t');
      if (org.trim().isNotEmpty) details.add('Org: $org');
    } else {
      final num = (item.payload['national_id_number'] ?? '').toString();
      final docType = (item.payload['id_document_type'] ?? '').toString();
      if (docType.trim().isNotEmpty) details.add('Type: $docType');
      if (num.trim().isNotEmpty) details.add('Numéro: $num');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: bd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(short(item.title), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                child: Text('En attente', style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange.shade100, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details.map((d) => _Chip(label: d)).toList(growable: false),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onVerify,
                  icon: const Icon(Icons.verified_rounded, color: Colors.white),
                  label: const Text('Vérifier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.block_rounded, color: Colors.white),
                  label: const Text('Rejeter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.18)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
    );
  }
}
