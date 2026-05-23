// ============================================================================
// FICHIER: lib/presentation/events/event_register_page.dart
// Version corrigée - Plus d'erreurs
// ============================================================================
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/event_service.dart';
import 'package:thix_id/services/profile_service.dart';
import 'package:thix_id/services/thix_id_service.dart';

// ============================================================================
// CONSTANTES
// ============================================================================
class RegisterRoutes {
  static const String ticketSuccess = '/ticket-success';
}

// ============================================================================
// MODÈLES
// ============================================================================
enum TicketType {
  standard('Standard', 1.0, Icons.confirmation_num_outlined),
  vip('VIP', 2.5, Icons.star_outline),
  premium('Premium', 4.0, Icons.workspace_premium_outlined);

  final String label;
  final double multiplier;
  final IconData icon;

  const TicketType(this.label, this.multiplier, this.icon);

  double calculatePrice(double basePrice) => basePrice * multiplier;

  String getFormattedPrice(double basePrice) {
    final price = calculatePrice(basePrice);
    return '${price.toStringAsFixed(0)} FCFA';
  }
}

enum PaymentMethod {
  orangeMoney('Orange Money', Icons.phone_android_rounded, 'OM'),
  wave('Wave', Icons.waves_rounded, 'Wave'),
  card('Carte Bancaire', Icons.credit_card_rounded, 'Card');

  final String label;
  final IconData icon;
  final String code;

  const PaymentMethod(this.label, this.icon, this.code);
}

class RegistrationData {
  final String eventId;
  final String eventTitle;
  final TicketType ticketType;
  final int quantity;
  final PaymentMethod paymentMethod;
  final double totalPrice;
  final String? promoCode;
  final Map<String, dynamic> attendeeInfo;

  RegistrationData({
    required this.eventId,
    required this.eventTitle,
    required this.ticketType,
    required this.quantity,
    required this.paymentMethod,
    required this.totalPrice,
    this.promoCode,
    this.attendeeInfo = const {},
  });

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'event_title': eventTitle,
    'ticket_type': ticketType.label,
    'quantity': quantity,
    'payment_method': paymentMethod.code,
    'total_price': totalPrice,
    'promo_code': promoCode,
    'attendee_info': attendeeInfo,
    'created_at': DateTime.now().toIso8601String(),
  };
}

// ============================================================================
// PROVIDER / CONTROLLER
// ============================================================================
class EventRegistrationController extends ChangeNotifier {
  final EventService _eventService;
  final ProfileService _profileService;
  final ThixIdService _thixIdService;

  RegistrationData? _currentRegistration;
  bool _isLoading = false;
  String? _errorMessage;
  double? _appliedDiscount;

  EventRegistrationController({
    required EventService eventService,
    required ProfileService profileService,
    required ThixIdService thixIdService,
  }) : _eventService = eventService,
       _profileService = profileService,
       _thixIdService = thixIdService;

  RegistrationData? get currentRegistration => _currentRegistration;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get appliedDiscount => _appliedDiscount;
  double get discountMultiplier => _appliedDiscount != null ? (100 - _appliedDiscount!) / 100 : 1.0;

  void initializeRegistration(String eventId, String eventTitle, double basePrice) {
    _currentRegistration = RegistrationData(
      eventId: eventId,
      eventTitle: eventTitle,
      ticketType: TicketType.standard,
      quantity: 1,
      paymentMethod: PaymentMethod.wave,
      totalPrice: basePrice,
    );
    notifyListeners();
  }

  void updateTicketType(TicketType type) {
    if (_currentRegistration == null) return;
    final newTotal = _calculateTotal(
      type.calculatePrice(_getBasePrice()),
      _currentRegistration!.quantity,
    );
    _currentRegistration = RegistrationData(
      eventId: _currentRegistration!.eventId,
      eventTitle: _currentRegistration!.eventTitle,
      ticketType: type,
      quantity: _currentRegistration!.quantity,
      paymentMethod: _currentRegistration!.paymentMethod,
      totalPrice: newTotal,
      promoCode: _currentRegistration!.promoCode,
      attendeeInfo: _currentRegistration!.attendeeInfo,
    );
    notifyListeners();
  }

  void updateQuantity(int quantity) {
    if (_currentRegistration == null) return;
    final newTotal = _calculateTotal(
      _getPricePerTicket(),
      quantity,
    );
    _currentRegistration = RegistrationData(
      eventId: _currentRegistration!.eventId,
      eventTitle: _currentRegistration!.eventTitle,
      ticketType: _currentRegistration!.ticketType,
      quantity: quantity,
      paymentMethod: _currentRegistration!.paymentMethod,
      totalPrice: newTotal,
      promoCode: _currentRegistration!.promoCode,
      attendeeInfo: _currentRegistration!.attendeeInfo,
    );
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod method) {
    if (_currentRegistration == null) return;
    _currentRegistration = RegistrationData(
      eventId: _currentRegistration!.eventId,
      eventTitle: _currentRegistration!.eventTitle,
      ticketType: _currentRegistration!.ticketType,
      quantity: _currentRegistration!.quantity,
      paymentMethod: method,
      totalPrice: _currentRegistration!.totalPrice,
      promoCode: _currentRegistration!.promoCode,
      attendeeInfo: _currentRegistration!.attendeeInfo,
    );
    notifyListeners();
  }

  Future<bool> applyPromoCode(String code) async {
    if (_currentRegistration == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final discount = await _eventService.validatePromoCode(code, _currentRegistration!.eventId);
      if (discount != null && discount > 0) {
        _appliedDiscount = discount;
        final newTotal = _currentRegistration!.totalPrice * ((100 - discount) / 100);
        _currentRegistration = RegistrationData(
          eventId: _currentRegistration!.eventId,
          eventTitle: _currentRegistration!.eventTitle,
          ticketType: _currentRegistration!.ticketType,
          quantity: _currentRegistration!.quantity,
          paymentMethod: _currentRegistration!.paymentMethod,
          totalPrice: newTotal,
          promoCode: code,
          attendeeInfo: _currentRegistration!.attendeeInfo,
        );
        notifyListeners();
        return true;
      }
      _errorMessage = 'Code promo invalide';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Code promo invalide';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(BuildContext context, {required String attendeeName, required String attendeeEmail, required String attendeePhone}) async {
    if (_currentRegistration == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.id;
      
      if (userId == null) {
        _errorMessage = 'Veuillez vous connecter';
        return false;
      }

      // Vérifier si l'utilisateur a déjà un billet
      final hasTicket = await _eventService.hasUserTicket(
        userId, 
        _currentRegistration!.eventId,
      );
      
      if (hasTicket) {
        _errorMessage = 'Vous avez déjà réservé pour cet événement';
        return false;
      }

      // Mettre à jour les infos du participant
      final updatedRegistration = RegistrationData(
        eventId: _currentRegistration!.eventId,
        eventTitle: _currentRegistration!.eventTitle,
        ticketType: _currentRegistration!.ticketType,
        quantity: _currentRegistration!.quantity,
        paymentMethod: _currentRegistration!.paymentMethod,
        totalPrice: _currentRegistration!.totalPrice,
        promoCode: _currentRegistration!.promoCode,
        attendeeInfo: {
          'name': attendeeName,
          'email': attendeeEmail,
          'phone': attendeePhone,
        },
      );

      // Générer un code Thix ID unique
      final thixCode = await _thixIdService.generateEventCode(
        userId: userId,
        eventId: _currentRegistration!.eventId,
      );

      // Créer la réservation
      final ticketCode = await _eventService.createRegistration(
        updatedRegistration.toJson(),
        userId: userId,
      );

      // Naviguer vers la page de succès
      if (context.mounted) {
        context.push(RegisterRoutes.ticketSuccess, extra: {
          'ticketCode': ticketCode,
          'thixCode': thixCode,
          'event': updatedRegistration.toJson(),
        });
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _getBasePrice() {
    // À remplacer par la vraie valeur récupérée de l'événement
    return 10000;
  }

  double _getPricePerTicket() {
    return _currentRegistration!.ticketType.calculatePrice(_getBasePrice());
  }

  double _calculateTotal(double pricePerTicket, int quantity) {
    return (pricePerTicket * quantity) * discountMultiplier;
  }

  void reset() {
    _currentRegistration = null;
    _isLoading = false;
    _errorMessage = null;
    _appliedDiscount = null;
    notifyListeners();
  }
}

// ============================================================================
// COULEURS
// ============================================================================
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color white = Colors.white;
}

// ============================================================================
// WIDGETS UI
// ============================================================================
class EventRegisterPage extends StatefulWidget {
  final String eventId;

  const EventRegisterPage({
    super.key,
    required this.eventId,
  });

  @override
  State<EventRegisterPage> createState() => _EventRegisterPageState();
}

class _EventRegisterPageState extends State<EventRegisterPage> {
  late EventRegistrationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _promoCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _showPromoField = false;
  
  String _eventTitle = '';
  double _basePrice = 0;
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _controller = EventRegistrationController(
      eventService: EventService(Supabase.instance.client),
      profileService: ProfileService(Supabase.instance.client),
      thixIdService: ThixIdService(Supabase.instance.client),
    );
  }

  Future<void> _loadEventData() async {
    final eventService = EventService(Supabase.instance.client);
    final event = await eventService.getEventById(widget.eventId);
    if (event != null && mounted) {
      setState(() {
        _eventTitle = event.title;
        _basePrice = event.priceAmount ?? 0;
        _coverImageUrl = event.coverImageUrl;
      });
      _controller.initializeRegistration(
        widget.eventId,
        _eventTitle,
        _basePrice,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _promoCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Réserver ma place'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<EventRegistrationController>(
      builder: (context, controller, child) {
        if (controller.currentRegistration == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(),
                const SizedBox(height: 24),
                _buildTicketTypeSelector(controller),
                const SizedBox(height: 20),
                _buildQuantitySelector(controller),
                const SizedBox(height: 20),
                _buildPaymentMethodSelector(controller),
                const SizedBox(height: 20),
                _buildPromoCodeSection(controller),
                const SizedBox(height: 20),
                _buildAttendeeInfoForm(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _coverImageUrl != null && _coverImageUrl!.isNotEmpty
                ? Image.network(
                    _coverImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Consumer<EventRegistrationController>(
                  builder: (context, controller, _) => Text(
                    '${controller.currentRegistration?.quantity ?? 0} place(s) · ${controller.currentRegistration?.ticketType.label ?? "Standard"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.backgroundLight,
      child: const Icon(Icons.event, size: 30),
    );
  }

  Widget _buildTicketTypeSelector(EventRegistrationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de billet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...TicketType.values.map((type) => RadioListTile<TicketType>(
                value: type,
                groupValue: controller.currentRegistration?.ticketType,
                onChanged: (value) {
                  if (value != null) controller.updateTicketType(value);
                },
                title: Text(type.label),
                subtitle: Text(
                  type.getFormattedPrice(_basePrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(type.icon, color: AppColors.primary),
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(EventRegistrationController controller) {
    return QuantitySelector(
      quantity: controller.currentRegistration?.quantity ?? 1,
      minQuantity: 1,
      maxQuantity: 10,
      pricePerTicket: _basePrice *
          (controller.currentRegistration?.ticketType.multiplier ?? 1),
      onQuantityChanged: (qty) => controller.updateQuantity(qty),
    );
  }

  Widget _buildPaymentMethodSelector(EventRegistrationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moyen de paiement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map((method) => RadioListTile<PaymentMethod>(
                value: method,
                groupValue: controller.currentRegistration?.paymentMethod,
                onChanged: (value) {
                  if (value != null) controller.updatePaymentMethod(value);
                },
                title: Text(method.label),
                secondary: Icon(method.icon, color: AppColors.primary),
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(EventRegistrationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Code promo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showPromoField = !_showPromoField),
                icon: Icon(
                  _showPromoField ? Icons.keyboard_arrow_up : Icons.local_offer_outlined,
                  size: 18,
                ),
                label: Text(_showPromoField ? 'Fermer' : 'Ajouter'),
              ),
            ],
          ),
          if (_showPromoField) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _promoCodeController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final success = await controller.applyPromoCode(
                            _promoCodeController.text,
                          );
                          if (success && mounted) {
                            _promoCodeController.clear();
                            setState(() => _showPromoField = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code promo appliqué !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted && controller.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Appliquer'),
                ),
              ],
            ),
          ],
          if (controller.appliedDiscount != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Réduction de ${controller.appliedDiscount!.toInt()}% appliquée',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendeeInfoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du participant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom complet',
              hintText: 'Entrez votre nom complet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Champ requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'votre@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Champ requis';
              if (!value!.contains('@') || !value.contains('.')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              hintText: '77 123 45 67',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty == true) return 'Champ requis';
              if (value!.length < 9) return 'Numéro invalide';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<EventRegistrationController>(
      builder: (context, controller, child) {
        final registration = controller.currentRegistration;
        if (registration == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total à payer',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (controller.appliedDiscount != null)
                          Text(
                            '${registration.totalPrice.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        Text(
                          '${registration.totalPrice.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : () => _submitRegistration(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Confirmer et payer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitRegistration(EventRegistrationController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await controller.register(
      context,
      attendeeName: _nameController.text,
      attendeeEmail: _emailController.text,
      attendeePhone: _phoneController.text,
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Erreur lors de la réservation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================================================
// WIDGET: QuantitySelector
// ============================================================================
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final double pricePerTicket;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.pricePerTicket,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre de places',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(
                icon: Icons.remove_rounded,
                onPressed: quantity > minQuantity ? () => onQuantityChanged(quantity - 1) : null,
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _buildButton(
                icon: Icons.add_rounded,
                onPressed: quantity < maxQuantity ? () => onQuantityChanged(quantity + 1) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Prix unitaire: ${pricePerTicket.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed != null ? AppColors.primary : AppColors.backgroundLight,
      ),
      child: IconButton(
        icon: Icon(icon, color: onPressed != null ? AppColors.white : AppColors.textLight),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      ),
    );
  }
}
