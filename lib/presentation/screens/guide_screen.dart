import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const _topics = [
    (
      title: 'Buying a Property in Pakistan',
      icon: Icons.home_work_outlined,
      body:
          'Verify the ownership documents (Fard/registry), confirm the property is free of disputes, and get a lawyer to review the sale deed before paying any token amount. Always visit the property in person and check utility connections and society dues.',
    ),
    (
      title: 'Renting Made Easy',
      icon: Icons.vpn_key_outlined,
      body:
          'Ask for a written rent agreement covering rent amount, security deposit, and notice period. Take photos of the property\'s condition before moving in, and confirm who is responsible for maintenance costs.',
    ),
    (
      title: 'Understanding Plot Types',
      icon: Icons.straighten_outlined,
      body:
          'Residential and commercial plots differ in permitted use and taxation. Agricultural land usually cannot be used for construction without conversion approval from the local development authority.',
    ),
    (
      title: 'Installments & Financing',
      icon: Icons.calculate_outlined,
      body:
          'Many developers offer installment plans directly, separate from bank financing. Use the Installment Calculator in Milkiyat Tools to estimate your monthly payments before committing to a plan.',
    ),
    (
      title: 'Avoiding Fraud',
      icon: Icons.shield_outlined,
      body:
          'Never pay the full amount before verifying documents with the relevant land authority. Be cautious of deals priced far below market rate, and always meet sellers at the property, not just online.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Malkiyat Guide')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(topic.icon, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(topic.body, style: const TextStyle(color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          );
        },
      ),
    );
  }
}
