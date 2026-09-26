import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/order_service.dart';
import '../theme/app_colors.dart';

typedef PageLoader<T> = Future<Paginated<T>> Function(int page);

/// Daftar dengan pull-to-refresh dan infinite scroll untuk endpoint
/// Laravel yang memakai `paginate()`.
///
/// Jika [refreshListenable] berubah (mis. setelah checkout), daftar dimuat ulang.
class PaginatedList<T> extends StatefulWidget {
  const PaginatedList({
    super.key,
    required this.loader,
    required this.itemBuilder,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.refreshListenable,
  });

  final PageLoader<T> loader;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final Listenable? refreshListenable;

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final _scrollController = ScrollController();

  List<T> _items = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.refreshListenable?.addListener(_refresh);
    _refresh();
  }

  @override
  void didUpdateWidget(covariant PaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable?.removeListener(_refresh);
      widget.refreshListenable?.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.refreshListenable?.removeListener(_refresh);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await widget.loader(1);
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _currentPage = page.currentPage;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final page = await widget.loader(_currentPage + 1);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _currentPage = page.currentPage;
        _hasMore = page.hasMore;
      });
    } catch (_) {
      // Pengguna bisa scroll lagi untuk mencoba ulang.
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return _MessageView(icon: Icons.cloud_off, message: _error!, onRetry: _refresh);
    }

    if (_items.isEmpty) {
      return _MessageView(icon: widget.emptyIcon, message: widget.emptyMessage);
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return widget.itemBuilder(context, _items[index]);
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // ListView agar pull-to-refresh tetap bisa dipakai saat kosong/error.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 64, color: AppColors.textMuted),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ],
    );
  }
}
