import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/winter_background.dart';
import '../widgets/my_button.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../models/skin_model.dart';
import 'login_screen.dart';
import 'main_menu.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const route = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  final UserService _userService = UserService();
  late final Future<bool> _isAdminFuture;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = _checkIsAdmin();
  }

  Future<bool> _checkIsAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final profile = await _userService.getUserProfile(
      user.uid,
      email: user.email,
    );
    return profile.role == 'admin';
  }

  void _redirectNoAccess() {
    if (_redirected) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nemas pristup.')));
      Navigator.pushReplacementNamed(context, MainMenuScreen.route);
    });
  }

  Future<void> _toggleBan(_UserRow user) async {
    try {
      await _userService.setBanned(user.uid, !user.banned);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _adjustCoins(_UserRow user, int delta) async {
    try {
      await _userService.adjustCoins(user.uid, delta);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _resetSkins(_UserRow user) async {
    try {
      await _userService.resetSkins(user.uid);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _toggleSkin(SkinModel skin, bool value) async {
    try {
      await _adminService.updateSkin(skin.id, active: value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _changePrice(SkinModel skin) async {
    final controller = TextEditingController(text: skin.price.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.pop(context, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;
    try {
      await _adminService.updateSkin(skin.id, price: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _changeSkin(SkinModel skin) async {
    final nameController = TextEditingController(text: skin.name);
    final assetController = TextEditingController(text: skin.assetPath);
    final gameplayController = TextEditingController(
      text: skin.gameplayAssetPath,
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change skin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: assetController,
                decoration: const InputDecoration(labelText: 'Asset path'),
              ),
              TextField(
                controller: gameplayController,
                decoration: const InputDecoration(
                  labelText: 'Gameplay asset path',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'assetPath': assetController.text.trim(),
                'gameplayAssetPath': gameplayController.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;
    try {
      await _adminService.updateSkin(
        skin.id,
        name: result['name'],
        assetPath: result['assetPath'],
        gameplayAssetPath: result['gameplayAssetPath'],
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greska: $e')));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: WinterBackground(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              ),
            ),
          );
        }

        if (snapshot.data != true) {
          _redirectNoAccess();
          return const Scaffold(
            body: WinterBackground(
              child: Center(
                child: Text(
                  'Nemas pristup',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: WinterBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _LogoutButton(onTap: _logout),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Manage users and shop content',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Users',
                                icon: Icons.people_alt_outlined,
                                child: StreamBuilder<List<UserProfile>>(
                                  stream: _userService.streamUsers(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const _EmptyState(
                                        text: 'Greska pri ucitavanju',
                                      );
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      );
                                    }

                                    final users = snapshot.data ?? [];
                                    if (users.isEmpty) {
                                      return const _EmptyState(
                                        text: 'No users available',
                                      );
                                    }

                                    final rows = users.map((user) {
                                      final name = user.username.isNotEmpty
                                          ? user.username
                                          : (user.email.isNotEmpty
                                                ? user.email
                                                : 'Unknown');
                                      return _UserRow(
                                        uid: user.uid,
                                        username: name,
                                        email: user.email.isNotEmpty
                                            ? user.email
                                            : '?',
                                        isAdmin: user.role == 'admin',
                                        banned: user.banned,
                                        coins: user.coins,
                                        role: user.role,
                                        activeSkin: user.equippedSkinId,
                                      );
                                    }).toList();

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: rows.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final item = rows[index];
                                        return _UserTile(
                                          user: item,
                                          onBanToggle: item.isAdmin
                                              ? null
                                              : () => _toggleBan(item),
                                          onAddCoins: item.isAdmin
                                              ? null
                                              : () => _adjustCoins(item, 50),
                                          onRemoveCoins: item.isAdmin
                                              ? null
                                              : () => _adjustCoins(item, -50),
                                          onResetSkins: item.isAdmin
                                              ? null
                                              : () => _resetSkins(item),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              _SectionCard(
                                title: 'Shop Skins',
                                icon: Icons.storefront_outlined,
                                child: StreamBuilder<List<SkinModel>>(
                                  stream: _adminService.streamSkins(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text(
                                          'Greska pri ucitavanju: ${snapshot.error}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      );
                                    }

                                    final skins = snapshot.data ?? [];
                                    if (skins.isEmpty) {
                                      return const _EmptyState(
                                        text: 'No skins available',
                                      );
                                    }

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: skins.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final skin = skins[index];
                                        return _SkinTile(
                                          skin: skin,
                                          onToggle: (v) => _toggleSkin(skin, v),
                                          onChangePrice: () =>
                                              _changePrice(skin),
                                          onChangeSkin: () => _changeSkin(skin),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 14),

                              MyButton(
                                text: 'Save Changes',
                                decorAsset: 'assets/images/iceEdited.png',
                                decorWidth: 90,
                                decorLeft: -18,
                                decorTop: -6,
                                icon: Icons.save_outlined,
                                isIcy: true,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved.')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.logout, size: 18, color: Color(0xFF1E3A8A)),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 14),
            color: Colors.black26,
          ),
        ],
        border: Border.all(color: const Color(0xFFBBD7FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _UserRow {
  final String uid;
  final String username;
  final String email;
  final bool isAdmin;
  final bool banned;
  final int coins;
  final String role;
  final String activeSkin;

  const _UserRow({
    required this.uid,
    required this.username,
    required this.email,
    required this.isAdmin,
    required this.banned,
    required this.coins,
    required this.role,
    required this.activeSkin,
  });
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    this.onBanToggle,
    this.onAddCoins,
    this.onRemoveCoins,
    this.onResetSkins,
  });

  final _UserRow user;
  final VoidCallback? onBanToggle;
  final VoidCallback? onAddCoins;
  final VoidCallback? onRemoveCoins;
  final VoidCallback? onResetSkins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBD7FF), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE8F1FF),
            child: Text(
              user.username.isNotEmpty
                  ? user.username.substring(0, 1).toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Role: ${user.role} | Coins: ${user.coins}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Skin: ${user.activeSkin}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                if (user.banned)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'BANNED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (user.isAdmin)
            const _Badge(text: 'ADMIN')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SmallAction(
                      text: user.banned ? 'Unban' : 'Ban',
                      onTap: onBanToggle,
                      isDanger: user.banned,
                    ),
                    const SizedBox(width: 6),
                    _SmallAction(text: '+50', onTap: onAddCoins),
                    const SizedBox(width: 6),
                    _SmallAction(text: '-50', onTap: onRemoveCoins),
                  ],
                ),
                const SizedBox(height: 6),
                _SmallAction(text: 'Reset Skins', onTap: onResetSkins),
              ],
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBD7FF), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.onToggle,
    required this.onChangePrice,
    required this.onChangeSkin,
  });

  final SkinModel skin;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChangePrice;
  final VoidCallback onChangeSkin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: skin.active ? const Color(0xFFE8F1FF) : const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBD7FF), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.ac_unit, size: 18, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${skin.price} coins',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SmallAction(text: 'Change Price', onTap: onChangePrice),
                  const SizedBox(width: 6),
                  _SmallAction(text: 'Change Skin', onTap: onChangeSkin),
                ],
              ),
              const SizedBox(height: 6),
              Switch(
                value: skin.active,
                onChanged: onToggle,
                activeColor: const Color(0xFF4FC3F7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.text,
    required this.onTap,
    this.isDanger = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDanger ? const Color(0xFFFCA5A5) : const Color(0xFFBBD7FF),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}
