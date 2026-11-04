// lib/features/worker/screens/worker_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/job_request_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/job_service.dart';

// ── Models for Worker Profile ────────────────────────────────────────────────

class ServiceItem {
  final String id;
  final String title;
  final int price;
  final String duration;
  final String description;
  final IconData icon;
  final bool isPopular;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    required this.icon,
    this.isPopular = false,
  });
}

class PortfolioProject {
  final String id;
  final String title;
  final String category;
  final String location;
  final String beforeNotes;
  final String afterNotes;
  final String completedTime;
  final double rating;
  final IconData icon;
  final Color accentColor;

  const PortfolioProject({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.beforeNotes,
    required this.afterNotes,
    required this.completedTime,
    required this.rating,
    required this.icon,
    required this.accentColor,
  });
}

class WorkerReview {
  final String id;
  final String author;
  final String initials;
  final Color avatarColor;
  final int rating;
  final String time;
  final String serviceTag;
  final String comment;
  int helpfulCount;
  bool isHelpfulMarked;

  WorkerReview({
    required this.id,
    required this.author,
    required this.initials,
    required this.avatarColor,
    required this.rating,
    required this.time,
    required this.serviceTag,
    required this.comment,
    required this.helpfulCount,
    this.isHelpfulMarked = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _currentIndex = 0; // Default to Home tab
  bool _isOnline = true;
  int _todayEarnings = 1850;
  int _tasksDoneCount = 4;

  StreamSubscription<List<JobRequestModel>>? _jobsSub;
  List<JobRequestModel> _allJobs = [];

  // ── Worker Profile State ───────────────────────────────────────────────────
  String _workerName = 'Rajesh Kumar';
  String _workerTitle = 'Master Plumber & Sanitary Specialist';
  String _workerPhone = '+91 98765 43210';
  String _workerEmail = 'rajesh.kumar@hireme.pro';
  String _workerLocation = 'Sector 12, Ghaziabad';
  String _serviceRadius = '15 km coverage';
  int _hourlyRate = 350;
  int _inspectionFee = 199;
  String _experienceYears = '15+ Years';
  final double _rating = 4.9;
  int _reviewsCount = 124;
  final int _jobsCompleted = 342;
  final String _responseTime = '< 15 mins';
  final String _onTimeArrival = '99.2%';
  int _selectedAvatarIndex = 0;
  bool _isBioExpanded = false;
  int _profileSubTabIndex = 0; // 0: Overview, 1: Services, 2: Portfolio, 3: Reviews
  String _selectedReviewFilter = 'All';

  String _bio =
      'With over 15 years of master-level experience in residential and commercial plumbing, I take pride in delivering fast, reliable, and leak-proof solutions. Specialized in emergency leak repairs, sanitaryware fittings, motorized booster pump setup, and water line overhauls. 100% transparent pricing with a 30-day workmanship guarantee.';

  // Interactive Lists
  final List<String> _skills = [
    'Pipe Fitting',
    'Leak Detection & Repair',
    'Toilet & Cistern Overhaul',
    'Water Tank Cleaning',
    'Geyser / Heater Setup',
    'Drainage & Unclogging',
    'Sanitaryware Installation',
    'Pressure Booster Pumps',
  ];

  final List<String> _tools = [
    'Thermal Leak Detector',
    'Electric Pipe Threader',
    'Rotary Hammer Drill',
    'Heavy Drain Snake Auger',
    'Digital Pressure Gauge',
    'PPR Hot-Melt Welder',
  ];

  late List<ServiceItem> _services;
  late List<PortfolioProject> _portfolio;
  late List<WorkerReview> _reviews;

  @override
  void initState() {
    super.initState();
    _initProfileData();
    _allJobs = JobService.instance.currentJobs;
    _jobsSub = JobService.instance.allJobsStream.listen((jobs) {
      if (mounted) {
        setState(() {
          _allJobs = jobs;
        });
      }
    });
  }

  @override
  void dispose() {
    _jobsSub?.cancel();
    super.dispose();
  }

  void _initProfileData() {
    _services = [
      const ServiceItem(
        id: 's1',
        title: 'Tap & Pipe Leak Repair',
        price: 249,
        duration: '30 mins',
        description: 'Comprehensive leak detection, washer replacement, and Teflon thread sealing.',
        icon: Icons.plumbing,
        isPopular: true,
      ),
      const ServiceItem(
        id: 's2',
        title: 'Toilet Cistern & Flush Overhaul',
        price: 399,
        duration: '45 mins',
        description: 'Dual flush valve adjustment, siphon fix, inlet diaphragm tuning, and leakage stop.',
        icon: Icons.water_drop,
        isPopular: true,
      ),
      const ServiceItem(
        id: 's3',
        title: 'Water Tank Cleaning & Disinfection',
        price: 799,
        duration: '90 mins',
        description: 'High-pressure mechanized wash, sludge vacuuming, and UV/potassium permanganate sterilizing.',
        icon: Icons.cleaning_services_outlined,
      ),
      const ServiceItem(
        id: 's4',
        title: 'Geyser & Water Heater Setup',
        price: 549,
        duration: '60 mins',
        description: 'Precision mounting, braided inlet hose connection, safety pressure relief valve testing.',
        icon: Icons.heat_pump_outlined,
        isPopular: true,
      ),
      const ServiceItem(
        id: 's5',
        title: 'Bathroom Full Diagnostic Inspection',
        price: 299,
        duration: '40 mins',
        description: 'Full water pressure check, tile seep inspection, trap flow rate test with diagnostic report.',
        icon: Icons.verified_outlined,
      ),
      const ServiceItem(
        id: 's6',
        title: 'Water Purifier / RO Plumbing Line',
        price: 349,
        duration: '35 mins',
        description: 'Dedicated brass valve tap-off and concealed reject water drainage diversion.',
        icon: Icons.filter_alt_outlined,
      ),
    ];

    _portfolio = [
      const PortfolioProject(
        id: 'p1',
        title: 'Concealed Shower Diverter Fitting',
        category: 'Bathroom Remodel',
        location: 'Sector 62, Noida',
        beforeNotes: 'Severe wall seepage from old cracked diverter valve ruining bedroom paint.',
        afterNotes: 'Replaced with 3-in-1 ceramic cartridge diverter with zero tile breakage and leak test.',
        completedTime: 'Yesterday',
        rating: 5.0,
        icon: Icons.shower_outlined,
        accentColor: Color(0xFF10B981),
      ),
      const PortfolioProject(
        id: 'p2',
        title: 'Under-Sink Kitchen Drain Overhaul',
        category: 'Emergency Repair',
        location: 'Indirapuram, Ghaziabad',
        beforeNotes: 'Corroded flexible pipe continuously leaking and creating foul kitchen odor.',
        afterNotes: 'Installed rigid PVC bottle trap with detachable debris collector and airtight rubber seals.',
        completedTime: '3 days ago',
        rating: 5.0,
        icon: Icons.kitchen_outlined,
        accentColor: Color(0xFF3B82F6),
      ),
      const PortfolioProject(
        id: 'p3',
        title: '1,000L Overhead Tank Float Valve',
        category: 'Water Conservation',
        location: 'Raj Nagar Extension',
        beforeNotes: 'Defective plastic ballcock resulting in hundreds of liters overflow every morning.',
        afterNotes: 'Upgraded to heavy-duty forged brass equilibrium float valve with high shutoff pressure.',
        completedTime: '1 week ago',
        rating: 4.9,
        icon: Icons.water_damage_outlined,
        accentColor: Color(0xFFF59E0B),
      ),
      const PortfolioProject(
        id: 'p4',
        title: 'Automatic Water Booster Pump Setup',
        category: 'Pressure System',
        location: 'Vaishali, Sector 4',
        beforeNotes: 'Trickling water pressure on top floor rain shower and washing machine.',
        afterNotes: 'Installed 0.5 HP inline pressure booster pump with automated flow sensor switch.',
        completedTime: '2 weeks ago',
        rating: 5.0,
        icon: Icons.speed_outlined,
        accentColor: Color(0xFF8B5CF6),
      ),
    ];

    _reviews = [
      WorkerReview(
        id: 'r1',
        author: 'Sarah J.',
        initials: 'SJ',
        avatarColor: const Color(0xFF818CF8),
        rating: 5,
        time: '2 days ago',
        serviceTag: 'Kitchen Sink Drain Overhaul',
        comment:
            'Rajesh was prompt, extremely polite, and diagnosed the concealed wall leak in under 10 minutes. He carried all original spare parts and cleaned up the entire workspace before leaving. True master professional!',
        helpfulCount: 14,
      ),
      WorkerReview(
        id: 'r2',
        author: 'David Sharma',
        initials: 'DS',
        avatarColor: const Color(0xFF34D399),
        rating: 5,
        time: '5 days ago',
        serviceTag: 'Geyser & Water Heater Setup',
        comment:
            'Very knowledgeable technician. He noticed my safety valve was improperly grounded and corrected it without extra charge. Highly recommend him for any electrical or plumbing appliance work!',
        helpfulCount: 9,
      ),
      WorkerReview(
        id: 'r3',
        author: 'Pooja Verma',
        initials: 'PV',
        avatarColor: const Color(0xFFF472B6),
        rating: 4,
        time: '1 week ago',
        serviceTag: 'Water Tank Float Valve',
        comment:
            'Arrived on time with proper heavy tools. Cleaned the overflow line and installed the brass valve. Quick and professional service with honest pricing.',
        helpfulCount: 6,
      ),
      WorkerReview(
        id: 'r4',
        author: 'Amitabh Sen',
        initials: 'AS',
        avatarColor: const Color(0xFFFBBF24),
        rating: 5,
        time: '2 weeks ago',
        serviceTag: 'Concealed Shower Diverter',
        comment:
            'Fixed an elusive leak inside the wall tile without cracking a single marble tile! Tested the water pressure three times before signing off. Outstanding workmanship.',
        helpfulCount: 22,
      ),
    ];
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
      backgroundColor: AppColors.workerBackground,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.customerGradientStart, AppColors.customerGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: const Center(
          child: Text('H', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        title: Text(
          switch (_currentIndex) {
            0 => 'Jobs Nearby',
            1 => 'Dashboard & Activity',
            2 => 'Search Services',
            _ => 'Worker Profile',
          },
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _showLogoutConfirmDialog,
          ),
          IconButton(
            tooltip: 'Share Profile',
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: _shareProfile,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 3),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: _buildAvatarIcon(size: 18, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: switch (_currentIndex) {
        0 => _buildHomeTab(),
        1 => _buildDashboardTab(),
        2 => _buildSearchTab(),
        _ => _buildProfileTab(),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.customerPrimary,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your worker account?'),
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
              if (mounted) context.go('/worker/login');
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

  // ── Tab 0: Home ────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    final availableJobs = _allJobs.where((j) => j.status == JobStatus.pending).toList();
    final activeJobs = _allJobs
        .where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Worker Online/Offline Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isOnline ? const Color(0xFFEDE9FE) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isOnline ? AppColors.customerPrimary.withValues(alpha: 0.3) : Colors.black12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOnline ? 'Online • Ready for Jobs' : 'Offline • Paused',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? AppColors.customerPrimary : Colors.black54,
                        ),
                      ),
                      Text(
                        _isOnline ? 'Receiving real-time customer requests' : 'Switch online to accept jobs',
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _isOnline,
                activeColor: AppColors.customerPrimary,
                onChanged: (val) {
                  setState(() => _isOnline = val);
                  _showMessage(_isOnline ? '🟢 You are now ONLINE & receiving jobs' : '⏸️ You are now OFFLINE');
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Active In-Progress Jobs (if accepted)
        if (activeJobs.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.play_circle_fill, color: AppColors.customerPrimary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Active Jobs (In Progress)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.customerPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeJobs.length} Active',
                  style: const TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...activeJobs.map((job) => _buildActiveJobCard(job)),
          const SizedBox(height: 16),
        ],

        // 3. Available Jobs Near You Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Jobs Near You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.customerPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${availableJobs.length} Available',
                style: const TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (availableJobs.isNotEmpty)
          ...availableJobs.map((job) => _buildAvailableJobCard(job))
        else
          _buildNoJobsAvailableBanner(),
      ],
    );
  }

  Widget _buildActiveJobCard(JobRequestModel job) {
    final amount = job.estimatedBudget?.toInt() ?? 450;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.customerPrimary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.customerPrimary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.customerPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.autorenew, color: AppColors.customerPrimary, size: 14),
                    SizedBox(width: 4),
                    Text('IN PROGRESS', style: TextStyle(color: AppColors.customerPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                '₹$amount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          const SizedBox(height: 4),
          Text(job.description, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),

          // Customer info card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.workerSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: AppColors.workerPrimary),
                    const SizedBox(width: 6),
                    Text(job.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.phone, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(job.customerPhone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.address,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMessage('Calling ${job.customerName} (${job.customerPhone})...'),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.workerPrimary,
                    side: const BorderSide(color: AppColors.workerPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMessage('Navigating to: ${job.address}...'),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Navigate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.customerSecondary,
                    side: const BorderSide(color: AppColors.customerSecondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeJobPrompt(job),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: Text('Complete & Collect ₹$amount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.customerPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableJobCard(JobRequestModel job) {
    final amount = job.estimatedBudget?.toInt() ?? 450;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.workerSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: job.urgency == 'Urgent'
                          ? Colors.red.shade50
                          : AppColors.workerPillBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.urgency,
                      style: TextStyle(
                        color: job.urgency == 'Urgent'
                            ? Colors.red.shade700
                            : AppColors.workerPillText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.categoryName,
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '₹$amount',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          const SizedBox(height: 4),
          Text(job.description, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.customerName} • ${job.address}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Working Action Buttons: Reject & Accept Job
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _rejectJobPrompt(job),
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                  label: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.red.shade50.withValues(alpha: 0.35),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await JobService.instance.acceptJob(
                      job.id,
                      workerId: 'worker-1',
                      workerName: _workerName,
                    );
                    _showMessage('🎉 Job Accepted: ${job.title}! Customer notified.');
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text(
                    'Accept Job',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workerPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _rejectJobPrompt(JobRequestModel job) {
    final amount = job.estimatedBudget?.toInt() ?? 450;
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Reject Job Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject "${job.title}"?',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.workerSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(job.customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.address,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This job will be removed from your available jobs list.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Keep Job', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              await JobService.instance.rejectJob(job.id, reason: 'Declined by worker');
              HapticFeedback.mediumImpact();
              _showMessage('❌ Job rejected: ${job.title}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reject Job', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoJobsAvailableBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(Icons.done_all_rounded, size: 48, color: AppColors.customerPrimary),
          const SizedBox(height: 12),
          const Text(
            'All Jobs Accepted or Completed!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'New customer requests will show up here automatically, or post one from the Customer side.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              JobService.instance.resetSampleJobs();
              _showMessage('Sample jobs refreshed!');
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset Demo Requests', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.workerPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _completeJobPrompt(JobRequestModel job) {
    final amount = job.estimatedBudget?.toInt() ?? 450;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.customerPrimary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.customerPrimary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collect & Complete Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Confirm payment collection from customer', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.workerSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Job Task', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Customer', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text(job.customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.customerPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await JobService.instance.completeJob(job.id, finalAmount: amount.toDouble());
                    setState(() {
                      _todayEarnings += amount;
                      _tasksDoneCount += 1;
                    });
                    HapticFeedback.mediumImpact();
                    _showMessage('✅ ₹$amount collected! Added to your today\'s earnings.');
                  },
                  icon: const Icon(Icons.verified, color: Colors.white),
                  label: Text('Confirm ₹$amount Received & Finish', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  // ── Tab 1: Dashboard ───────────────────────────────────────────────────────
  Widget _buildDashboardTab() {
    final completedJobs = _allJobs.where((j) => j.status == JobStatus.completed).toList();
    // Sort with most recent first
    completedJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final int calculatedEarnings = completedJobs.fold<int>(
      0,
      (sum, j) => sum + (j.finalAmount?.toInt() ?? j.estimatedBudget?.toInt() ?? 450),
    );
    final int displayEarnings = calculatedEarnings > _todayEarnings ? calculatedEarnings : _todayEarnings;
    final int displayDoneCount = completedJobs.length > _tasksDoneCount ? completedJobs.length : _tasksDoneCount;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isOnline ? const Color(0xFFEDE9FE) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isOnline ? AppColors.customerPrimary.withValues(alpha: 0.3) : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Availability Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                  const SizedBox(height: 4),
                  Text(_isOnline ? 'Online • Receiving jobs' : 'Offline • Paused', style: TextStyle(fontSize: 13, color: _isOnline ? AppColors.customerPrimary : Colors.grey)),
                ],
              ),
              Switch(
                value: _isOnline,
                activeColor: AppColors.customerPrimary,
                onChanged: (val) {
                  setState(() => _isOnline = val);
                  _showMessage(_isOnline ? 'You are now ONLINE' : 'You are now OFFLINE');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.customerPrimary.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(color: AppColors.customerPrimary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Earnings", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('₹$displayEarnings', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                    const SizedBox(height: 4),
                    const Text('+18% vs yesterday', style: TextStyle(fontSize: 11, color: AppColors.customerSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.customerPrimary.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(color: AppColors.customerPrimary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tasks Done', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('$displayDoneCount Jobs', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                    const SizedBox(height: 4),
                    const Text('100% on time', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Jobs Done Before Section Header ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.customerPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.customerPrimary, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jobs Done Before',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.workerPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.customerPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${completedJobs.length} Completed',
                style: const TextStyle(
                  color: AppColors.customerPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (completedJobs.isEmpty)
          _buildNoJobsDoneBanner()
        else
          ...completedJobs.map((job) => _buildCompletedJobHistoryCard(job)),
      ],
    );
  }

  Widget _buildCompletedJobHistoryCard(JobRequestModel job) {
    final amount = job.finalAmount?.toInt() ?? job.estimatedBudget?.toInt() ?? 450;
    final rating = job.customerRating ?? 5.0;

    // Relative formatted date
    final diff = DateTime.now().difference(job.createdAt);
    final String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = '${diff.inDays}d ago';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.customerPrimary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.workerPillBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.customerPrimary, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: AppColors.customerPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.categoryName,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '₹$amount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.customerPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            job.description,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Client and location info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.workerSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.workerPrimary),
                    const SizedBox(width: 6),
                    Text(
                      job.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '$rating',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.address,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showJobReceiptModal(job),
                  icon: const Icon(Icons.receipt_long_outlined, size: 15),
                  label: const Text('View Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.workerPrimary,
                    side: const BorderSide(color: AppColors.workerPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMessage('Calling ${job.customerName} (${job.customerPhone})...'),
                  icon: const Icon(Icons.call_outlined, size: 15),
                  label: const Text('Call Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.customerSecondary,
                    side: const BorderSide(color: AppColors.customerSecondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoJobsDoneBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.workerSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_toggle_off_rounded, size: 36, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Jobs Done Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Accept jobs from the "Jobs Nearby" tab and complete them to build your completed history and earnings record.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showJobReceiptModal(JobRequestModel job) {
    final amount = job.finalAmount?.toInt() ?? job.estimatedBudget?.toInt() ?? 450;
    final rating = job.customerRating ?? 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.workerPillBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppColors.customerPrimary, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Job Completed & Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Service ID: ${job.id}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.workerSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Title', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Flexible(
                        child: Text(
                          job.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Category', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text(job.categoryName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Customer', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text('${job.customerName} (${job.customerPhone})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Location', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Flexible(
                        child: Text(
                          job.address,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Customer Rating', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text('$rating / 5.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid to You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₹$amount',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.customerPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.workerPillBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.customerPrimary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '30-Day Workmanship Guarantee registered for client.',
                      style: TextStyle(fontSize: 12, color: AppColors.customerPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(bCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.workerPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Search ──────────────────────────────────────────────────────────
  Widget _buildSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search jobs, locations, tasks...',
            prefixIcon: const Icon(Icons.search, color: AppColors.workerPrimary),
            filled: true,
            fillColor: AppColors.workerSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onSubmitted: (query) => _showMessage('Searching for "$query"...'),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Browse by Category Tiles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
            Text('6 Trades', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [
            _buildWorkerCategoryTile('Plumbing', '🔧', const Color(0xFFEFF6FF), AppColors.plumber, '14 jobs'),
            _buildWorkerCategoryTile('Electrical', '⚡', const Color(0xFFFFFBEB), AppColors.electrician, '9 jobs'),
            _buildWorkerCategoryTile('Carpentry', '🪚', const Color(0xFFF5F3FF), AppColors.carpenter, '6 jobs'),
            _buildWorkerCategoryTile('Painting', '🎨', const Color(0xFFFEF2F2), AppColors.painter, '8 jobs'),
            _buildWorkerCategoryTile('Cleaning', '🧹', const Color(0xFFECFDF5), AppColors.cleaner, '12 jobs'),
            _buildWorkerCategoryTile('Appliance', '❄️', const Color(0xFFE0F2FE), const Color(0xFF0284C7), '11 jobs'),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkerCategoryTile(String title, String icon, Color bgColor, Color accentColor, String count) {
    return InkWell(
      onTap: () => _showMessage('Filtered jobs by $title ($count)'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Interactive Worker Profile ───────────────────────────────────────
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── 1. Hero Profile Header ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 24, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.customerGradientStart.withOpacity(0.12),
                  AppColors.workerBackground,
                ],
              ),
            ),
            child: Column(
              children: [
                // Avatar with Camera / Edit Button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPickerSheet,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.workerPrimary.withOpacity(0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: _getAvatarColor(),
                          child: _buildAvatarIcon(size: 58, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _showAvatarPickerSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.workerPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Name & Verified Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _workerName,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _showProIdModal,
                      child: const Tooltip(
                        message: 'Verified Pro. Tap to view ID badge',
                        child: Icon(Icons.verified, color: Color(0xFF0284C7), size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Title & Specialization
                Text(
                  _workerTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Live Availability & Coverage Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _isOnline = !_isOnline);
                        _showMessage(_isOnline ? 'Online: Accepting immediate service requests' : 'Offline: Bookings paused');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isOnline ? const Color(0xFF10B981).withOpacity(0.15) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'Available Now' : 'Offline / Away',
                              style: TextStyle(
                                color: _isOnline ? AppColors.customerPrimary : Colors.black54,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(_serviceRadius, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons: Edit Profile, Share, ID Badge, Settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showEditProfileSheet,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.workerPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCircleIconButton(
                      icon: Icons.badge_outlined,
                      tooltip: 'Pro ID Badge',
                      onTap: _showProIdModal,
                    ),
                    const SizedBox(width: 8),
                    _buildCircleIconButton(
                      icon: Icons.share_outlined,
                      tooltip: 'Share Profile',
                      onTap: _shareProfile,
                    ),
                    const SizedBox(width: 8),
                    _buildCircleIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: 'Account Settings',
                      onTap: _showSettingsSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 2. Performance Stats Grid ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatMetricCard(
                  title: 'Rating',
                  value: '$_rating ★',
                  subtext: '$_reviewsCount reviews',
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () => setState(() => _profileSubTabIndex = 3),
                ),
                const SizedBox(width: 8),
                _buildStatMetricCard(
                  title: 'Completed',
                  value: '$_jobsCompleted',
                  subtext: 'Jobs done',
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.customerSecondary,
                  onTap: () => setState(() => _profileSubTabIndex = 2),
                ),
                const SizedBox(width: 8),
                _buildStatMetricCard(
                  title: 'Response',
                  value: _responseTime,
                  subtext: 'Avg. reply',
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFF0284C7),
                  onTap: () => _showMessage('Fast Responder: 98% inquiries replied within 15 mins!'),
                ),
                const SizedBox(width: 8),
                _buildStatMetricCard(
                  title: 'Rate',
                  value: '₹$_hourlyRate',
                  subtext: 'Per hour',
                  icon: Icons.currency_rupee_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  onTap: _showEditProfileSheet,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 3. Interactive Profile Tabs ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildSubTabButton(0, 'Overview', Icons.info_outline),
                  _buildSubTabButton(1, 'Rates', Icons.receipt_long_outlined),
                  _buildSubTabButton(2, 'Portfolio', Icons.photo_library_outlined),
                  _buildSubTabButton(3, 'Reviews', Icons.star_outline),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 4. Tab Views ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: switch (_profileSubTabIndex) {
              0 => _buildOverviewTabView(),
              1 => _buildServicesTabView(),
              2 => _buildPortfolioTabView(),
              _ => _buildReviewsTabView(),
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.workerPrimary, size: 20),
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.workerSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabButton(int index, String label, IconData icon) {
    final isSelected = _profileSubTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _profileSubTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.workerPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.black87),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab View 0: Overview ───────────────────────────────────────────────────
  Widget _buildOverviewTabView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Me Card with Expand/Collapse
        _buildSectionHeader('About Me', onAction: _showEditProfileSheet, actionLabel: 'Edit'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.workerSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _bio,
                maxLines: _isBioExpanded ? 100 : 3,
                overflow: _isBioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
                child: Text(
                  _isBioExpanded ? 'Read Less ▲' : 'Read More ▼',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Specific Service Details & Credentials
        _buildSectionHeader('Key Highlights & Verification'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.workerSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.history_edu, 'Experience', '$_experienceYears in plumbing & sanitaryware'),
              const Divider(height: 20),
              _buildDetailRow(Icons.verified_user_outlined, 'Verification', 'Govt. Aadhaar & Police Clearance Verified'),
              const Divider(height: 20),
              _buildDetailRow(Icons.timer_outlined, 'On-Time Reliability', '$_onTimeArrival verified on-time arrival rate'),
              const Divider(height: 20),
              _buildDetailRow(Icons.schedule, 'Working Hours', 'Mon - Sat: 8:00 AM - 8:00 PM'),
              const Divider(height: 20),
              _buildDetailRow(Icons.home_repair_service_outlined, 'Inspection Charge', '₹$_inspectionFee (Adjusted in final bill)'),
              const Divider(height: 20),
              _buildDetailRow(Icons.translate, 'Languages', 'Hindi (Fluent), English (Working), Punjabi'),
              const Divider(height: 20),
              _buildDetailRow(Icons.phone_outlined, 'Contact', '$_workerPhone • $_workerEmail'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Skills & Expertise with Add Skill button
        _buildSectionHeader(
          'Skills & Specializations (${_skills.length})',
          onAction: _showAddSkillDialog,
          actionLabel: '+ Add Skill',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _skills.map((skill) => _buildInteractiveSkillChip(skill)).toList(),
        ),

        const SizedBox(height: 20),

        // Equipment & Professional Tools
        _buildSectionHeader(
          'Tools & Equipment Owned (${_tools.length})',
          onAction: _showAddToolDialog,
          actionLabel: '+ Add Tool',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _tools.map((tool) => _buildToolChip(tool)).toList(),
        ),

        const SizedBox(height: 20),

        // Service Guarantee Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.customerGradientStart, AppColors.customerGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HireMe 30-Day Pro Warranty',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All repairs by Rajesh include 30-day rework protection & genuine material billing guarantee.',
                      style: TextStyle(color: Color(0xFFD8DADC), fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAction, String? actionLabel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
          ),
          if (onAction != null && actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.workerPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveSkillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: AppColors.workerPillBg,
      labelStyle: const TextStyle(color: AppColors.workerPillText, fontWeight: FontWeight.bold, fontSize: 12),
      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.workerPillText),
      onDeleted: () {
        setState(() => _skills.remove(skill));
        _showMessage('Removed "$skill"');
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildToolChip(String tool) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.build_circle_outlined, size: 14, color: AppColors.workerPrimary),
          const SizedBox(width: 6),
          Text(tool, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  // ── Tab View 1: Services & Rates ───────────────────────────────────────────
  Widget _buildServicesTabView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Standard Rate Card',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
            ),
            ElevatedButton.icon(
              onPressed: _showAddServiceDialog,
              icon: const Icon(Icons.add, size: 14, color: Colors.white),
              label: const Text('Add Service', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.workerPrimary,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._services.map((item) => _buildServiceRateCard(item)),
      ],
    );
  }

  Widget _buildServiceRateCard(ServiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.workerSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPopular ? AppColors.secondary.withOpacity(0.5) : Colors.black.withOpacity(0.05),
          width: item.isPopular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.workerPillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.workerPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
                          ),
                        ),
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('POPULAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Est. time: ${item.duration}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${item.price}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.description, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => _showMessage('Selected "${item.title}". Contacting customer...'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.workerPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Book Service', style: TextStyle(color: AppColors.workerPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab View 2: Portfolio & Past Projects ──────────────────────────────────
  Widget _buildPortfolioTabView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Past Work & Case Studies (${_portfolio.length})',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
            ),
            ElevatedButton.icon(
              onPressed: _showAddPortfolioDialog,
              icon: const Icon(Icons.add_photo_alternate, size: 14, color: Colors.white),
              label: const Text('Add Work', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.workerPrimary,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._portfolio.map((project) => _buildPortfolioCard(project)),
      ],
    );
  }

  Widget _buildPortfolioCard(PortfolioProject project) {
    return InkWell(
      onTap: () => _showProjectDetailModal(project),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.workerSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: project.accentColor.withOpacity(0.15),
                  radius: 20,
                  child: Icon(project.icon, color: project.accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.workerPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${project.category} • ${project.location}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text('${project.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Before vs After pill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔴 Problem: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                      Expanded(
                        child: Text(project.beforeNotes, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🟢 Solution: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46))),
                      Expanded(
                        child: Text(project.afterNotes, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Completed: ${project.completedTime}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const Row(
                  children: [
                    Text('Tap for details', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 14, color: AppColors.secondary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab View 3: Reviews & Ratings ──────────────────────────────────────────
  Widget _buildReviewsTabView() {
    final filteredReviews = _selectedReviewFilter == 'All'
        ? _reviews
        : _selectedReviewFilter == '5 Stars'
            ? _reviews.where((r) => r.rating == 5).toList()
            : _selectedReviewFilter == '4 Stars'
                ? _reviews.where((r) => r.rating == 4).toList()
                : _reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Rating Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.workerSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text('$_rating', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.workerPrimary)),
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$_reviewsCount Reviews', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar('5 ★', 0.88, '108'),
                    _buildRatingBar('4 ★', 0.09, '12'),
                    _buildRatingBar('3 ★', 0.02, '3'),
                    _buildRatingBar('2 ★', 0.01, '1'),
                    _buildRatingBar('1 ★', 0.00, '0'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filter chips and Write Review Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildReviewFilterChip('All'),
                  const SizedBox(width: 6),
                  _buildReviewFilterChip('5 Stars'),
                  const SizedBox(width: 6),
                  _buildReviewFilterChip('4 Stars'),
                ],
              ),
            ),
            GestureDetector(
              onTap: _showWriteReviewDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.workerPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.rate_review_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Write Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // List of Reviews
        if (filteredReviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('No reviews found for this filter.', style: TextStyle(color: Colors.black54))),
          )
        else
          ...filteredReviews.map((rev) => _buildReviewCardItem(rev)),
      ],
    );
  }

  Widget _buildRatingBar(String label, double ratio, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text(count, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFilterChip(String label) {
    final isSelected = _selectedReviewFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedReviewFilter = label),
      selectedColor: AppColors.workerPrimary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      backgroundColor: AppColors.workerSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildReviewCardItem(WorkerReview rev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.workerSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: rev.avatarColor,
                radius: 18,
                child: Text(rev.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(rev.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                      ],
                    ),
                    Text('${rev.time} • ${rev.serviceTag}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rev.rating,
                  (index) => const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(rev.comment, style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (rev.isHelpfulMarked) {
                      rev.helpfulCount--;
                      rev.isHelpfulMarked = false;
                    } else {
                      rev.helpfulCount++;
                      rev.isHelpfulMarked = true;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rev.isHelpfulMarked ? AppColors.workerPillBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rev.isHelpfulMarked ? AppColors.secondary : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        rev.isHelpfulMarked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        size: 13,
                        color: rev.isHelpfulMarked ? AppColors.workerPrimary : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${rev.helpfulCount})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rev.isHelpfulMarked ? AppColors.workerPrimary : Colors.black54,
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
    );
  }

  // ── Helper Avatar Icon Builder ─────────────────────────────────────────────
  Widget _buildAvatarIcon({required double size, required Color color}) {
    switch (_selectedAvatarIndex) {
      case 1:
        return Icon(Icons.build, size: size, color: color);
      case 2:
        return Icon(Icons.engineering, size: size, color: color);
      case 3:
        return Icon(Icons.shield, size: size, color: color);
      case 4:
        return Icon(Icons.handyman, size: size, color: color);
      case 5:
        return Icon(Icons.water_drop, size: size, color: color);
      default:
        return Icon(Icons.person, size: size, color: color);
    }
  }

  Color _getAvatarColor() {
    switch (_selectedAvatarIndex) {
      case 1:
        return const Color(0xFF0D9488); // Teal
      case 2:
        return const Color(0xFF2563EB); // Navy Blue
      case 3:
        return const Color(0xFF7C3AED); // Purple
      case 4:
        return const Color(0xFFEA580C); // Warm Orange
      case 5:
        return const Color(0xFF0284C7); // Water Blue
      default:
        return AppColors.workerPrimary;
    }
  }

  // ── Modals and Dialogs ─────────────────────────────────────────────────────

  void _shareProfile() {
    Clipboard.setData(ClipboardData(text: 'https://hireme.pro/worker/${_workerName.toLowerCase().replaceAll(' ', '-')}'));
    _showMessage('Profile link copied to clipboard! Share it with clients.');
  }

  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Profile Avatar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
              const SizedBox(height: 6),
              const Text('Select an icon badge representing your professional trade', style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (idx) {
                  final isCurrent = _selectedAvatarIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatarIndex = idx);
                      Navigator.pop(ctx);
                      _showMessage('Avatar updated!');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isCurrent ? AppColors.secondary : Colors.transparent, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: switch (idx) {
                          1 => const Color(0xFF0D9488),
                          2 => const Color(0xFF2563EB),
                          3 => const Color(0xFF7C3AED),
                          4 => const Color(0xFFEA580C),
                          5 => const Color(0xFF0284C7),
                          _ => AppColors.workerPrimary,
                        },
                        child: Icon(
                          switch (idx) {
                            1 => Icons.build,
                            2 => Icons.engineering,
                            3 => Icons.shield,
                            4 => Icons.handyman,
                            5 => Icons.water_drop,
                            _ => Icons.person,
                          },
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _workerName);
    final titleCtrl = TextEditingController(text: _workerTitle);
    final phoneCtrl = TextEditingController(text: _workerPhone);
    final emailCtrl = TextEditingController(text: _workerEmail);
    final locationCtrl = TextEditingController(text: _workerLocation);
    final coverageCtrl = TextEditingController(text: _serviceRadius);
    final expCtrl = TextEditingController(text: _experienceYears);
    final rateCtrl = TextEditingController(text: '$_hourlyRate');
    final feeCtrl = TextEditingController(text: '$_inspectionFee');
    final bioCtrl = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Worker Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Full Name', nameCtrl, Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField('Professional Title', titleCtrl, Icons.work_outline),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Hourly Rate (₹)', rateCtrl, Icons.currency_rupee, isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Inspection Fee (₹)', feeCtrl, Icons.receipt_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Service Base Location', locationCtrl, Icons.location_on_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Experience', expCtrl, Icons.history_edu_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Service Coverage', coverageCtrl, Icons.near_me_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Phone', phoneCtrl, Icons.phone_outlined, isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Email', emailCtrl, Icons.email_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('About Me / Bio', bioCtrl, Icons.description_outlined, maxLines: 4),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _workerName = nameCtrl.text.trim();
                        _workerTitle = titleCtrl.text.trim();
                        _workerPhone = phoneCtrl.text.trim();
                        _workerEmail = emailCtrl.text.trim();
                        _workerLocation = locationCtrl.text.trim();
                        _experienceYears = expCtrl.text.trim().isEmpty ? _experienceYears : expCtrl.text.trim();
                        _serviceRadius = coverageCtrl.text.trim().isEmpty ? _serviceRadius : coverageCtrl.text.trim();
                        _hourlyRate = int.tryParse(rateCtrl.text.trim()) ?? _hourlyRate;
                        _inspectionFee = int.tryParse(feeCtrl.text.trim()) ?? _inspectionFee;
                        _bio = bioCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                      _showMessage('Profile changes saved successfully! ✨');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.workerPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.workerPrimary, size: 20),
        filled: true,
        fillColor: AppColors.workerSurface.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _showAddSkillDialog() {
    final skillCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Skill', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          content: TextField(
            controller: skillCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Geyser Descaling, Solar Plumbing',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final txt = skillCtrl.text.trim();
                if (txt.isNotEmpty) {
                  setState(() => _skills.add(txt));
                  Navigator.pop(ctx);
                  _showMessage('Added skill: "$txt"');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddToolDialog() {
    final toolCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Equipment / Tool', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          content: TextField(
            controller: toolCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Laser Distance Meter, Heat Gun',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final txt = toolCtrl.text.trim();
                if (txt.isNotEmpty) {
                  setState(() => _tools.add(txt));
                  Navigator.pop(ctx);
                  _showMessage('Added tool: "$txt"');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddServiceDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Service & Rate', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Service Title')),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)')),
                TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Est. Duration (e.g. 45 mins)')),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Service Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final price = int.tryParse(priceCtrl.text.trim()) ?? 299;
                final duration = durationCtrl.text.trim().isEmpty ? '45 mins' : durationCtrl.text.trim();
                final desc = descCtrl.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _services.add(ServiceItem(
                      id: 's_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      price: price,
                      duration: duration,
                      description: desc,
                      icon: Icons.handyman_outlined,
                    ));
                  });
                  Navigator.pop(ctx);
                  _showMessage('Added "$title" to your Rate Card!');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
              child: const Text('Add Service', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddPortfolioDialog() {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final beforeCtrl = TextEditingController();
    final afterCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Project to Portfolio', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Project Title')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category (e.g. Leak Fix)')),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
                TextField(controller: beforeCtrl, decoration: const InputDecoration(labelText: 'Problem / Before issue')),
                TextField(controller: afterCtrl, decoration: const InputDecoration(labelText: 'Solution / After result')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _portfolio.insert(
                      0,
                      PortfolioProject(
                        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        category: categoryCtrl.text.trim().isEmpty ? 'Plumbing Work' : categoryCtrl.text.trim(),
                        location: locCtrl.text.trim().isEmpty ? _workerLocation : locCtrl.text.trim(),
                        beforeNotes: beforeCtrl.text.trim().isEmpty ? 'Customer reported damaged fittings.' : beforeCtrl.text.trim(),
                        afterNotes: afterCtrl.text.trim().isEmpty ? 'Fully resolved and pressure tested.' : afterCtrl.text.trim(),
                        completedTime: 'Just now',
                        rating: 5.0,
                        icon: Icons.check_circle_outline,
                        accentColor: const Color(0xFF10B981),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  _showMessage('Added "$title" to portfolio!');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
              child: const Text('Publish', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showProjectDetailModal(PortfolioProject item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: item.accentColor.withOpacity(0.15),
                    radius: 24,
                    child: Icon(item.icon, color: item.accentColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                        Text('${item.category} • ${item.location}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.workerSurface, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildCaseStudyStep('Issue Reported', item.beforeNotes, Icons.error_outline, Colors.red),
                    const Divider(height: 20),
                    _buildCaseStudyStep('Solution Implemented', item.afterNotes, Icons.task_alt, AppColors.customerPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 4),
                      Text('Customer Rating: ${item.rating} / 5.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Text('Completed ${item.completedTime}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showMessage('Case study shared!');
                  },
                  icon: const Icon(Icons.share, color: Colors.white, size: 18),
                  label: const Text('Share Case Study', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workerPrimary,
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

  Widget _buildCaseStudyStep(String title, String detail, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
              const SizedBox(height: 3),
              Text(detail, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  void _showProIdModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('HireMe PRO ID BADGE', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.workerPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.workerPillBg, borderRadius: BorderRadius.circular(8)),
                      child: const Text('ACTIVE', style: TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getAvatarColor(),
                  child: _buildAvatarIcon(size: 44, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(_workerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                Text(_workerTitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.workerSurface, borderRadius: BorderRadius.circular(12)),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID Registration', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('HM-PRO-DEL-8921', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NSDC Skill Cert', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('Level 3 Certified', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Police Verification', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('Cleared (Oct 2024)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showMessage('Digital ID badge saved to gallery!');
                    },
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download ID Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final nameCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'General Plumbing Service');
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add Review / Feedback', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (idx) {
                        final star = idx + 1;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedRating = star),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Icon(
                              star <= selectedRating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Client Name (e.g. Ramesh S.)')),
                    TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Service Performed')),
                    TextField(controller: commentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Review Feedback')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final author = nameCtrl.text.trim().isEmpty ? 'Verified Customer' : nameCtrl.text.trim();
                    final comment = commentCtrl.text.trim().isEmpty ? 'Great on-time plumbing job done!' : commentCtrl.text.trim();
                    final initials = author.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

                    setState(() {
                      _reviews.insert(
                        0,
                        WorkerReview(
                          id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                          author: author,
                          initials: initials.isEmpty ? 'VC' : initials,
                          avatarColor: const Color(0xFF6366F1),
                          rating: selectedRating,
                          time: 'Just now',
                          serviceTag: tagCtrl.text.trim(),
                          comment: comment,
                          helpfulCount: 0,
                        ),
                      );
                      _reviewsCount++;
                    });
                    Navigator.pop(ctx);
                    _showMessage('Thank you! Review published.');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Worker Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.workerPrimary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 16),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: AppColors.workerPrimary),
                title: const Text('Switch to Customer View', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Book handyman & plumbing services'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/customer/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance, color: AppColors.workerPrimary),
                title: const Text('Bank & Payouts', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('HDFC Bank •••• 4821 (₹1,850 pending)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMessage('Payout transferred daily at 11:59 PM.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: AppColors.workerPrimary),
                title: const Text('Job Alerts & Sound', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Enabled for instant incoming jobs'),
                trailing: Switch(
                  value: true,
                  activeColor: AppColors.workerPrimary,
                  onChanged: (v) => _showMessage('Alert preferences saved'),
                ),
              ),
              const Divider(height: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Confirm Sign Out'),
                      content: const Text('Are you sure you want to sign out of HireMe?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Log Out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await AuthService().signOut();
                    if (mounted) context.go('/worker/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


