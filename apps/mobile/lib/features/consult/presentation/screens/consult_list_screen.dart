import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/search_input.dart';
import '../../../../shared/widgets/filter_chip_widget.dart';

class ConsultListScreen extends StatefulWidget {
  const ConsultListScreen({super.key});

  @override
  State<ConsultListScreen> createState() => _ConsultListScreenState();
}

class _ConsultListScreenState extends State<ConsultListScreen> {
  String _activeCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Consultation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.edgeMargin, AppSpacing.sm, AppSpacing.edgeMargin, AppSpacing.sm),
              child: SearchInput(hintText: 'Search consultant or location...'),
            ),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.sm),
              child: Row(
                 children: ['All', 'Tax', 'Investment', 'Insurance', 'Debt', 'Business'].map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChipWidget(
                        label: c,
                        isSelected: _activeCategory == c,
                        onTap: () => setState(() => _activeCategory = c),
                      ),
                    );
                 }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Match Expert Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFEF0),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Bingung mencari konsultan yang cocok?', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
                   const SizedBox(height: 4),
                   Text('Kami akan membantu kamu menemukan konsultan yang sesuai preferensi dan kondisi kamu', style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade500, height: 1.4)),
                   const SizedBox(height: 12),
                   Align(
                     alignment: Alignment.centerRight,
                     child: ElevatedButton(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         foregroundColor: Colors.black,
                         elevation: 0,
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: const [
                           Text('Coba Fitur Match Expert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                           SizedBox(width: 4),
                           Icon(Icons.arrow_forward, size: 16),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Consultant List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Column(
                children: [
                  _buildConsultantCard(
                    context,
                    name: 'Sarah Jenkins',
                    role: 'Senior Tax Consultant',
                    roleColor: Colors.teal.shade700,
                    rating: '4.9',
                    reviews: '124',
                    location: 'Jakarta, Indonesia',
                    tags: ['Corp. Tax', 'Estate Planning', 'Audit'],
                    price: 'Rp 250.000',
                    experience: '12+ Yrs',
                  ),
                  _buildConsultantCard(
                    context,
                    name: 'Mike Thompson',
                    role: 'Financial Planner',
                    roleColor: Colors.blue.shade700,
                    rating: '4.8',
                    reviews: '89',
                    location: 'Jakarta, Indonesia',
                    tags: ['Wealth Mgmt', 'Retirement'],
                    price: 'Rp 185.000',
                    experience: '8+ Yrs',
                  ),
                  _buildConsultantCard(
                    context,
                    name: 'Emily Chen',
                    role: 'Crypto Analyst',
                    roleColor: Colors.purple.shade700,
                    rating: '5.0',
                    reviews: '42',
                    location: 'Banten, Indonesia',
                    tags: ['Blockchain', 'DeFi Strategy', 'NFTs'],
                    price: 'Rp 300.000',
                    experience: '5+ Yrs',
                  ),
                  _buildConsultantCard(
                    context,
                    name: 'David Ross',
                    role: 'Debt Manager',
                    roleColor: Colors.orange.shade700,
                    rating: '4.7',
                    reviews: '156',
                    location: 'Jakarta, Indonesia',
                    tags: ['Consolidation', 'Bankruptcy'],
                    price: 'Rp 200.000',
                    experience: '15+ Yrs',
                    isFullyBooked: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultantCard(
    BuildContext context, {
    required String name,
    required String role,
    required Color roleColor,
    required String rating,
    required String reviews,
    required String location,
    required List<String> tags,
    required String price,
    required String experience,
    bool isFullyBooked = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: isFullyBooked ? null : () => context.push('/consult/detail'),
      child: Opacity(
        opacity: isFullyBooked ? 0.7 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar & Experience Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Icon(Icons.person, color: Colors.grey, size: 32),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isFullyBooked ? Colors.grey.shade200 : AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(experience, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isFullyBooked ? Colors.grey.shade600 : Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Info Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: roleColor)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('$reviews Reviews', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(location, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                )).toList(),
              ),
              const SizedBox(height: 12),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: List.generate(
                    150 ~/ 3,
                    (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Price and CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starting from', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(width: 4),
                          Text('/hr', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isFullyBooked ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFullyBooked ? Colors.grey.shade100 : AppColors.primary,
                      foregroundColor: isFullyBooked ? Colors.grey.shade400 : Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isFullyBooked ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isFullyBooked ? 'Fully Booked' : 'Schedule', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(isFullyBooked ? Icons.event_busy : Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
