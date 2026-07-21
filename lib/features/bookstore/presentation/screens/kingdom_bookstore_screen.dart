import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/bookstore/presentation/providers/bookstore_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class KingdomBookstoreScreen extends ConsumerWidget {
  const KingdomBookstoreScreen({super.key});

  Future<void> _launchBuyUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.couldNotOpenStoreLink),),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(bookstoreCategoriesProvider);
    final productsAsync = ref.watch(bookstoreProductsProvider);
    final selectedCategoryId = ref.watch(bookstoreSelectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.kingdomBookstore),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          categoriesAsync.when(
            loading: () => const SizedBox(
              height: 44,
              child: Center(child: LinearProgressIndicator()),
            ),
            error: (e, _) =>
                SizedBox(height: 44, child: Center(child: Text('Error: $e'))),
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, i) {
                    final isAll = i == 0;
                    final category = isAll ? null : categories[i - 1];
                    final isSelected = selectedCategoryId == category?.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(isAll ? 'All' : category!.name),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(bookstoreSelectedCategoryProvider.notifier)
                              .state = category?.id;
                        },
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context)!.noProductsAvailable,),);
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    [
                                      AppColors.primary,
                                      AppColors.tertiary,
                                      AppColors.secondary,
                                    ][i % 3],
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  p.productType == 'Book' ||
                                          p.productType == 'E-Book'
                                      ? Icons.menu_book_rounded
                                      : p.productType == 'Merch'
                                          ? Icons.checkroom_rounded
                                          : Icons.album_rounded,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: theme.textTheme.labelLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.author != null && p.author!.isNotEmpty)
                                  Text(
                                    p.author!,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.formattedPrice,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () => _launchBuyUrl(
                                          p.externalBuyUrl,
                                          context,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(0, 28),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Buy',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
