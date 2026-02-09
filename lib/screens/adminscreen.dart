import 'package:flutter/material.dart';
import '../widgets/winter_background.dart';
import '../widgets/my_button.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const route = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<_UserRow> _users = [
    _UserRow(username: 'jovan', email: 'jovan@mail.com', isAdmin: false),
    _UserRow(username: 'ana', email: 'ana@mail.com', isAdmin: false),
    _UserRow(username: 'stefan', email: 'stefan@mail.com', isAdmin: false),
    _UserRow(username: 'admin', email: 'admin@prizegrab.com', isAdmin: true),
  ];

  final List<_SkinItem> _skins = [
    _SkinItem(name: 'Classic Santa', price: 0, active: true),
    _SkinItem(name: 'Gold Winter Santa', price: 150, active: true),
    _SkinItem(name: 'Cool Santa', price: 250, active: true),
    _SkinItem(name: 'Snowman with Beard Santa', price: 300, active: true),
    _SkinItem(name: 'Snowman santa', price: 200, active: false),
    _SkinItem(name: 'Santa with pipe', price: 350, active: true),
  ];

  void _removeUser(int index) {
    setState(() {
      _users.removeAt(index);
    });
  }

  void _toggleSkin(int index, bool value) {
    setState(() {
      _skins[index] = _skins[index].copyWith(active: value);
    });
  }

  void _toggleBan(int index) {
    setState(() {
      _users[index] = _users[index].copyWith(banned: !_users[index].banned);
    });
  }

  void _changePrice(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change price (demo): ${_skins[index].name}')),
    );
  }

  void _changeSkin(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change skin (demo): ${_skins[index].name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        child: _LogoutButton(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.route,
                          ),
                        ),
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
                            child: _users.isEmpty
                                ? const _EmptyState(text: 'No users available')
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _users.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final item = _users[index];
                                      return _UserTile(
                                        user: item,
                                        onDelete: item.isAdmin
                                            ? null
                                            : () => _removeUser(index),
                                        onBanToggle: item.isAdmin
                                            ? null
                                            : () => _toggleBan(index),
                                      );
                                    },
                                  ),
                          ),

                          const SizedBox(height: 12),

                          _SectionCard(
                            title: 'Shop Skins',
                            icon: Icons.storefront_outlined,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _skins.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final skin = _skins[index];
                                return _SkinTile(
                                  skin: skin,
                                  onToggle: (v) => _toggleSkin(index, v),
                                  onChangePrice: () => _changePrice(index),
                                  onChangeSkin: () => _changeSkin(index),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          MyButton(
                            text: 'Save Changes (demo)',
                            decorAsset: 'assets/images/iceEdited.png',
                            decorWidth: 90,
                            decorLeft: -18,
                            decorTop: -6,
                            icon: Icons.save_outlined,
                            isIcy: true,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Changes saved (demo)'),
                                ),
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
  final String username;
  final String email;
  final bool isAdmin;
  final bool banned;

  const _UserRow({
    required this.username,
    required this.email,
    required this.isAdmin,
    this.banned = false,
  });

  _UserRow copyWith({bool? banned}) {
    return _UserRow(
      username: username,
      email: email,
      isAdmin: isAdmin,
      banned: banned ?? this.banned,
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, this.onDelete, this.onBanToggle});

  final _UserRow user;
  final VoidCallback? onDelete;
  final VoidCallback? onBanToggle;

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
              user.username.substring(0, 1).toUpperCase(),
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
          else ...[
            _SmallAction(
              text: user.banned ? 'Unban' : 'Ban',
              onTap: onBanToggle,
              isDanger: user.banned,
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: const Color(0xFFEF4444),
              tooltip: 'Delete user',
            ),
          ],
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

class _SkinItem {
  final String name;
  final int price;
  final bool active;

  const _SkinItem({
    required this.name,
    required this.price,
    required this.active,
  });

  _SkinItem copyWith({bool? active}) {
    return _SkinItem(name: name, price: price, active: active ?? this.active);
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.onToggle,
    required this.onChangePrice,
    required this.onChangeSkin,
  });

  final _SkinItem skin;
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
