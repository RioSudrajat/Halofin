import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ConsultDetailScreen extends StatelessWidget {
  final String consultantId;
  const ConsultDetailScreen({super.key, required this.consultantId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBjtx7h7FjDd3wyfWqRg4PDPSXr4X6ALJw0d8Tr6LDDMwno2KLfdLKfww7Xb_x15wvkXDXUVkXCmS4v-ZpEcM6wFJEFv0qanyMGTPSpMgTonlCwZFeFKQ_17dM5LYGc-AwdSGrLe7l7bQY0LSUvUnrNMPpqssuy7RF3G8Dq65eDnT2TfcOJyKbDXQSDpNlmwA1T6SnyRAKkKxAqa5jyuibGs8cMjvUaZqN4_1NtcPUFDkCZaPe57smpr4dkzg_86MvK0t0T9oLEN_ny',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, Colors.black87],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Sarah Jenkins', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                              SizedBox(height: 4),
                              Text('Senior Tax Consultant • BudgetIn Certified', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified, size: 14, color: Colors.black),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -16.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats Area
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: const [
                              Text('450+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('CLIENTS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 1)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('4.9', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('RATING', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 1)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        Expanded(
                          child: Column(
                            children: const [
                              Text('12 Yr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('EXPERIENCE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),

                  // About Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tentang Konsultan', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Profesional pajak berpengalaman dengan spesialisasi dalam restrukturisasi pajak perusahaan dan perencanaan keuangan strategis. Berdedikasi untuk membantu klien mencapai efisiensi fiskal yang optimal melalui pendekatan yang terstruktur dan patuh hukum.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),

                  // Accordions Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAccordion(context, Icons.psychology, 'Keahlian'),
                        const SizedBox(height: 12),
                        _buildAccordion(context, Icons.verified_user, 'Sertifikasi'),
                        const SizedBox(height: 12),
                        _buildAccordion(context, Icons.school, 'Riwayat Pendidikan'),
                        const SizedBox(height: 12),
                        _buildAccordion(context, Icons.work_history, 'Pengalaman Lapangan'),
                      ],
                    ),
                  ),

                  // Reviews
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ulasan Pengguna', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(color: Colors.grey.shade800, shape: BoxShape.circle),
                                        child: const Center(child: Text('AD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Andi Darmawan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.star, color: Colors.amber, size: 14),
                                        SizedBox(width: 4),
                                        Text('5.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('"Sarah sangat membantu saya dalam merapikan laporan pajak tahunan. Sangat detail dan profesional!"', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding for footer
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 20),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
               Expanded(
                 flex: 2,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Biaya Sesi', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                     Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                       children: const [
                         Text('Rp 250.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         Text('/jam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                       ],
                     ),
                   ],
                 ),
               ),
               Expanded(
                 flex: 3,
                 child: ElevatedButton(
                   onPressed: () => context.push('/booking/$consultantId/service'),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                   ),
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Pesan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                   ),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordion(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        iconColor: Colors.grey.shade400,
        collapsedIconColor: Colors.grey.shade400,
        childrenPadding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Konten tambahan untuk $title akan muncul di sini. Misalnya list skill, detail universitas, dsb.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
