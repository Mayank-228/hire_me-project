// lib/core/constants/service_categories.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final Color bgColor;
  final String description;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.description,
  });
}

class ServiceCategories {
  static const List<ServiceCategory> all = [
    ServiceCategory(
      id: 'plumber',
      name: 'Plumber',
      icon: '🔧',
      color: AppColors.plumber,
      bgColor: Color(0xFFEFF6FF),
      description: 'Fix leaks, pipes, and plumbing issues',
    ),
    ServiceCategory(
      id: 'electrician',
      name: 'Electrician',
      icon: '⚡',
      color: AppColors.electrician,
      bgColor: Color(0xFFFFFBEB),
      description: 'Wiring, repairs, and electrical work',
    ),
    ServiceCategory(
      id: 'carpenter',
      name: 'Carpenter',
      icon: '🪚',
      color: AppColors.carpenter,
      bgColor: Color(0xFFF5F3FF),
      description: 'Furniture, doors, and woodwork',
    ),
    ServiceCategory(
      id: 'cleaner',
      name: 'Cleaner',
      icon: '🧹',
      color: AppColors.cleaner,
      bgColor: Color(0xFFECFDF5),
      description: 'Home and office cleaning services',
    ),
    ServiceCategory(
      id: 'painter',
      name: 'Painter',
      icon: '🎨',
      color: AppColors.painter,
      bgColor: Color(0xFFFEF2F2),
      description: 'Interior and exterior painting',
    ),
    ServiceCategory(
      id: 'mechanic',
      name: 'Mechanic',
      icon: '🔩',
      color: AppColors.mechanic,
      bgColor: Color(0xFFF9FAFB),
      description: 'Vehicle and bike repairs',
    ),
    ServiceCategory(
      id: 'delivery',
      name: 'Delivery',
      icon: '📦',
      color: AppColors.delivery,
      bgColor: Color(0xFFECFEFF),
      description: 'Quick local deliveries',
    ),
    ServiceCategory(
      id: 'security',
      name: 'Security',
      icon: '🛡️',
      color: AppColors.security,
      bgColor: Color(0xFFEFF6FF),
      description: 'Security guard services',
    ),
    ServiceCategory(
      id: 'gardener',
      name: 'Gardener',
      icon: '🌿',
      color: Color(0xFF16A34A),
      bgColor: Color(0xFFF0FDF4),
      description: 'Garden maintenance and landscaping',
    ),
    ServiceCategory(
      id: 'mason',
      name: 'Mason',
      icon: '🧱',
      color: Color(0xFFB45309),
      bgColor: Color(0xFFFFFBEB),
      description: 'Brickwork, tiles, and construction',
    ),
    ServiceCategory(
      id: 'ac_repair',
      name: 'AC Repair',
      icon: '❄️',
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      description: 'AC installation and repair',
    ),
    ServiceCategory(
      id: 'cook',
      name: 'Cook',
      icon: '👨‍🍳',
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFFF1F2),
      description: 'Home cooking and catering',
    ),
  ];

  static ServiceCategory? getById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }
}
