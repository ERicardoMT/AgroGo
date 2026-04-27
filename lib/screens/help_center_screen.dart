import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<_HelpTopic> _topics = [
    _HelpTopic(
      icon: Icons.agriculture_rounded,
      titleEs: '¿Cómo rento una maquinaria?',
      titleEn: 'How do I rent machinery?',
      bodyEs:
          'Busca el equipo que necesitas, abre su detalle, revisa disponibilidad, precio y condiciones. Después presiona el botón de reserva y confirma las fechas de uso.',
      bodyEn:
          'Search for the equipment you need, open its details, check availability, price and conditions. Then press the booking button and confirm the usage dates.',
    ),
    _HelpTopic(
      icon: Icons.event_available_rounded,
      titleEs: '¿Cómo reviso mis reservas?',
      titleEn: 'How do I check my bookings?',
      bodyEs:
          'Entra a la sección de Reservas desde la barra principal. Ahí podrás consultar tus rentas activas, pendientes o finalizadas.',
      bodyEn:
          'Go to the Bookings section from the main navigation bar. There you can check your active, pending or completed rentals.',
    ),
    _HelpTopic(
      icon: Icons.favorite_border_rounded,
      titleEs: '¿Para qué sirven los favoritos?',
      titleEn: 'What are favorites for?',
      bodyEs:
          'Los favoritos te permiten guardar maquinaria que te interesa para consultarla más rápido después, sin tener que buscarla nuevamente.',
      bodyEn:
          'Favorites let you save machinery you are interested in, so you can check it faster later without searching again.',
    ),
    _HelpTopic(
      icon: Icons.payments_outlined,
      titleEs: '¿AgroGo procesa pagos dentro de la app?',
      titleEn: 'Does AgroGo process payments inside the app?',
      bodyEs:
          'Por ahora, AgroGo funciona como plataforma de consulta y reserva. La integración de pagos puede agregarse posteriormente con pasarelas seguras.',
      bodyEn:
          'For now, AgroGo works as a search and booking platform. Payment integration can be added later using secure payment gateways.',
    ),
    _HelpTopic(
      icon: Icons.verified_user_outlined,
      titleEs: '¿Cómo se protege mi información?',
      titleEn: 'How is my information protected?',
      bodyEs:
          'AgroGo debe manejar tus datos personales con fines de identificación, contacto, reservas y soporte. En futuras versiones se recomienda integrar autenticación segura, cifrado y aviso de privacidad.',
      bodyEn:
          'AgroGo should handle your personal data for identification, contact, bookings and support. Future versions should include secure authentication, encryption and a privacy notice.',
    ),
    _HelpTopic(
      icon: Icons.build_circle_outlined,
      titleEs: '¿Qué hago si una maquinaria aparece como no disponible?',
      titleEn: 'What if machinery appears unavailable?',
      bodyEs:
          'Puedes revisar otras fechas, buscar equipos similares o contactar soporte para validar disponibilidad directamente con el proveedor.',
      bodyEn:
          'You can check other dates, search for similar equipment, or contact support to validate availability directly with the provider.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_HelpTopic> get _filteredTopics {
    final cleanQuery = _query.trim().toLowerCase();

    if (cleanQuery.isEmpty) return _topics;

    // Optimización local: se normaliza una sola vez la búsqueda para evitar
    // comparar strings completos sin necesidad en cada campo.
    return _topics.where((topic) {
      final text = [
        topic.titleEs,
        topic.titleEn,
        topic.bodyEs,
        topic.bodyEn,
      ].join(' ').toLowerCase();

      return text.contains(cleanQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = _filteredTopics;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Centro de ayuda', 'Help Center')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeroCard(context, isDark),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: tr('Buscar una duda...', 'Search a question...'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          Text(
            tr('Preguntas frecuentes', 'Frequently Asked Questions'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            _buildEmptyState(context)
          else
            ...topics.map((topic) => _buildTopicTile(context, topic, isDark)),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1B5E20), Color(0xFF263238)]
              : const [AppTheme.primaryColor, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tr(
                'Encuentra respuestas rápidas sobre reservas, maquinaria, favoritos y seguridad.',
                'Find quick answers about bookings, machinery, favorites and security.',
              ),
              style: const TextStyle(
                color: Colors.white,
                height: 1.35,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTile(
    BuildContext context,
    _HelpTopic topic,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : AppTheme.borderColor,
        ),
      ),
      child: ExpansionTile(
        leading: Icon(
          topic.icon,
          color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
        ),
        title: Text(
          tr(topic.titleEs, topic.titleEn),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          Text(
            tr(topic.bodyEs, topic.bodyEn),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 42),
          const SizedBox(height: 10),
          Text(
            tr(
              'No encontramos una respuesta con esa búsqueda.',
              'No answer was found for that search.',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String titleEs;
  final String titleEn;
  final String bodyEs;
  final String bodyEn;

  const _HelpTopic({
    required this.icon,
    required this.titleEs,
    required this.titleEn,
    required this.bodyEs,
    required this.bodyEn,
  });
}