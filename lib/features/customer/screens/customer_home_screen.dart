// lib/features/customer/screens/customer_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/job_request_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/job_service.dart';
import 'customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _homeCategoryFilter = 'All';
  String _categoriesTabSearch = '';

  // Logged-in Customer Profile State
  String _customerName = 'Aditya Sharma';
  String _customerPhone = '+91 98112 34567';
  String _customerEmail = 'aditya.sharma@gmail.com';
  String _customerCity = 'Ghaziabad, Sector 12';
  int _walletBalance = 450;
  bool _isLoggedIn = false;
  String? _userId;

  StreamSubscription<UserModel?>? _userSub;
  StreamSubscription<List<JobRequestModel>>? _jobsSub;
  List<JobRequestModel> _allJobs = [];

  final List<String> _savedAddresses = [
    'Home: Flat 402, Tower B, Lotus Greens, Sector 12',
    'Office: DLF Tech Park, Block C, Noida Sector 62',
  ];

  // Ongoing booking mock linked to logged-in user
  final bool _hasActiveBooking = true;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
    _allJobs = JobService.instance.currentJobs;
    _jobsSub = JobService.instance.allJobsStream.listen((jobs) {
      if (mounted) setState(() => _allJobs = jobs);
    });
  }

  void _loadLoggedInUser() {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      _isLoggedIn = true;
      _userId = currentUser.uid;

      // 1. Initial immediate fill from Firebase Auth user
      if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
        _customerName = currentUser.displayName!;
      }
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        _customerEmail = currentUser.email!;
      }
      if (currentUser.phoneNumber != null && currentUser.phoneNumber!.isNotEmpty) {
        _customerPhone = currentUser.phoneNumber!;
      }

      // 2. Real-time stream from Firestore user profile
      _userSub = authService.watchUserProfile(currentUser.uid).listen((profile) {
        if (profile != null && mounted) {
          setState(() {
            if (profile.name.isNotEmpty) _customerName = profile.name;
            if (profile.email.isNotEmpty) _customerEmail = profile.email;
            if (profile.phone.isNotEmpty) _customerPhone = profile.phone;
            if (profile.address != null && profile.address!.isNotEmpty) {
              _customerCity = profile.address!;
              if (!_savedAddresses.contains(profile.address!)) {
                _savedAddresses.insert(0, profile.address!);
              }
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _jobsSub?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserFirstName() {
    if (_customerName.trim().isEmpty) return 'Customer';
    return _customerName.trim().split(' ').first;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customerBackground,
      body: switch (_currentIndex) {
        0 => _buildHomeTab(),
        1 => _buildCategoriesTab(),
        2 => _buildMessagesTab(),
        _ => _buildCustomerProfileTab(),
      },
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showPostJobRequestSheet,
              backgroundColor: AppColors.customerPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_task),
              label: const Text('Post Request', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.customerSecondary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ── Tab 0: Personalized Home Linked to Logged-in Customer ─────────────────
  Widget _buildHomeTab() {
    final filteredCategories = switch (_homeCategoryFilter) {
      'Repairs' => ServiceCategories.all.where((c) => ['plumber', 'electrician', 'carpenter', 'mason'].contains(c.id)).toList(),
      'Cleaning' => ServiceCategories.all.where((c) => ['cleaner', 'painter', 'gardener'].contains(c.id)).toList(),
      'Appliance' => ServiceCategories.all.where((c) => ['ac_repair', 'mechanic', 'cook'].contains(c.id)).toList(),
      _ => ServiceCategories.all,
    };

    final topPadding = MediaQuery.paddingOf(context).top;
    final headerTopPadding = topPadding > 0 ? topPadding + 10 : 50.0;
    final headerHeight = 200.0 + headerTopPadding;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Personalized Header with Gradient ───────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: headerHeight,
                padding: EdgeInsets.only(top: headerTopPadding, left: 20, right: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.customerGradientStart, AppColors.customerGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Location on left, Notifications & Avatar on right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location Picker
                        InkWell(
                          onTap: _showAddressPickerSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 160),
                                  child: Text(
                                    _customerCity,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),

                        // Action Icons: Logout, Notifications & User Avatar
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                              onPressed: _showLogoutConfirmDialog,
                              tooltip: 'Log Out',
                            ),
                            IconButton(
                              icon: Stack(
                                children: [
                                  const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: _showNotificationsSheet,
                              tooltip: 'Notifications',
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _currentIndex = 3),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Text(
                                  _customerName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
                                  style: const TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Personalized Welcome Title
                    Text(
                      '${_getGreeting()}, ${_getUserFirstName()} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Everyday home help, one tap away.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar overlapping header
              Positioned(
                bottom: -24,
                left: 20,
                right: 20,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.customerPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search plumbers, electricians, cleaners...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (query) {
                            setState(() {
                              _categoriesTabSearch = query;
                              _currentIndex = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          // ── 2. Post Job Request Banner ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showPostJobRequestSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.customerPrimary, AppColors.customerSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.customerPrimary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Need Work Done? Post a Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Appears instantly on workers' screen nearby",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          '+ Post',
                          style: TextStyle(
                            color: AppColors.customerPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildCustomerRequestsList(),

          // ── 2. Active Ongoing Booking Card (Linked to Logged-in Customer) ──
          if (_hasActiveBooking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SERVICE IN PROGRESS',
                              style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.customerSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Arriving ~11:30 AM', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerSecondary, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.customerPrimary,
                          radius: 18,
                          child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kitchen Sink Pipe Leak Repair', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Rajesh Kumar (Master Plumber ★ 4.9)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showMessage('Calling Rajesh Kumar (+91 98765 43210)...'),
                            icon: const Icon(Icons.phone, size: 14),
                            label: const Text('Call Pro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              side: const BorderSide(color: AppColors.customerPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showMessage('Tracking Pro location on live map...'),
                            icon: const Icon(Icons.navigation, size: 14, color: Colors.white),
                            label: const Text('Track Pro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.customerPrimary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (_hasActiveBooking) const SizedBox(height: 18),

          // ── 3. Quick Filter Chips Row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHomeFilterChip('All', 'All Services'),
                  const SizedBox(width: 8),
                  _buildHomeFilterChip('Repairs', '🛠️ Repairs'),
                  const SizedBox(width: 8),
                  _buildHomeFilterChip('Cleaning', '🧹 Cleaning'),
                  const SizedBox(width: 8),
                  _buildHomeFilterChip('Appliance', '⚡ Appliances'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 4. Category Section Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.customerPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── 5. Category Tiles Grid (2-Column) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return _buildCategoryTile(category);
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── 6. Top Verified Pros In Your Area Section ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Pros near $_customerCity',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 4),
                    Text('Verified', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTopProCard(
                  name: 'Rajesh Kumar',
                  trade: 'Master Plumber',
                  initials: 'RK',
                  rating: 4.9,
                  reviews: 124,
                  rate: '₹350/hr',
                  distance: '1.2 km away',
                  onTap: () => context.go('/worker/home'),
                ),
                const SizedBox(width: 12),
                _buildTopProCard(
                  name: 'Sunil Verma',
                  trade: 'Electrician Pro',
                  initials: 'SV',
                  rating: 4.8,
                  reviews: 98,
                  rate: '₹299/hr',
                  distance: '2.4 km away',
                  onTap: () => _showMessage('Selected Sunil Verma (Electrician)'),
                ),
                const SizedBox(width: 12),
                _buildTopProCard(
                  name: 'Anita Roy',
                  trade: 'Deep Cleaning',
                  initials: 'AR',
                  rating: 4.9,
                  reviews: 156,
                  rate: '₹399/visit',
                  distance: '3.1 km away',
                  onTap: () => _showMessage('Selected Anita Roy (Cleaning)'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 7. HireMe Gold Wallet & Benefits Banner ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.customerGradientStart, AppColors.customerGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getUserFirstName()}\'s HireMe Wallet: ₹$_walletBalance',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Gold Member: 10% off automatically applied on all on-demand bookings.',
                          style: TextStyle(color: Color(0xFFD8DADC), fontSize: 11, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTopProCard({
    required String name,
    required String trade,
    required String initials,
    required double rating,
    required int reviews,
    required String rate,
    required String distance,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.customerPrimary,
                  radius: 18,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(trade, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text('$rating ($reviews)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(rate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(distance, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFilterChip(String key, String label) {
    final isSelected = _homeCategoryFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _homeCategoryFilter = key),
      selectedColor: AppColors.customerPrimary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.customerPrimary : Colors.black12),
      ),
    );
  }

  // ── Tab 1: Categories (Full Tiles Catalog) ─────────────────────────────────
  Widget _buildCategoriesTab() {
    final query = _categoriesTabSearch.toLowerCase().trim();
    final categories = query.isEmpty
        ? ServiceCategories.all
        : ServiceCategories.all.where((c) {
            return c.name.toLowerCase().contains(query) || c.description.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.customerBackground,
      appBar: AppBar(
        title: const Text('All Service Categories', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search any trade (e.g. Plumber, AC, Painter)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.customerPrimary),
                  suffixIcon: _categoriesTabSearch.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _categoriesTabSearch = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (val) => setState(() => _categoriesTabSearch = val),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${categories.length} Categories Available',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                ),
                const Row(
                  children: [
                    Icon(Icons.tune, size: 14, color: AppColors.customerSecondary),
                    SizedBox(width: 4),
                    Text('Verified Pros', style: TextStyle(color: AppColors.customerSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No categories matching "$_categoriesTabSearch"', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() => _categoriesTabSearch = ''),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
                        child: const Text('Clear Search', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else
              // ── 2-Column Grid of Category Tiles ────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryTile(categories[index]);
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Reusable Category Tile Widget ──────────────────────────────────────────
  Widget _buildCategoryTile(ServiceCategory category) {
    final startingPrice = switch (category.id) {
      'plumber' => '₹199',
      'electrician' => '₹149',
      'carpenter' => '₹249',
      'cleaner' => '₹299',
      'painter' => '₹499',
      'ac_repair' => '₹399',
      'gardener' => '₹199',
      'cook' => '₹350',
      'mechanic' => '₹299',
      'mason' => '₹450',
      'delivery' => '₹99',
      _ => '₹199',
    };

    final prosCount = switch (category.id) {
      'plumber' => '18 Pros',
      'electrician' => '24 Pros',
      'carpenter' => '12 Pros',
      'cleaner' => '31 Pros',
      'painter' => '15 Pros',
      'ac_repair' => '20 Pros',
      'gardener' => '8 Pros',
      'cook' => '14 Pros',
      'mechanic' => '10 Pros',
      'mason' => '7 Pros',
      'delivery' => '45 Pros',
      _ => '16 Pros',
    };

    return InkWell(
      onTap: () => _showCategoryDetailsSheet(category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: category.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withValues(alpha: 0.28),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Emoji container & Price badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(category.icon, style: const TextStyle(fontSize: 22)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startingPrice,
                    style: TextStyle(
                      color: category.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Category Name & Subtitle Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  category.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom Row: Pros count & Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, size: 13, color: category.color),
                    const SizedBox(width: 2),
                    Text(
                      prosCount,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: category.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 9, color: category.color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Interactive Category Details Bottom Sheet ─────────────────────────────
  void _showCategoryDetailsSheet(ServiceCategory category) {
    final commonTasks = switch (category.id) {
      'plumber' => [
          {'name': 'Tap & Pipe Leak Repair', 'price': '₹249', 'time': '30m'},
          {'name': 'Toilet Cistern Overhaul', 'price': '₹399', 'time': '45m'},
          {'name': 'Water Tank Cleaning', 'price': '₹799', 'time': '90m'},
          {'name': 'Geyser Setup & Mounting', 'price': '₹549', 'time': '60m'},
        ],
      'electrician' => [
          {'name': 'Switchboard & Socket Repair', 'price': '₹199', 'time': '25m'},
          {'name': 'Ceiling Fan Installation', 'price': '₹249', 'time': '35m'},
          {'name': 'MCB & Fuse Tripping Fix', 'price': '₹349', 'time': '40m'},
          {'name': 'Inverter & Battery Wiring', 'price': '₹599', 'time': '60m'},
        ],
      'carpenter' => [
          {'name': 'Door Lock & Latch Fitting', 'price': '₹299', 'time': '40m'},
          {'name': 'Drawer & Hinge Repair', 'price': '₹249', 'time': '30m'},
          {'name': 'Furniture Assembly', 'price': '₹499', 'time': '60m'},
          {'name': 'Curtain Rod & Channel Setup', 'price': '₹249', 'time': '30m'},
        ],
      _ => [
          {'name': 'Standard Inspection & Diagnostic', 'price': '₹199', 'time': '30m'},
          {'name': 'Full Service Overhaul', 'price': '₹499', 'time': '60m'},
          {'name': 'Emergency Instant Repair', 'price': '₹349', 'time': '45m'},
        ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: category.bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: category.color.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(category.icon, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(category.description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),

              const SizedBox(height: 18),

              const Text('Common Services & Pricing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),

              // Task List
              ...commonTasks.map((task) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: category.bgColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: category.color.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: category.color),
                          const SizedBox(width: 8),
                          Text(task['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ],
                      ),
                      Text(
                        '${task['price']} (${task['time']})',
                        style: TextStyle(fontWeight: FontWeight.w900, color: category.color, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Recommended Pro snippet
              if (category.id == 'plumber')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.customerPrimary,
                        radius: 18,
                        child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Featured Pro: Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('⭐ 4.9 (124 reviews) • 15+ Yrs Exp • 1.2 km away', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go('/worker/home');
                        },
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('View Pro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Booking Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showMessage('Searching nearby available ${category.name} pros...');
                  },
                  icon: const Icon(Icons.bolt, color: Colors.white),
                  label: Text('Find Nearby ${category.name}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Address Picker Modal Sheet ─────────────────────────────────────────────
  void _showAddressPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Service Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              ..._savedAddresses.map((addr) {
                final isCurrent = _customerCity == addr;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.customerPrimary.withValues(alpha: 0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isCurrent ? AppColors.customerPrimary : Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Icon(
                      addr.startsWith('Office') ? Icons.business : Icons.home,
                      color: isCurrent ? AppColors.customerPrimary : Colors.grey,
                    ),
                    title: Text(addr, style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500)),
                    trailing: isCurrent ? const Icon(Icons.check_circle, color: AppColors.customerPrimary, size: 18) : null,
                    onTap: () {
                      setState(() => _customerCity = addr);
                      Navigator.pop(ctx);
                      _saveAddressToFirestore(addr);
                      _showMessage('Address switched to $addr');
                    },
                  ),
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAddAddressDialog();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Notifications Bottom Sheet ─────────────────────────────────────────────
  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF10B981), child: Icon(Icons.electric_bolt, color: Colors.white, size: 18)),
                title: const Text('Rajesh Kumar is on his way', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Arriving at Sector 12 in ~15 mins. Tap to track pro live.'),
                trailing: const Text('10m ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMessage('Tracking pro on map...');
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.customerPrimary, child: Icon(Icons.verified, color: Colors.white, size: 18)),
                title: const Text('Booking Confirmed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Kitchen Sink Pipe Leak fixed with standard warranty.'),
                trailing: const Text('25m ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.card_giftcard, color: Colors.white, size: 18)),
                title: const Text('Welcome Gift: ₹150 Off', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Use code WELCOME150 on any home repair job.'),
                trailing: const Text('1d ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Messages ────────────────────────────────────────────────────────
  Widget _buildMessagesTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.customerPrimary,
                child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: const Text('Rajesh Kumar (Plumber)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('I am arriving at Sector 12 in 10 minutes with the replacement valve.'),
              trailing: const Text('10:45 AM', style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () => _showMessage('Opening chat with Rajesh Kumar...'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAddressToFirestore(String newAddress) async {
    final uid = _userId ?? AuthService().currentUserId;
    if (uid != null) {
      try {
        await AuthService().updateUserProfile(uid, {'address': newAddress});
      } catch (_) {}
    }
  }

  void _showAddAddressDialog() {
    final addrCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Saved Address'),
          content: TextField(
            controller: addrCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. Flat 301, Tower A, Sector 62'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final txt = addrCtrl.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _savedAddresses.add(txt);
                    _customerCity = txt;
                  });
                  _saveAddressToFirestore(txt);
                  Navigator.pop(ctx);
                  _showMessage('Address saved!');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── Tab 3: Interactive Customer Profile ────────────────────────────────────
  Widget _buildCustomerProfileTab() {
    return const CustomerProfileScreen(isEmbedded: true);
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your customer account?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              await AuthService().signOut();
              if (mounted) context.go('/customer/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteJob(JobRequestModel job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Job Request?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${job.title}"?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              'This request will be permanently deleted and immediately removed from nearby service workers\' feeds.',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await JobService.instance.deleteJob(job.id);
              HapticFeedback.mediumImpact();
              if (mounted) {
                _showMessage('🗑️ Job request deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete Job'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCustomerRequestsList() {
    final activeRequests = _allJobs;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Your Job Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.customerPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeRequests.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.customerPrimary),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showPostJobRequestSheet,
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Add Request',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.customerPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      if (activeRequests.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text(
                  'No Job Requests Yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add a request for plumbing, electrical or repair work and reach verified pros instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _showPostJobRequestSheet,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Request Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customerPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        )
      else
        ...activeRequests.map((job) {
          final isAccepted = job.status == JobStatus.accepted || job.status == JobStatus.inProgress;
          final isCompleted = job.status == JobStatus.completed;
          final isRejected = job.status == JobStatus.rejected || job.status == JobStatus.cancelled;
          final amount = job.estimatedBudget?.toInt() ?? 450;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAccepted
                      ? const Color(0xFF10B981)
                      : isCompleted
                          ? Colors.blue.shade300
                          : isRejected
                              ? Colors.red.shade300
                              : Colors.orange.shade300,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAccepted
                              ? const Color(0xFFECFDF5)
                              : isCompleted
                                  ? Colors.blue.shade50
                                  : isRejected
                                      ? Colors.red.shade50
                                      : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAccepted
                                  ? Icons.verified
                                  : isCompleted
                                      ? Icons.check_circle
                                      : isRejected
                                          ? Icons.cancel_outlined
                                          : Icons.access_time_filled,
                              size: 13,
                              color: isAccepted
                                  ? const Color(0xFF065F46)
                                  : isCompleted
                                      ? Colors.blue.shade700
                                      : isRejected
                                          ? Colors.red.shade700
                                          : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAccepted
                                  ? 'PRO ASSIGNED & IN PROGRESS'
                                  : isCompleted
                                      ? 'COMPLETED'
                                      : isRejected
                                          ? 'DECLINED BY PRO'
                                          : 'LOOKING FOR NEARBY WORKERS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isAccepted
                                    ? const Color(0xFF065F46)
                                    : isCompleted
                                        ? Colors.blue.shade800
                                        : isRejected
                                            ? Colors.red.shade900
                                            : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹$amount',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.customerPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    job.description.isNotEmpty ? job.description : 'Standard inspection and service required.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          job.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.categoryName,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  if (isAccepted) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showMessage('Calling Pro (${job.workerName ?? "Partner"})...'),
                            icon: const Icon(Icons.phone, size: 14),
                            label: const Text('Call Pro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              side: const BorderSide(color: AppColors.customerPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showMessage('Pro is on the way to your location!'),
                            icon: const Icon(Icons.navigation, size: 14, color: Colors.white),
                            label: const Text('Track Pro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.customerPrimary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  // Delete Request Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAccepted
                            ? 'Pro: ${job.workerName ?? "Assigned"}'
                            : 'Urgency: ${job.urgency}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAccepted ? const Color(0xFF065F46) : Colors.orange.shade800,
                        ),
                      ),
                      InkWell(
                        onTap: () => _confirmDeleteJob(job),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Delete Job',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      const SizedBox(height: 16),
    ];
  }

  void _showPostJobRequestSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final addressCtrl = TextEditingController(text: _customerCity);
    final phoneCtrl = TextEditingController(text: _customerPhone);
    final budgetCtrl = TextEditingController(text: '450');

    String selectedCategory = 'plumber';
    String selectedCategoryName = 'Plumbing';
    String selectedUrgency = 'Urgent';

    final categories = [
      {'id': 'plumber', 'name': 'Plumbing', 'icon': Icons.plumbing},
      {'id': 'electrician', 'name': 'Electrical', 'icon': Icons.bolt},
      {'id': 'carpenter', 'name': 'Carpentry', 'icon': Icons.carpenter},
      {'id': 'painter', 'name': 'Painting', 'icon': Icons.format_paint},
      {'id': 'cleaner', 'name': 'Cleaning', 'icon': Icons.cleaning_services},
      {'id': 'ac_repair', 'name': 'AC Repair', 'icon': Icons.ac_unit},
      {'id': 'mason', 'name': 'Masonry', 'icon': Icons.foundation},
      {'id': 'mechanic', 'name': 'Appliance', 'icon': Icons.build},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_task, color: AppColors.customerPrimary),
                            SizedBox(width: 8),
                            Text('Post a Job Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                          "Appears instantly on workers' screen nearby",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    // Job Title
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Job Title / Problem',
                        hintText: 'e.g. Kitchen Sink Pipe Leak',
                        prefixIcon: const Icon(Icons.edit_note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Selection Chips
                    const Text('Select Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat['id'];
                        return ChoiceChip(
                          avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.customerPrimary),
                          label: Text(cat['name'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.customerPrimary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() {
                                selectedCategory = cat['id'] as String;
                                selectedCategoryName = cat['name'] as String;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Urgency Selector
                    const Text('Urgency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Urgent', 'Today', 'Scheduled'].map((urg) {
                        final isSel = selectedUrgency == urg;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(urg),
                            selected: isSel,
                            selectedColor: urg == 'Urgent' ? Colors.red.shade600 : AppColors.customerSecondary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedUrgency = urg);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Address and Phone
                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        labelText: 'Service Location / Address',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Contact Phone',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: budgetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Budget (₹)',
                              prefixText: '₹',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Problem Details',
                        hintText: 'e.g. Water dripping under sink continuously...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          final address = addressCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          final desc = descCtrl.text.trim();
                          final budget = double.tryParse(budgetCtrl.text.trim()) ?? 450.0;

                          if (title.isEmpty) {
                            _showMessage('Please enter a job title or problem');
                            return;
                          }
                          if (address.isEmpty) {
                            _showMessage('Please provide the service address');
                            return;
                          }

                          Navigator.pop(ctx);

                          await JobService.instance.postJobRequest(
                            customerId: _userId ?? 'cust-',
                            customerName: _customerName,
                            customerPhone: phone.isNotEmpty ? phone : _customerPhone,
                            categoryId: selectedCategory,
                            categoryName: selectedCategoryName,
                            title: title,
                            description: desc.isNotEmpty ? desc : 'Standard on-site inspection and repair needed.',
                            address: address,
                            estimatedBudget: budget,
                            urgency: selectedUrgency,
                          );

                          HapticFeedback.mediumImpact();
                          _showMessage('🎉 Job Request Posted! Workers nearby have been notified.');
                        },
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        label: const Text('Post Job Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.customerPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

