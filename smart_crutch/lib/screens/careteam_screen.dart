import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CareTeamScreen extends StatelessWidget {
  const CareTeamScreen({super.key});

  void _showContactSheet(BuildContext context, String name, String contact) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.white, Colors.teal.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -6),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Text(
                  "Contact $name",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.call,
                      label: "Call",
                      color: Colors.green,
                      onTap: () => _launchPhone(contact),
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.message,
                      label: "Message",
                      color: Colors.blue,
                      onTap: () => _launchSms(contact),
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.video_call,
                      label: "Video",
                      color: Colors.purple,
                      onTap: () => _launchWhatsapp(contact),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String contact) async {
    final Uri uri = Uri(scheme: 'tel', path: contact);
    await launchUrl(uri);
  }

  Future<void> _launchSms(String contact) async {
    final Uri uri = Uri(scheme: 'sms', path: contact);
    await launchUrl(uri);
  }

  Future<void> _launchWhatsapp(String contact) async {
    final Uri uri =
    Uri.parse("https://wa.me/${contact.replaceAll(RegExp(r'[^0-9]'), '')}");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildContactCard({
    required BuildContext context,
    required String name,
    required String role,
    required String contact,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () => _showContactSheet(context, name, contact),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "$role\n$contact",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Care Team"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.teal.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.health_and_safety_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your Care Team is here to assist you anytime 💖",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Doctor
                _buildContactCard(
                  context: context,
                  name: "Dr. Priya Sharma",
                  role: "Physiotherapist",
                  contact: "+91 98765 43210",
                  icon: Icons.medical_services_rounded,
                  gradient: [Colors.deepPurpleAccent, Colors.purple],
                ),

                // Family
                _buildContactCard(
                  context: context,
                  name: "Arun Kumar",
                  role: "Family Contact",
                  contact: "+91 91234 56789",
                  icon: Icons.family_restroom_rounded,
                  gradient: [Colors.orangeAccent, Colors.deepOrange],
                ),

                // Emergency
                _buildContactCard(
                  context: context,
                  name: "City Hospital",
                  role: "Emergency Support",
                  contact: "+91 80000 11111",
                  icon: Icons.local_hospital_rounded,
                  gradient: [Colors.redAccent, Colors.pinkAccent],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
