import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Términos y condiciones', 'Terms & Conditions')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(context, isDark),
          const SizedBox(height: 20),
          _buildSection(
            context,
            icon: Icons.info_outline_rounded,
            titleEs: '1. Aceptación de los términos',
            titleEn: '1. Acceptance of terms',
            bodyEs:
                'Al utilizar AgroGo, el usuario acepta estos términos y condiciones. Si no está de acuerdo con alguna disposición, deberá abstenerse de utilizar la aplicación. AgroGo funciona como una plataforma digital para consultar, seleccionar y gestionar solicitudes de renta de maquinaria agrícola.',
            bodyEn:
                'By using AgroGo, the user accepts these terms and conditions. If the user does not agree with any provision, they should not use the application. AgroGo works as a digital platform to search, select and manage agricultural machinery rental requests.',
          ),
          _buildSection(
            context,
            icon: Icons.agriculture_rounded,
            titleEs: '2. Uso de la plataforma',
            titleEn: '2. Platform usage',
            bodyEs:
                'El usuario se compromete a utilizar la aplicación de forma responsable, proporcionando información verídica durante el registro, consulta de equipos, gestión de perfil y solicitudes de reserva. Queda prohibido utilizar AgroGo para actividades fraudulentas, suplantación de identidad o manipulación de información.',
            bodyEn:
                'The user agrees to use the application responsibly, providing truthful information during registration, equipment search, profile management and booking requests. AgroGo must not be used for fraudulent activities, identity impersonation or information manipulation.',
          ),
          _buildSection(
            context,
            icon: Icons.event_note_rounded,
            titleEs: '3. Reservas de maquinaria',
            titleEn: '3. Machinery bookings',
            bodyEs:
                'Las reservas realizadas en AgroGo están sujetas a disponibilidad, validación del proveedor y confirmación de las condiciones de renta. La información mostrada sobre precios, fechas, ubicación y características de los equipos puede actualizarse conforme a la operación real del servicio.',
            bodyEn:
                'Bookings made through AgroGo are subject to availability, provider validation and confirmation of rental conditions. Displayed information about prices, dates, location and equipment characteristics may be updated according to the real operation of the service.',
          ),
          _buildSection(
            context,
            icon: Icons.payments_outlined,
            titleEs: '4. Pagos, costos y cargos',
            titleEn: '4. Payments, costs and charges',
            bodyEs:
                'En caso de integrar pagos dentro de la aplicación, AgroGo deberá utilizar pasarelas seguras y notificar al usuario antes de confirmar cualquier cargo. Los costos de renta, depósitos, penalizaciones o cargos adicionales deberán mostrarse de forma clara antes de finalizar una operación.',
            bodyEn:
                'If in-app payments are integrated, AgroGo must use secure payment gateways and notify the user before confirming any charge. Rental costs, deposits, penalties or additional charges must be clearly displayed before completing an operation.',
          ),
          _buildSection(
            context,
            icon: Icons.security_rounded,
            titleEs: '5. Seguridad de la cuenta',
            titleEn: '5. Account security',
            bodyEs:
                'El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso. AgroGo podrá implementar medidas como validación de correo, cifrado de contraseñas, tokens de sesión y cierre de sesión seguro para proteger las cuentas de usuario.',
            bodyEn:
                'The user is responsible for keeping access credentials confidential. AgroGo may implement measures such as email validation, password encryption, session tokens and secure logout to protect user accounts.',
          ),
          _buildSection(
            context,
            icon: Icons.privacy_tip_outlined,
            titleEs: '6. Datos personales',
            titleEn: '6. Personal data',
            bodyEs:
                'AgroGo podrá recopilar datos como nombre, correo electrónico, ubicación, historial de reservas y preferencias de uso, únicamente para operar la plataforma, brindar soporte, mejorar el servicio y gestionar solicitudes. El tratamiento de datos deberá complementarse con un aviso de privacidad formal.',
            bodyEn:
                'AgroGo may collect data such as name, email, location, booking history and usage preferences only to operate the platform, provide support, improve the service and manage requests. Data processing should be complemented by a formal privacy notice.',
          ),
          _buildSection(
            context,
            icon: Icons.warning_amber_rounded,
            titleEs: '7. Responsabilidad del usuario',
            titleEn: '7. User responsibility',
            bodyEs:
                'El usuario deberá verificar las condiciones del equipo antes de utilizarlo, respetar los tiempos de renta, reportar incidentes y utilizar la maquinaria conforme a las recomendaciones del proveedor. AgroGo no será responsable por daños ocasionados por uso negligente, indebido o no autorizado.',
            bodyEn:
                'The user must verify equipment conditions before use, respect rental periods, report incidents and use machinery according to provider recommendations. AgroGo will not be responsible for damage caused by negligent, improper or unauthorized use.',
          ),
          _buildSection(
            context,
            icon: Icons.storefront_outlined,
            titleEs: '8. Responsabilidad de proveedores',
            titleEn: '8. Provider responsibility',
            bodyEs:
                'Los proveedores deberán publicar información clara, actualizada y comprobable sobre la maquinaria ofrecida, incluyendo disponibilidad, estado físico, condiciones de entrega, restricciones y costos. También deberán atender reportes relacionados con fallas o incumplimientos del servicio.',
            bodyEn:
                'Providers must publish clear, updated and verifiable information about offered machinery, including availability, physical condition, delivery terms, restrictions and costs. They must also respond to reports related to failures or service breaches.',
          ),
          _buildSection(
            context,
            icon: Icons.update_rounded,
            titleEs: '9. Cambios en los términos',
            titleEn: '9. Changes to terms',
            bodyEs:
                'AgroGo podrá actualizar estos términos y condiciones para adaptarlos a mejoras técnicas, cambios legales o nuevas funcionalidades. Las modificaciones deberán notificarse dentro de la aplicación o mediante canales oficiales.',
            bodyEn:
                'AgroGo may update these terms and conditions to adapt them to technical improvements, legal changes or new features. Changes should be notified inside the application or through official channels.',
          ),
          _buildSection(
            context,
            icon: Icons.gavel_rounded,
            titleEs: '10. Legislación aplicable',
            titleEn: '10. Applicable law',
            bodyEs:
                'Estos términos se interpretarán conforme a la legislación aplicable en México, especialmente en materia de comercio electrónico, protección de datos personales, derechos del consumidor y responsabilidad por prestación de servicios digitales.',
            bodyEn:
                'These terms shall be interpreted according to applicable law in Mexico, especially regarding electronic commerce, personal data protection, consumer rights and responsibility for digital services.',
          ),
          const SizedBox(height: 12),
          _buildDisclaimer(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF263238), Color(0xFF1B5E20)]
              : const [AppTheme.primaryColor, AppTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.description_outlined,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 14),
          Text(
            tr(
              'Términos profesionales para el uso responsable de AgroGo.',
              'Professional terms for responsible use of AgroGo.',
            ),
            style: const TextStyle(
              color: Colors.white,
              height: 1.35,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Última actualización: abril de 2026',
              'Last updated: April 2026',
            ),
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String titleEs,
    required String titleEn,
    required String bodyEs,
    required String bodyEn,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : AppTheme.borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(titleEs, titleEn),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(bodyEs, bodyEn),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.48,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(isDark ? 0.14 : 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr(
                'Estos términos y condiciones son un ejemplo de referencia y no constituyen asesoría legal. Se recomienda consultar con un profesional del derecho para adaptar el contenido a las necesidades específicas de la aplicación y cumplir con la legislación aplicable.',
                'These terms and conditions are a reference example and do not constitute legal advice. It is recommended to consult with a legal professional to adapt the content to the specific needs of the application and comply with applicable law.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}