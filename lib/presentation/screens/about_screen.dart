import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Image.asset('assets/icons/app_icon.png', width: 88, height: 88),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('MALKIYAT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('Jaidad Ke Har Baat Ho Asaan', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 28),
          const Text(
            'Malkiyat is Pakistan\'s property portal for buying, selling, and renting homes, plots, and commercial spaces. '
            'Our goal is to make every property transaction transparent and hassle-free — from browsing verified listings '
            'to connecting directly with owners and agents.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Whether you\'re looking for your first home, a commercial space for your business, or a plot to invest in, '
            'Malkiyat brings buyers, sellers, and agents onto one platform built specifically for Pakistan.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                SizedBox(width: 10),
                Text('support@malkiyat.pk', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
