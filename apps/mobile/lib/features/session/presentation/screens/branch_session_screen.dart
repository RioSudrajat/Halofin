import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class BranchSessionScreen extends StatefulWidget {
  const BranchSessionScreen({super.key});

  @override
  State<BranchSessionScreen> createState() => _BranchSessionScreenState();
}

class _BranchSessionScreenState extends State<BranchSessionScreen> {
  int _selectedFilter = 0;
  final _filters = ['Semua', 'Aktif', 'Selesai', 'Batal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Sesi & Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: List.generate(_filters.length, (i) {
                final selected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.black : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),

          // Session list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Section: AKTIF
                _buildSectionLabel('AKTIF'),
                const SizedBox(height: 8),
                _buildSessionCard(
                  name: 'Sarah Jenkins',
                  role: 'Tax Consultant',
                  sessionTitle: 'Konsultasi SPT Tahunan (3 Hari)',
                  subtitle: 'Sisa Waktu: 1 Hari 4 Jam',
                  subtitleColor: Colors.orange.shade700,
                  actionLabel: 'Chat',
                  actionColor: AppColors.primary,
                  avatarColor: Colors.teal.shade100,
                  avatarIcon: Icons.person,
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildSessionCard(
                  name: 'Budi Santoso',
                  role: 'Financial Planner',
                  sessionTitle: 'Virtual Meet (Zoom)',
                  subtitle: 'Jadwal: Besok, 10:00 WIB',
                  subtitleColor: Colors.blue.shade700,
                  actionLabel: 'Detail',
                  actionColor: Colors.blue,
                  avatarColor: Colors.blue.shade100,
                  avatarIcon: Icons.person,
                  statusBadge: 'Menunggu Jadwal',
                  statusBadgeColor: Colors.amber.shade100,
                  statusBadgeTextColor: Colors.amber.shade800,
                  isActive: true,
                ),
                const SizedBox(height: 24),

                // Section: SELESAI
                _buildSectionLabel('SELESAI'),
                const SizedBox(height: 8),
                _buildSessionCard(
                  name: 'PT HaloFin Insurance',
                  role: 'Review Portofolio Asuransi',
                  sessionTitle: '',
                  subtitle: 'Selesai pada: 12 Jan 2026',
                  subtitleColor: Colors.grey.shade500,
                  actionLabel: 'Nilai',
                  actionColor: Colors.grey.shade600,
                  avatarColor: Colors.green.shade100,
                  avatarIcon: Icons.business,
                  isActive: false,
                ),
                const SizedBox(height: 12),
                _buildSessionCard(
                  name: 'Dewi Rahmawati',
                  role: 'Investment Advisor',
                  sessionTitle: '',
                  subtitle: 'Selesai pada: 5 Jan 2026',
                  subtitleColor: Colors.grey.shade500,
                  actionLabel: 'Nilai',
                  actionColor: Colors.grey.shade600,
                  avatarColor: Colors.purple.shade100,
                  avatarIcon: Icons.person,
                  isActive: false,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade500,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSessionCard({
    required String name,
    required String role,
    required String sessionTitle,
    required String subtitle,
    required Color subtitleColor,
    required String actionLabel,
    required Color actionColor,
    required Color avatarColor,
    required IconData avatarIcon,
    bool isActive = false,
    String? statusBadge,
    Color? statusBadgeColor,
    Color? statusBadgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(avatarIcon, size: 24, color: Color.fromRGBO(
                  (avatarColor.r * 255.0).round().clamp(0, 255) ~/ 2,
                  (avatarColor.g * 255.0).round().clamp(0, 255) ~/ 2,
                  (avatarColor.b * 255.0).round().clamp(0, 255) ~/ 2,
                  1.0,
                )),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(role, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              // Action button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: actionColor),
                ),
              ),
            ],
          ),
          if (sessionTitle.isNotEmpty || statusBadge != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
          ],
          if (statusBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: statusBadgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(statusBadge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusBadgeTextColor)),
            ),
          ],
          if (sessionTitle.isNotEmpty)
            Text('Sesi: $sessionTitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          if (sessionTitle.isNotEmpty) const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
