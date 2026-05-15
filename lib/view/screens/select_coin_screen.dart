import 'package:factor/model/response/token_response_model.dart';
import 'package:factor/src/config.dart';
import 'package:factor/src/view_model.dart';
import 'package:factor/view/components/chain_badge.dart';
import 'package:factor/view/components/neumorphic_bottom_sheet.dart';
import 'package:factor/view/components/neumorphic_selector.dart';
import 'package:factor/view/components/token_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class SelectCoinScreen extends StatefulWidget {
  const SelectCoinScreen({super.key});

  @override
  State<SelectCoinScreen> createState() => _SelectCoinScreenState();
}

class _SelectCoinScreenState extends State<SelectCoinScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    context.read<ExchangeRateViewModel>().searchTokens(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExchangeRateViewModel>();
    final tokens = viewModel.tokens;
    final isInitialLoading = viewModel.tokensLoading && tokens.isEmpty;
    final isSearching = viewModel.tokenSearchLoading;
    final currentFilter = viewModel.chainFilter;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeumorphicSheetHandle(),
          Text(
            FactorStrings.hdrSelectCoin,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: FactorStrings.hintSearch,
              prefixIcon: Icon(
                FactorIcons.search,
                size: FactorIcons.defaultSize,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: Icon(
                        FactorIcons.close,
                        size: FactorIcons.defaultSize,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Chain filter tabs
          _ChainFilterTabs(
            currentFilter: currentFilter,
            onFilterChanged: viewModel.setChainFilter,
          ),
          const SizedBox(height: 12),
          if (isSearching)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Expanded(
            child: isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : tokens.isEmpty
                ? Center(
                    child: Text(
                      currentFilter == ChainFilter.otherChains
                          ? 'Search to find tokens on other chains'
                          : 'No tokens found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tokens.length,
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      final isSelected = token.id == viewModel.selectedToken?.id;
                      final isFavorite = viewModel.isTokenFavorite(token.id);
                      return Padding(
                        padding: const EdgeInsets.only(right: 4, left: 4),
                        child: NeumorphicSelectorTile(
                          title: token.symbol?.toUpperCase() ?? '--',
                          subtitle: token.name,
                          leading: _TokenLeading(token: token),
                          isSelected: isSelected,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FavoriteStar(
                                isFavorite: isFavorite,
                                onTap: () => viewModel.toggleFavoriteToken(
                                  token.id,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: 8.r),
                                Icon(
                                  FactorIcons.checkCircle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: FactorIcons.defaultSize,
                                ),
                              ],
                            ],
                          ),
                          onTap: () async {
                            if (_isSelecting) return;
                            _isSelecting = true;
                            try {
                              final success = await viewModel.selectToken(
                                token,
                              );
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } finally {
                              if (mounted) {
                                _isSelecting = false;
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Chain filter tab bar widget
class _ChainFilterTabs extends StatelessWidget {
  const _ChainFilterTabs({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final ChainFilter currentFilter;
  final ValueChanged<ChainFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChainFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: EdgeInsets.only(right: 8.r),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Token leading widget with avatar and chain badge
class _TokenLeading extends StatelessWidget {
  const _TokenLeading({required this.token});

  final TokenResponseModel token;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.r,
      height: 40.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TokenAvatar(imageUrl: token.icon, symbol: token.symbol, size: 40),
          // Chain badge positioned at bottom-right of avatar
          if (!token.isSolana)
            Positioned(
              right: -4.r,
              bottom: -4.r,
              child: ChainBadge(token: token),
            ),
        ],
      ),
    );
  }
}

/// Tappable star that toggles favorite state for a token or currency tile.
class _FavoriteStar extends StatelessWidget {
  const _FavoriteStar({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFavorite
        ? theme.colorScheme.primary
        : theme.iconTheme.color?.withValues(alpha: 0.45);
    return InkResponse(
      onTap: onTap,
      radius: 18.r,
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(
          isFavorite ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
          size: FactorIcons.smallSize,
          color: color,
        ),
      ),
    );
  }
}
