import 'package:flutter/material.dart';
import '../home_page.dart';
import '../screening_intro_page.dart';
import '../dokter_page.dart';
import '../riwayat_page.dart';
import '../profil_page.dart';

/// Bottom Navigation Bar kustom pada menu skrining yang seragam dengan menu home
class HeartCareBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? activeColor;

  const HeartCareBottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTap,
    this.activeColor,
  });

  static const Color primaryActiveBlue = Color(0xFF1479F5);
  static const Color inactiveColor = Color(0xFF4B5563);

  void _onItemTapped(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScreeningIntroPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PilihDokterPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.home,
            label: 'Home',
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.favorite_border,
            label: 'Skrining',
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.medical_services_outlined,
            label: 'Dokter',
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.description_outlined,
            label: 'Riwayat',
          ),
          _buildNavItem(
            context,
            index: 4,
            icon: Icons.person_outline,
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    final Color itemColor =
        isSelected ? (activeColor ?? primaryActiveBlue) : inactiveColor;

    return InkWell(
      onTap: () => _onItemTapped(context, index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: Center(
              child: Icon(
                icon,
                size: 25,
                color: itemColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: itemColor,
            ),
          ),
        ],
      ),
    );
  }
}