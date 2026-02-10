import 'package:cloud_firestore/cloud_firestore.dart';

class SkinModel {
  final String id;
  final String name;
  final int price;
  final bool active;
  final String assetPath;
  final String gameplayAssetPath;
  final DateTime? updatedAt;

  const SkinModel({
    required this.id,
    required this.name,
    required this.price,
    required this.active,
    required this.assetPath,
    required this.gameplayAssetPath,
    this.updatedAt,
  });

  factory SkinModel.fromMap(Map<String, dynamic> data, {required String id}) {
    final updatedAt = data['updatedAt'];
    final priceRaw = data['price'];
    final activeRaw = data['active'];

    int price;
    if (priceRaw is num) {
      price = priceRaw.toInt();
    } else if (priceRaw is String) {
      price = int.tryParse(priceRaw.trim()) ?? 0;
    } else {
      price = 0;
    }

    bool active;
    if (activeRaw is bool) {
      active = activeRaw;
    } else if (activeRaw is num) {
      active = activeRaw != 0;
    } else if (activeRaw is String) {
      active = activeRaw.toLowerCase() == 'true';
    } else {
      active = true;
    }

    return SkinModel(
      id: id,
      name: data['name']?.toString() ?? '',
      price: price,
      active: active,
      assetPath: data['assetPath']?.toString() ?? '',
      gameplayAssetPath: data['gameplayAssetPath']?.toString() ?? '',
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'price': price,
      'active': active,
      'assetPath': assetPath,
      'gameplayAssetPath': gameplayAssetPath,
    };
  }
}
