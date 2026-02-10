import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/winter_background.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  static const route = '/shop';

  @override
  State<ShopScreen> createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Skrolbar
  final ScrollController scrollController = ScrollController();

  // ID-jevi kupljenih/posedovanih skinova
  int coins = 450;
  final Set<String> ownedSkins = {'classic'};

  // Lista skinova za grid

  late final List<SkinItem> items = [
    const SkinItem(
      id: 'classic',
      name: 'Classic Santa',
      price: 0,
      assetPath: 'assets/images/Skin1.png',
      isDefault: true,
    ),
    const SkinItem(
      id: 'gold',
      name: 'Gold Winter Santa',
      price: 150,
      assetPath: 'assets/images/Skin2.png',
    ),
    const SkinItem(
      id: 'glasses',
      name: 'Cool Santa',
      price: 250,
      assetPath: 'assets/images/Skin3.png',
    ),
    const SkinItem(
      id: 'snowmanbeard',
      name: 'Snowman with Beard Santa',
      price: 300,
      assetPath: 'assets/images/Skin4.png',
    ),
    const SkinItem(
      id: 'snowman',
      name: 'Snowman santa',
      price: 200,
      assetPath: 'assets/images/Skin5.png',
    ),
    const SkinItem(
      id: 'pipe',
      name: 'Santa with pipe',
      price: 350,
      assetPath: 'assets/images/Skin6.png',
    ),
  ];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final fetchedCoins = (data['coins'] as num?)?.toInt();
      if (fetchedCoins == null) return;

      if (mounted) {
        setState(() {
          coins = fetchedCoins;
        });
      }
    } catch (_) {}
  }

  //Klik na buy
  void buySkin(SkinItem item) {
    final alreadyOwned = ownedSkins.contains(item.id);

    if (alreadyOwned) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ovaj skin već imaš.')));
      return;
    }

    if (coins < item.price) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nemaš dovoljno coinova.')));
      return;
    }

    setState(() {
      coins -= item.price;
      ownedSkins.add(item.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Kupljen: ${item.name}')));
  }

  @override
  Widget build(BuildContext context) {
    // Stil boja
    const Color primaryBlue = Color(0xFF4FC3F7);
    const Color titleBlue = Color(0xFF1565C0);

    return Scaffold(
      body: WinterBackground(
        child: SafeArea(
          child: Stack(
            children: [
              /// GORNJI RED: back dugme + coin badge
              Positioned(
                left: 12,
                top: 12,
                child: Material(
                  color: Colors.white.withOpacity(0.85),
                  shape: const CircleBorder(),
                  elevation: 6,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back, color: titleBlue),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 14,
                top: 12,
                child: CoinBadge(
                  coins: coins,
                  background: const Color(0xFFFFD54F),
                ),
              ),

              /// GLAVNI SADRŽAJ (naslov + grid)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 58),

                        // NASLOV
                        const Text(
                          'Shop',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: titleBlue,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // GRID + SCROLLBAR
                        Expanded(
                          child: Scrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            child: GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.only(bottom: 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isOwned = ownedSkins.contains(item.id);

                                return ShopCard(
                                  item: item,
                                  isOwned: isOwned,
                                  primaryBlue: primaryBlue,
                                  onBuy: () => buySkin(item),
                                  coinGifPath: 'assets/gifs/preview.gif',
                                );
                              },
                            ),
                          ),
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
    );
  }
}

//Model: skin u shopu

class SkinItem {
  final String id;
  final String name;
  final int price;
  final String assetPath;
  final bool isDefault;

  const SkinItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    this.isDefault = false,
  });
}

// Coin Badge (gore desno)
class CoinBadge extends StatelessWidget {
  final int coins;
  final Color background;

  const CoinBadge({super.key, required this.coins, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black26,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GIF coin
          Image.asset(
            'assets/gifs/preview.gif',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          // coin broj
          Text(
            '$coins',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF1B3A57),
            ),
          ),
        ],
      ),
    );
  }
}

// Kartica za jedan skin

class ShopCard extends StatelessWidget {
  final SkinItem item;
  final bool isOwned;
  final Color primaryBlue;
  final VoidCallback onBuy;
  final String coinGifPath;

  const ShopCard({
    super.key,
    required this.item,
    required this.isOwned,
    required this.primaryBlue,
    required this.onBuy,
    required this.coinGifPath,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleBlue = Color(0xFF1565C0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Slika skina
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(item.assetPath, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 10),

          // Naziv
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: titleBlue,
            ),
          ),

          const SizedBox(height: 10),

          // Owned ili cena
          if (isOwned || item.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC8F7D2), // zelenkasto kao na figmi
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Owned',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E7A34),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  coinGifPath,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB87400),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // Buy dugme (plavo kao Play Game)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: (isOwned || item.isDefault) ? null : onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFB0BEC5),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                (isOwned || item.isDefault) ? 'Owned' : 'Buy',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
