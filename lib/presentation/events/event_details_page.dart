// ============================================================================
// FICHIER 1: lib/core/constants/app_constants.dart
// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:thix_id/models/event_item.dart';

class AppConstants {
  static const String appName = 'THIX';
  static const String ticketPrefix = 'THIX-EVT';
  
  static const double coverImageHeight = 280;
  static const double footerHeight = 100;
  static const double buttonHeight = 50;
  static const double buttonWidth = 180;
  static const double defaultPadding = 20;
  static const double smallPadding = 12;
  static const double borderRadius = 12;
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF64748B);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppStrings {
  // Event details
  static const String about = 'À propos';
  static const String price = 'Prix';
  static const String free = 'Gratuit';
  static const String book = 'Confirmer la place';
  static const String date = 'Date & Heure';
  static const String location = 'Lieu';
  static const String category = 'Catégorie';
  static const String tickets = 'Billets';
  
  // Errors & Messages
  static const String loginRequired = 'Veuillez vous connecter pour réserver';
  static const String bookingError = 'Échec de la réservation';
  static const String bookingSuccess = 'Réservation confirmée !';
  static const String networkError = 'Vérifiez votre connexion internet';
  static const String duplicateError = 'Une erreur est survenue, veuillez réessayer';
  static const String defaultError = 'Une erreur inattendue s\'est produite';
  
  // Placeholders
  static const String noDescription = 'Aucune description disponible pour cet événement.';
  static const String noDate = 'Date à confirmer';
  static const String noLocation = 'Lieu à confirmer';
  static const String noTitle = 'Sans titre';
  static const String defaultCategory = 'Événement';
}

// ============================================================================
// FICHIER 2: lib/core/helpers/date_formatter.dart
// ============================================================================
class DateFormatter {
  static String formatEventDate(DateTime? date) {
    if (date == null) return AppStrings.noDate;
    
    return '${_formatDate(date)} • ${_formatTime(date)}';
  }
  
  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Jul', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
  }
  
  static DateTime? parseEventDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }
    return null;
  }
}

// ============================================================================
// FICHIER 3: lib/core/helpers/error_handler.dart
// ============================================================================
class ErrorHandler {
  static String getUserFriendlyMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || 
        errorStr.contains('socket') || 
        errorStr.contains('connection')) {
      return AppStrings.networkError;
    }
    
    if (errorStr.contains('duplicate') || 
        errorStr.contains('unique constraint')) {
      return AppStrings.duplicateError;
    }
    
    if (errorStr.contains('auth') || 
        errorStr.contains('permission')) {
      return AppStrings.loginRequired;
    }
    
    return AppStrings.defaultError;
  }
  
  static void logError(String context, Object error, [StackTrace? stack]) {
    debugPrint('❌ ERROR [$context]: $error');
    if (stack != null) debugPrint(stack.toString());
  }
}

// ============================================================================
// FICHIER 4: lib/models/event_model.dart
// ============================================================================
class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String category;
  final DateTime? eventDate;
  final String venue;
  final bool isFree;
  final double? priceAmount;
  final String? currency;
  
  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.category,
    this.eventDate,
    required this.venue,
    required this.isFree,
    this.priceAmount,
    this.currency,
  });
  
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? AppStrings.noTitle,
      description: json['description']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      category: json['category']?.toString() ?? AppStrings.defaultCategory,
      eventDate: DateFormatter.parseEventDate(json['event_date']),
      venue: json['venue']?.toString() ?? AppStrings.noLocation,
      isFree: json['is_free'] == true,
      priceAmount: _parsePrice(json['price_amount']),
      currency: json['currency']?.toString(),
    );
  }
  
  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    return double.tryParse(price.toString());
  }
  
  String get formattedPrice {
    if (isFree) return AppStrings.free;
    if (priceAmount == null) return AppStrings.free;
    return '${priceAmount!.toStringAsFixed(0)} ${currency ?? 'FCFA'}';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'category': category,
      'event_date': eventDate?.toIso8601String(),
      'venue': venue,
      'is_free': isFree,
      'price_amount': priceAmount,
      'currency': currency,
    };
  }
}

// ============================================================================
// FICHIER 5: lib/widgets/common/custom_snackbar.dart
// ============================================================================
enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIcon(type), color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _getColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }
  
  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppColors.success;
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.warning:
        return AppColors.warning;
      case SnackBarType.info:
        return AppColors.primary;
    }
  }
}

// ============================================================================
// FICHIER 6: lib/widgets/event/event_cover.dart
// ============================================================================
class EventCover extends StatefulWidget {
  final String? imageUrl;
  final double height;
  
  const EventCover({super.key, this.imageUrl, this.height = AppConstants.coverImageHeight});
  
  @override
  State<EventCover> createState() => _EventCoverState();
}

class _EventCoverState extends State<EventCover> {
  final ImageProvider _defaultImage = const AssetImage('assets/images/placeholder.jpg');
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: widget.imageUrl != null && !_hasError
              ? _buildNetworkImage()
              : _buildPlaceholder(),
        ),
        if (_isLoading)
          Container(
            height: widget.height,
            color: AppColors.backgroundGrey,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildNetworkImage() {
    return Image.network(
      widget.imageUrl!,
      height: widget.height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _isLoading = false;
          return child;
        }
        return const SizedBox.shrink();
      },
      errorBuilder: (context, error, stackTrace) {
        _hasError = true;
        _isLoading = false;
        return _buildPlaceholder();
      },
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      width: double.infinity,
      color: AppColors.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: AppColors.textLight),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FICHIER 7: lib/widgets/event/event_info_card.dart
// ============================================================================
class EventInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  
  const EventInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FICHIER 8: lib/widgets/event/booking_button.dart
// ============================================================================
class BookingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double? priceAmount;
  final String? currency;
  final bool isFree;
  
  const BookingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.priceAmount,
    this.currency,
    this.isFree = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildPriceColumn(),
            ),
            const SizedBox(width: 16),
            _buildBookButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.price,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getPriceText(),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  String _getPriceText() {
    if (isFree) return AppStrings.free;
    if (priceAmount == null) return AppStrings.free;
    return '${priceAmount!.toStringAsFixed(0)} ${currency ?? 'FCFA'}';
  }
  
  Widget _buildBookButton() {
    return SizedBox(
      width: AppConstants.buttonWidth,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                AppStrings.book,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ============================================================================
// FICHIER 9: lib/services/ticket_service.dart
// ============================================================================
class TicketService {
  final SupabaseClient _supabase;
  final Random _random = Random();
  
  TicketService(this._supabase);
  
  String generateTicketCode() {
    final number = _random.nextInt(900000) + 100000;
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    return '${AppConstants.ticketPrefix}-$number-$timestamp';
  }
  
  Future<String> bookTicket({
    required String userId,
    required String eventId,
  }) async {
    final ticketCode = generateTicketCode();
    
    await _supabase.from('thix_event_tickets').insert({
      'user_id': userId,
      'event_id': eventId,
      'ticket_code': ticketCode,
      'status': 'valid',
      'created_at': DateTime.now().toIso8601String(),
    });
    
    return ticketCode;
  }
  
  Future<bool> hasUserBooked({
    required String userId,
    required String eventId,
  }) async {
    final response = await _supabase
        .from('thix_event_tickets')
        .select()
        .eq('user_id', userId)
        .eq('event_id', eventId)
        .eq('status', 'valid');
    
    return response.isNotEmpty;
  }
}

// ============================================================================
// FICHIER 10: lib/pages/event_details_page.dart (PAGE PRINCIPALE)
// ============================================================================
class EventDetailsPage extends StatefulWidget {
  final EventModel event;
  
  const EventDetailsPage({
    super.key,
    required this.event,
  });
  
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late final TicketService _ticketService;
  bool _isBooking = false;
  bool _alreadyBooked = false;
  
  @override
  void initState() {
    super.initState();
    _ticketService = TicketService(Supabase.instance.client);
    _checkIfAlreadyBooked();
  }
  
  Future<void> _checkIfAlreadyBooked() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    try {
      final booked = await _ticketService.hasUserBooked(
        userId: user.id,
        eventId: widget.event.id,
      );
      if (mounted) {
        setState(() => _alreadyBooked = booked);
      }
    } catch (e) {
      ErrorHandler.logError('CheckBooking', e);
    }
  }
  
  Future<void> _handleBooking() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      _showLoginDialog();
      return;
    }
    
    if (_alreadyBooked) {
      _showAlreadyBookedDialog();
      return;
    }
    
    setState(() => _isBooking = true);
    
    try {
      final ticketCode = await _ticketService.bookTicket(
        userId: user.id,
        eventId: widget.event.id,
      );
      
      if (!mounted) return;
      
      CustomSnackBar.show(
        context,
        message: AppStrings.bookingSuccess,
        type: SnackBarType.success,
      );
      
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketSuccessPage(
            event: widget.event.toJson(),
            ticketCode: ticketCode,
          ),
        ),
      );
    } catch (e) {
      ErrorHandler.logError('Booking', e);
      if (!mounted) return;
      
      CustomSnackBar.show(
        context,
        message: '${AppStrings.bookingError}: ${ErrorHandler.getUserFriendlyMessage(e)}',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }
  
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: const Text('Connexion requise'),
        content: const Text(AppStrings.loginRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigation vers login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
  
  void _showAlreadyBookedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        content: const Text('Vous avez déjà réservé pour cet événement !'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: AppConstants.coverImageHeight,
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                leading: _buildBackButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: EventCover(imageUrl: widget.event.coverImageUrl),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryChip(),
                      const SizedBox(height: 12),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BookingButton(
              onPressed: _handleBooking,
              isLoading: _isBooking,
              priceAmount: widget.event.priceAmount,
              currency: widget.event.currency,
              isFree: widget.event.isFree,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
        color: AppColors.textDark,
      ),
    );
  }
  
  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            widget.event.category,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitle() {
    return Text(
      widget.event.title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        height: 1.3,
      ),
    );
  }
  
  Widget _buildInfoSection() {
    return Column(
      children: [
        EventInfoCard(
          icon: Icons.calendar_today_rounded,
          label: AppStrings.date,
          value: DateFormatter.formatEventDate(widget.event.eventDate),
        ),
        const SizedBox(height: 12),
        EventInfoCard(
          icon: Icons.location_on_rounded,
          label: AppStrings.location,
          value: widget.event.venue,
          onTap: () {
            // Ouvrir dans maps
          },
        ),
      ],
    );
  }
  
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.about,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.event.description ?? AppStrings.noDescription,
            style: TextStyle(
              color: AppColors.textMedium,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
