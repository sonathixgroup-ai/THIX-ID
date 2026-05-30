// ============================================================================
// FICHIER: lib/presentation/events/events_page.dart
// Version corrigée - Plus d'erreurs
// ============================================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Vos modèles et services
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/services/event_service.dart';


// ============================================================================
// CONSTANTES (pour remplacer Routes manquant)
// ============================================================================
class EventRoutes {
  static const String events = '/events';
  static const String eventDetails = '/events/:eventId';
  static const String eventRegister = '/events/:eventId/register';
  static const String userEventsDashboard = '/events/me';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
}

// ============================================================================
// CONTROLLER
// ============================================================================
class EventsPageController extends ChangeNotifier {
  final EventService _eventService;
  List<EventItem> _recommendedEvents = [];
  List<EventItem> _upcomingEvents = [];
  List<String> _popularCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  EventsPageController({required EventService eventService})
      : _eventService = eventService;

  List<EventItem> get recommendedEvents => _recommendedEvents;
  List<EventItem> get upcomingEvents => _upcomingEvents;
  List<String> get popularCategories => _popularCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _recommendedEvents = await _eventService.getRecommendedEvents(limit: 4);
      _upcomingEvents = await _eventService.getUpcomingEvents(limit: 2);
      _popularCategories = await _eventService.getPopularCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() => loadHomeData();
}

// ============================================================================
// PAGE PRINCIPALE
// ============================================================================
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late EventsPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EventsPageController(
      eventService: EventService(Supabase.instance.client),
    );
    _controller.loadHomeData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) return _buildLoadingState();
          if (_controller.errorMessage != null) return _buildErrorState();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text(
                  'THIX ÉVÉNEMENT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                centerTitle: false,
                elevation: 0,
                backgroundColor: Colors.white,
                floating: true,
                toolbarHeight: 56,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications à venir')),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildPopularCategoriesSection(),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(),
                    const SizedBox(height: 24),
                    _buildNotificationBanner(),
                    const SizedBox(height: 24),
                    _buildUpcomingSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==========================================================================
  // ÉTATS
  // ==========================================================================
  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());
  
  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_controller.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );

  // ==========================================================================
  // SECTION HERO (À LA UNE)
  // ==========================================================================
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À LA UNE',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vivez des moments inoubliables.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Concerts, festivals, conférences, spectacles et plus encore.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () => context.push(EventRoutes.events),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Découvrir', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CATÉGORIES POPULAIRES
  // ==========================================================================
  Widget _buildPopularCategoriesSection() {
    final categories = _controller.popularCategories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Catégories populaires', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Voir tout', style: TextStyle(fontSize: 12, color: Color(0xFF6366F1))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _buildCategoryChip(categories[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final Map<String, IconData> icons = {
      'Musique & Concerts': Icons.music_note,
      'Conférences & Séminaires': Icons.record_voice_over,
      'Culture & Art': Icons.palette,
      'Sport & Loisirs': Icons.sports_soccer,
      'Festivals & Soirées': Icons.celebration,
    };
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[category] ?? Icons.category, size: 28, color: const Color(0xFF6366F1)),
          const SizedBox(height: 4),
          Text(
            category,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ÉVÉNEMENTS RECOMMANDÉS
  // ==========================================================================
  Widget _buildRecommendedSection() {
    final events = _controller.recommendedEvents;
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Événements recommandés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) => _buildEventCard(events[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return GestureDetector(
      onTap: () => context.push('/events/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                  ? Image.network(
                      event.coverImageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(100),
                    )
                  : _imagePlaceholder(100),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(_formatDateShort(event.eventDate), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.isFree ? 'Gratuit' : '${event.priceAmount?.toStringAsFixed(0)} ${event.currency ?? '€'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/events/${event.id}/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Réserver', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.event, color: Colors.grey),
    );
  }

  // ==========================================================================
  // BANNIÈRE NOTIFICATION
  // ==========================================================================
  Widget _buildNotificationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ne manquez aucun événement !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Activez les notifications', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Activer', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROCHAINS ÉVÉNEMENTS
  // ==========================================================================
  Widget _buildUpcomingSection() {
    final events = _controller.upcomingEvents;
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prochains événements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...events.map((e) => _buildUpcomingCard(e)),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(EventItem event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(_formatDay(event.eventDate), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                Text(_formatMonth(event.eventDate), style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Text(event.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 4),
                Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time, size: 10, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_formatTime(event.eventDate), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.isFree ? 'Gratuit' : '${event.priceAmount?.toStringAsFixed(0)} ${event.currency ?? '€'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => context.push('/events/${event.id}/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Réserver', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM NAVIGATION BAR
  // ==========================================================================
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6366F1),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 1:
            context.push(EventRoutes.search);
            break;
          case 2:
            context.push(EventRoutes.userEventsDashboard);
            break;
          case 3:
            context.push(EventRoutes.favorites);
            break;
          case 4:
            context.push(EventRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 22), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined, size: 22), label: 'Rechercher'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined, size: 22), label: 'Mes billets'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border, size: 22), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), label: 'Profil'),
      ],
    );
  }

  // ==========================================================================
  // FORMATTEURS
  // ==========================================================================
  String _formatDateShort(DateTime d) => '${d.day} ${_monthAbbr(d.month)} ${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  String _formatDay(DateTime d) => '${d.day}';
  String _formatMonth(DateTime d) => _monthAbbr(d.month);
  String _formatTime(DateTime d) => '${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  String _monthAbbr(int m) => const ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'][m - 1];
}
