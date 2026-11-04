// lib/features/customer/screens/customer_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  final bool isEmbedded;

  const CustomerProfileScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final AuthService _authService = AuthService();

  // Profile fields (synced with Firestore)
  String _name = 'Aditya Sharma';
  String _phone = '+91 98112 34567';
  String _email = 'aditya.sharma@gmail.com';
  String _primaryAddress = 'Sector 12, Indirapuram, Ghaziabad';
  String? _profilePhotoUrl;
  String _serviceNotes = 'Ring bell twice. Landmark: Near Apex Mall.';
  String _selectedLanguage = 'English';
  int _walletBalance = 450;

  // Preferences toggles
  bool _whatsappUpdates = true;
  bool _smsAlerts = true;

  // Saved addresses list with label & address
  final List<Map<String, String>> _addresses = [
    {
      'label': 'Home',
      'address': 'Flat 402, Block B, Silver Palms, Sector 18, Noida',
      'isDefault': 'true',
    },
    {
      'label': 'Office',
      'address': 'Plot 14, Tech Boulevard, Sector 127, Noida Expressway',
      'isDefault': 'false',
    },
    {
      'label': 'Parents',
      'address': 'House 88, Nyay Khand 2, Indirapuram, Ghaziabad',
      'isDefault': 'false',
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = _authService.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _name = user.displayName!;
      }
      if (user.email != null && user.email!.isNotEmpty) {
        _email = user.email!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        _phone = user.phoneNumber!;
      }

      // Stream updates from Firestore
      _authService.watchUserProfile(user.uid).listen((profile) {
        if (profile != null && mounted) {
          setState(() {
            if (profile.name.isNotEmpty) _name = profile.name;
            if (profile.email.isNotEmpty) _email = profile.email;
            if (profile.phone.isNotEmpty) _phone = profile.phone;
            if (profile.address != null && profile.address!.isNotEmpty) {
              _primaryAddress = profile.address!;
            }
            if (profile.profilePhotoUrl != null) {
              _profilePhotoUrl = profile.profilePhotoUrl;
            }
          });
        }
      });
    }
  }

  Future<void> _persistProfileToFirestore() async {
    final uid = _authService.currentUserId;
    if (uid != null) {
      try {
        await _authService.updateUserProfile(uid, {
          'name': _name,
          'phone': _phone,
          'email': _email,
          'address': _primaryAddress,
          if (_profilePhotoUrl != null) 'profilePhotoUrl': _profilePhotoUrl,
        });
      } catch (e) {
        debugPrint('Firestore update failed: $e');
      }
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── 1. Full Edit Profile Modal Sheet ─────────────────────────────────────────
  void _openEditProfileModal() {
    final nameCtrl = TextEditingController(text: _name);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);
    final addressCtrl = TextEditingController(text: _primaryAddress);
    final notesCtrl = TextEditingController(text: _serviceNotes);
    final photoUrlCtrl = TextEditingController(text: _profilePhotoUrl ?? '');

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.customerPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.badge_rounded, color: AppColors.customerPrimary, size: 22),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Edit Customer Profile',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 22),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Full Name
                      TextFormField(
                        controller: nameCtrl,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Phone Number
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email Address
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter email' : null,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Primary Address / Area
                      TextFormField(
                        controller: addressCtrl,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your area or city' : null,
                        decoration: InputDecoration(
                          labelText: 'Primary City / Area',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Special Instructions / Landmark for Workers
                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Special Instructions for Workers',
                          hintText: 'e.g. Ring bell twice, Landmark near Axis Bank...',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Profile Photo URL
                      TextFormField(
                        controller: photoUrlCtrl,
                        decoration: InputDecoration(
                          labelText: 'Avatar Image URL (Optional)',
                          hintText: 'https://...',
                          prefixIcon: const Icon(Icons.image_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final updatedName = nameCtrl.text.trim();
                            final updatedPhone = phoneCtrl.text.trim();
                            final updatedEmail = emailCtrl.text.trim();
                            final updatedAddress = addressCtrl.text.trim();
                            final updatedNotes = notesCtrl.text.trim();
                            final updatedPhoto = photoUrlCtrl.text.trim();

                            setState(() {
                              _name = updatedName;
                              _phone = updatedPhone;
                              _email = updatedEmail;
                              _primaryAddress = updatedAddress;
                              _serviceNotes = updatedNotes;
                              _profilePhotoUrl = updatedPhoto.isNotEmpty ? updatedPhoto : null;
                            });

                            Navigator.pop(ctx);
                            HapticFeedback.mediumImpact();

                            await _persistProfileToFirestore();
                            _showMessage('🎉 Profile updated successfully!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.customerPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Save Profile Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 2. Add / Edit Address Dialog ─────────────────────────────────────────────
  void _openAddressDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    final labelCtrl = TextEditingController(text: isEditing ? _addresses[editIndex]['label'] : 'Home');
    final addressCtrl = TextEditingController(text: isEditing ? _addresses[editIndex]['address'] : '');
    bool isDefault = isEditing ? _addresses[editIndex]['isDefault'] == 'true' : false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Edit Address' : 'Add New Address',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: InputDecoration(
                  labelText: 'Address Label (e.g. Home, Office, Studio)',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Complete Address Line',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: isDefault,
                title: const Text('Set as default service location', style: TextStyle(fontSize: 13)),
                activeColor: AppColors.customerPrimary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setDlgState(() => isDefault = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final label = labelCtrl.text.trim();
                final addr = addressCtrl.text.trim();
                if (label.isEmpty || addr.isEmpty) {
                  _showMessage('Please enter both label and address');
                  return;
                }

                setState(() {
                  if (isDefault) {
                    for (var a in _addresses) {
                      a['isDefault'] = 'false';
                    }
                    _primaryAddress = addr;
                  }

                  if (isEditing) {
                    _addresses[editIndex] = {
                      'label': label,
                      'address': addr,
                      'isDefault': isDefault ? 'true' : 'false',
                    };
                  } else {
                    _addresses.insert(0, {
                      'label': label,
                      'address': addr,
                      'isDefault': isDefault ? 'true' : 'false',
                    });
                  }
                });

                Navigator.pop(ctx);
                HapticFeedback.lightImpact();
                _persistProfileToFirestore();
                _showMessage(isEditing ? 'Address updated!' : 'New address added!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.customerPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'Update' : 'Save Address'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAddress(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Address?'),
        content: Text('Are you sure you want to remove "${_addresses[index]['label']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _addresses.removeAt(index));
              Navigator.pop(ctx);
              _showMessage('Address removed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── 3. Edit Instructions Dialog ──────────────────────────────────────────────
  void _openInstructionsDialog() {
    final ctrl = TextEditingController(text: _serviceNotes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Worker Entry & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These notes will be shown to assigned service workers when they navigate to your address.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Landmark, building gate instructions...',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _serviceNotes = ctrl.text.trim());
              Navigator.pop(ctx);
              _showMessage('Instructions updated');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary, foregroundColor: Colors.white),
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

    return Scaffold(
      backgroundColor: AppColors.customerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isEmbedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                onPressed: () => context.go('/customer/home'),
              ),
        title: const Text(
          'Customer Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.customerPrimary),
            tooltip: 'Edit Profile',
            onPressed: _openEditProfileModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // ── Hero Profile Card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.customerPrimary, AppColors.customerSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.customerPrimary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar with edit badge
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: _profilePhotoUrl != null ? NetworkImage(_profilePhotoUrl!) : null,
                            child: _profilePhotoUrl == null
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.customerPrimary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _openEditProfileModal,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 13, color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('GOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Edit Button in Hero
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openEditProfileModal,
                      icon: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                      label: const Text('Edit Personal Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Wallet Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('Wallet: ₹$_walletBalance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _walletBalance += 200);
                            _showMessage('Added ₹200 to Wallet! Balance: ₹$_walletBalance');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: const Text('+ Add ₹200', style: TextStyle(color: AppColors.customerPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Editable Section 1: Personal Details Summary ─────────────
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              actionLabel: 'Edit',
              onAction: _openEditProfileModal,
              child: Column(
                children: [
                  _buildDetailRow(Icons.person, 'Full Name', _name),
                  const Divider(height: 16),
                  _buildDetailRow(Icons.phone, 'Mobile', _phone),
                  const Divider(height: 16),
                  _buildDetailRow(Icons.email, 'Email Address', _email),
                  const Divider(height: 16),
                  _buildDetailRow(Icons.map, 'Primary City/Area', _primaryAddress),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Editable Section 2: Saved Service Addresses ───────────────
            _buildSectionCard(
              title: 'Saved Locations (${_addresses.length})',
              icon: Icons.location_on_outlined,
              actionLabel: '+ Add Address',
              onAction: () => _openAddressDialog(),
              child: Column(
                children: _addresses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isDef = item['isDefault'] == 'true';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDef ? AppColors.customerPrimary.withValues(alpha: 0.04) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDef ? AppColors.customerPrimary.withValues(alpha: 0.3) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item['label'] == 'Home' ? Icons.home_rounded : item['label'] == 'Office' ? Icons.apartment_rounded : Icons.place_rounded,
                          color: AppColors.customerPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item['label'] ?? 'Address',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (isDef) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.customerPrimary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('DEFAULT', style: TextStyle(color: AppColors.customerPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['address'] ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                              onPressed: () => _openAddressDialog(editIndex: idx),
                              tooltip: 'Edit',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                              onPressed: () => _confirmDeleteAddress(idx),
                              tooltip: 'Delete',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── Editable Section 3: Worker Instructions & Landmark ────────
            _buildSectionCard(
              title: 'Worker Entry Instructions',
              icon: Icons.speaker_notes_outlined,
              actionLabel: 'Edit',
              onAction: _openInstructionsDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.customerPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _serviceNotes.isNotEmpty ? _serviceNotes : 'No entry instructions set. Tap edit to add landmark or gate instructions.',
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Editable Section 4: Preferences & Language ────────────────
            _buildSectionCard(
              title: 'App & Communication Preferences',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  // Language Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.language_rounded, size: 18, color: AppColors.customerPrimary),
                          SizedBox(width: 8),
                          Text('Preferred Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          items: const [
                            DropdownMenuItem(value: 'English', child: Text('English')),
                            DropdownMenuItem(value: 'Hindi', child: Text('हिन्दी (Hindi)')),
                            DropdownMenuItem(value: 'Marathi', child: Text('मराठी (Marathi)')),
                            DropdownMenuItem(value: 'Bengali', child: Text('বাংলা (Bengali)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedLanguage = val);
                              _showMessage('Language preference set to $val');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12),

                  // WhatsApp Toggle
                  SwitchListTile(
                    value: _whatsappUpdates,
                    onChanged: (val) {
                      setState(() => _whatsappUpdates = val);
                      _showMessage(val ? 'WhatsApp booking alerts enabled' : 'WhatsApp alerts disabled');
                    },
                    title: const Text('WhatsApp Booking Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Instant pro arrival & status updates', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    activeThumbColor: AppColors.customerPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 8),

                  // SMS Toggle
                  SwitchListTile(
                    value: _smsAlerts,
                    onChanged: (val) {
                      setState(() => _smsAlerts = val);
                    },
                    title: const Text('SMS Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('OTP & payment verification texts', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    activeThumbColor: AppColors.customerPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Switch to Worker Portal ───────────────────────────────────
            GestureDetector(
              onTap: () => context.go('/worker/home'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.customerGradientStart, AppColors.customerGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.handyman_outlined, color: Colors.white, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Want to Earn as a Pro?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Switch to Worker Mode to accept service jobs.', style: TextStyle(color: Color(0xFFD8DADC), fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Account Logout ────────────────────────────────────────────
            _buildSectionCard(
              title: 'Account Settings',
              icon: Icons.shield_outlined,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out of Customer Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Securely sign out and switch profile', style: TextStyle(fontSize: 11, color: Colors.black54)),
                onTap: () async {
                  final router = GoRouter.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to sign out from your Customer profile?'),
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
                  if (confirmed == true) {
                    await AuthService().signOut();
                    if (mounted) router.go('/customer/login');
                  }
                },
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  Icon(icon, size: 18, color: AppColors.customerPrimary),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.customerSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
