// ============================================================================
// FICHIER: lib/presentation/events/event_ticket_page.dart
// Version corrigée avec AppColors et AppConstants
// ============================================================================
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/models/event_registration.dart';
import 'package:thix_id/services/event_service.dart';

// ============================================================================
// CONSTANTES (à placer dans un fichier séparé normalement)
// ============================================================================
class AppConstants {
  static const String appName = 'THIX';
  static const String ticketPrefix = 'THIX-EVT';
  static const double coverImageHeight = 280;
  static const double footerHeight = 100;
  static const double buttonWidth = 180;
  static const double defaultPadding = 20;
  static const double smallPadding = 12;
  static const double borderRadius = 12;
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);  // Violet THIX
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

// ============================================================================
// MODÈLE POUR L'AFFICHAGE DU TICKET
// ============================================================================
class TicketDisplayData {
  final String ticketCode;
  final String thixCode;
  final EventItem event;
  final EventRegistration registration;
  final DateTime purchaseDate;
  final String attendeeName;
  final String attendeeEmail;
  final String? qrData;
  final String? barcodeData;

  TicketDisplayData({
    required this.ticketCode,
    required this.thixCode,
    required this.event,
    required this.registration,
    required this.purchaseDate,
    required this.attendeeName,
    required this.attendeeEmail,
    this.qrData,
    this.barcodeData,
  });

  String get formattedPrice => '${registration.totalPrice.toStringAsFixed(0)} ${registration.currency ?? 'FCFA'}';
  String get formattedDate => DateFormat('dd MMM yyyy • HH:mm').format(event.eventDate);
  String get formattedPurchaseDate => DateFormat('dd/MM/yyyy à HH:mm').format(purchaseDate);
  String get maskedTicketCode => '****${ticketCode.substring(ticketCode.length - 4)}';
}

// ============================================================================
// CONTROLLER
// ============================================================================
class EventTicketController extends ChangeNotifier {
  final EventService _eventService;
  
  TicketDisplayData? _ticketData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSavingToWallet = false;
  bool _isSharing = false;

  EventTicketController({
    required EventService eventService,
  }) : _eventService = eventService;

  TicketDisplayData? get ticketData => _ticketData;
  bool get isLoading => _isLoading;
  bool get isSavingToWallet => _isSavingToWallet;
  bool get isSharing => _isSharing;
  String? get errorMessage => _errorMessage;

  Future<void> loadTicket(String registrationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final registration = await _eventService.getRegistrationById(registrationId);
      if (registration == null) {
        throw Exception('Billet introuvable');
      }

      final event = await _eventService.getEventById(registration.eventId);
      if (event == null) {
        throw Exception('Événement introuvable');
      }

      _ticketData = TicketDisplayData(
        ticketCode: registration.ticketCode,
        thixCode: registration.thixCode ?? _generateThixCode(registration),
        event: event,
        registration: registration,
        purchaseDate: registration.createdAt ?? DateTime.now(),
        attendeeName: registration.attendeeName ?? 'Participant',
        attendeeEmail: registration.attendeeEmail ?? 'email@exemple.com',
        qrData: _generateQRData(registration, event),
        barcodeData: _generateBarcodeData(registration),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateThixCode(EventRegistration registration) {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'THIX-${registration.ticketCode.substring(0, 8)}-$timestamp';
  }

  String _generateQRData(EventRegistration registration, EventItem event) {
    return _jsonEncode({
      'ticket_id': registration.id,
      'ticket_code': registration.ticketCode,
      'event_id': event.id,
      'event_name': event.title,
      'attendee': registration.attendeeName,
      'date': event.eventDate.toIso8601String(),
      'verified': false,
    });
  }

  String _generateBarcodeData(EventRegistration registration) {
    return registration.ticketCode;
  }

  String _jsonEncode(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}:${e.value}').join('|');
  }

  Future<void> saveToWallet() async {
    _isSavingToWallet = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        throw Exception('Fonctionnalité disponible uniquement sur mobile');
      }
      await Future.delayed(const Duration(seconds: 1));
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isSavingToWallet = false;
      notifyListeners();
    }
  }

  Future<void> shareTicket(BuildContext context) async {
    _isSharing = true;
    notifyListeners();

    try {
      final ticketData = _ticketData;
      if (ticketData == null) return;

      final String shareText = '''
🎫 ${ticketData.event.title}
━━━━━━━━━━━━━━━━━━━━━
Code: ${ticketData.ticketCode}
📅 ${ticketData.formattedDate}
📍 ${ticketData.event.venue}
👤 ${ticketData.attendeeName}
💳 ${ticketData.formattedPrice}
━━━━━━━━━━━━━━━━━━━━━
Scannez ce code à l'entrée
THIX - Vivez l'exceptionnel
      ''';

      await Share.share(shareText);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      _isSharing = false;
      notifyListeners();
    }
  }

  Future<void> downloadTicket() async {
    debugPrint('Download ticket - À implémenter');
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ============================================================================
// PAGE PRINCIPALE
// ============================================================================
class EventTicketPage extends StatefulWidget {
  final String eventId;
  final String registrationId;
  final bool showBackButton;

  const EventTicketPage({
    super.key,
    required this.eventId,
    required this.registrationId,
    this.showBackButton = true,
  });

  @override
  State<EventTicketPage> createState() => _EventTicketPageState();
}

class _EventTicketPageState extends State<EventTicketPage>
    with SingleTickerProviderStateMixin {
  late EventTicketController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = EventTicketController(
      eventService: EventService(Supabase.instance.client),
    );
    _controller.loadTicket(widget.registrationId);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return _buildLoadingState();
          }
          
          if (_controller.errorMessage != null) {
            return _buildErrorState();
          }
          
          if (_controller.ticketData == null) {
            return _buildEmptyState();
          }
          
          return _buildTicketContent();
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (!widget.showBackButton) return null;
    
    return AppBar(
      title: const Text('Mon billet'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textDark,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _controller.isSharing ? null : () => _controller.shareTicket(context),
          tooltip: 'Partager',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreMenu(),
          tooltip: 'Plus',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement de votre billet...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _controller.errorMessage!,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _controller.loadTicket(widget.registrationId),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Aucun billet trouvé'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTicketCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 16),
              _buildEventInfoCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    final ticket = _controller.ticketData!;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header avec gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.qr_code, color: Colors.white, size: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.ticketCode.substring(0, 8),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ticket.event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.formattedDate,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Corps du billet
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        BarcodeWidget(
                          barcode: Barcode.qrCode(),
                          data: ticket.qrData ?? ticket.ticketCode,
                          width: 180,
                          height: 180,
                          drawText: false,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scannez ce code à l\'entrée',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Code barre
                  if (!kIsWeb) ...[
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: ticket.barcodeData ?? ticket.ticketCode,
                      width: double.infinity,
                      height: 50,
                      drawText: false,
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Code textuel
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      ticket.ticketCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  // Informations participant
                  _buildInfoRow(
                    Icons.person_outline,
                    'Participant',
                    ticket.attendeeName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.email_outline,
                    'Email',
                    ticket.attendeeEmail,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.confirmation_number_outlined,
                    'Code THIX',
                    ticket.thixCode,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.receipt_outlined,
                    'Prix',
                    ticket.formattedPrice,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Acheté le',
                    ticket.formattedPurchaseDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Télécharger',
            onPressed: () => _controller.downloadTicket(),
            color: Colors.grey[700]!,
          ),
        ),
        const SizedBox(width: 12),
        if (!kIsWeb)
          Expanded(
            child: _buildActionButton(
              icon: Icons.wallet_outlined,
              label: 'Ajouter au portefeuille',
              onPressed: _controller.isSavingToWallet
                  ? null
                  : () async {
                      try {
                        await _controller.saveToWallet();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Billet ajouté au portefeuille'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              color: AppColors.primary,
            ),
          ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.calendar_month_outlined,
            label: 'Ajouter au calendrier',
            onPressed: () => _addToCalendar(),
            color: Colors.grey[700]!,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEventInfoCard() {
    final ticket = _controller.ticketData!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations événement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildEventDetail(
            Icons.location_on_outlined,
            'Lieu',
            ticket.event.venue,
          ),
          const SizedBox(height: 8),
          _buildEventDetail(
            Icons.access_time_outlined,
            'Heure d\'ouverture',
            '30 minutes avant l\'événement',
          ),
          const SizedBox(height: 8),
          _buildEventDetail(
            Icons.info_outline,
            'Instructions',
            'Présentez ce billet (digital ou imprimé) à l\'entrée',
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Comment utiliser mon billet ?'),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined),
              title: const Text('Signaler un problème'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('À propos de THIX'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment utiliser mon billet ?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Ouvrez ce billet sur votre téléphone'),
            SizedBox(height: 8),
            Text('2. Présentez le QR code à l\'entrée'),
            SizedBox(height: 8),
            Text('3. Un membre de l\'équipe le scannera'),
            SizedBox(height: 8),
            Text('4. Vous pouvez aussi l\'imprimer'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: const Text(
          'Pour tout problème avec votre billet, contactez notre support :\n\nsupport@thix.com\n+221 78 000 00 00',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _addToCalendar() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement ajouté au calendrier'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
