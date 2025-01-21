import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/services/ad_manager.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/purchase_provider.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';

final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final purchaseService = ref.read(purchaseServiceProvider);
  return purchaseService.getProducts();
});

class CreditPackage {
  final int credits;
  final ProductDetails productDetails;
  final String Function(BuildContext) getDescription;

  const CreditPackage({
    required this.credits,
    required this.productDetails,
    required this.getDescription,
  });
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _handleWatchAd(WidgetRef ref) async {
    final adManager = AdManager();
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    if (await adManager.showRewardedAd()) {
      await creditsNotifier.addCredits(1); // Reklam izleme başına 1 kredi
    }
  }

  void _handlePurchase(WidgetRef ref, ProductDetails product) async {
    final purchaseService = ref.read(purchaseServiceProvider);
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    try {
      final success = await purchaseService.buyProduct(product);
      if (success) {
        // Kredi miktarı ürün ID'sine göre belirlenir
        switch (product.id) {
          case 'credits_10':
            await creditsNotifier.addCredits(10);
            break;
          case 'credits_25':
            await creditsNotifier.addCredits(25);
            break;
          case 'credits_50':
            await creditsNotifier.addCredits(55); // 50 + 5 bonus
            break;
          case 'credits_100':
            await creditsNotifier.addCredits(115); // 100 + 15 bonus
            break;
        }
      }
    } catch (e) {
      print('Satın alma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final credits = ref.watch(aiCreditsProvider);
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.medium(
            title: Text(l10n.profileTab),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            pinned: true,
            actions: [
              // Dil değiştirme butonu
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentLocale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    ref.read(localeProvider.notifier).toggleLocale();
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kredi Kartı
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF16213E),
                          Color(0xFF0F3460),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16213E).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.remainingCredits,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          l10n.credits(credits),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reklam İzle Butonu
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF533483),
                          Color(0xFF0F3460),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF533483).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleWatchAd(ref),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.watchAdForCredit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Kredi Paketleri Grid
                  products.when(
                    data: (productList) => GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: [
                        _CreditPackageCard(
                          title: '10',
                          subtitle: 'AI Çizim\nKredisi',
                          price: productList
                              .firstWhere((p) => p.id == 'credits_10')
                              .price,
                          product: productList
                              .firstWhere((p) => p.id == 'credits_10'),
                          onTap: (product) => _handlePurchase(ref, product),
                        ),
                        _CreditPackageCard(
                          title: '25',
                          subtitle: 'AI Çizim\nKredisi',
                          price: productList
                              .firstWhere((p) => p.id == 'credits_25')
                              .price,
                          product: productList
                              .firstWhere((p) => p.id == 'credits_25'),
                          isPopular: true,
                          onTap: (product) => _handlePurchase(ref, product),
                        ),
                        _CreditPackageCard(
                          title: '50',
                          subtitle: 'AI Çizim\nKredisi',
                          price: productList
                              .firstWhere((p) => p.id == 'credits_50')
                              .price,
                          product: productList
                              .firstWhere((p) => p.id == 'credits_50'),
                          showBonus: true,
                          bonusAmount: '+5',
                          onTap: (product) => _handlePurchase(ref, product),
                        ),
                        _CreditPackageCard(
                          title: '100',
                          subtitle: 'AI Çizim\nKredisi',
                          price: productList
                              .firstWhere((p) => p.id == 'credits_100')
                              .price,
                          product: productList
                              .firstWhere((p) => p.id == 'credits_100'),
                          showBonus: true,
                          bonusAmount: '+15',
                          onTap: (product) => _handlePurchase(ref, product),
                        ),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Ürünler yüklenirken hata oluştu: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditPackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final ProductDetails product;
  final bool isPopular;
  final Function(ProductDetails) onTap;
  final bool showBonus;
  final String bonusAmount;

  const _CreditPackageCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.product,
    this.isPopular = false,
    required this.onTap,
    this.showBonus = false,
    this.bonusAmount = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPopular
              ? const [Color(0xFF533483), Color(0xFF0F3460)]
              : const [Color(0xFF16213E), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(product),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'En Popüler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (showBonus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bonus $bonusAmount',
                      style: const TextStyle(
                        color: Color(0xFFE94560),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
