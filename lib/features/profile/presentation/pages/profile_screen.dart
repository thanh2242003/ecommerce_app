import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/features/address/presentation/pages/address_screen.dart';
import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_cubit.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/models/user_review_item.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/data/sources/review_api_service.dart';
import 'package:ecommerce_app/features/order/presentation/pages/history_screen.dart';
import 'package:ecommerce_app/features/order/presentation/pages/order_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/pages/login_screen.dart';
import '../bloc/user_cubit.dart';
import '../bloc/user_state.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TokenStorage _tokenStorage = TokenStorage();
  int _pendingCount = 0;
  int _confirmedCount = 0;
  int _shippingCount = 0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadUserIfNeeded();
      await _loadOrderBadgeCountsIfNeeded();
    });
  }

  Future<({String token, String userId})?> _resolveSession() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return (token: authState.accessToken, userId: authState.user.id);
    }

    final token = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return null;
    }

    return (token: token, userId: userId);
  }

  Future<void> _loadUserIfNeeded({bool forceRefresh = false}) async {
    if (!mounted) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final session = await _resolveSession();
    if (session == null || !mounted) {
      return;
    }

    final userCubit = context.read<UserCubit>();
    final userState = userCubit.state;

    final shouldRefreshForDifferentUser =
        authState is AuthAuthenticated &&
        userState is UserLoaded &&
        userState.user.email != authState.user.email;

    if (shouldRefreshForDifferentUser) {
      forceRefresh = true;
    }

    if (!forceRefresh && userState is UserLoaded) {
      return;
    }

    await userCubit.getUser(
      token: session.token,
      userId: session.userId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !mounted) {
      return;
    }

    await context.read<AuthCubit>().logout();
    if (!mounted) {
      return;
    }
    await context.read<AppStartCubit>().goToLogin();
    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openHistoryWithFilter(String filter) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HistoryScreen(initialFilter: filter)),
    );
    if (!mounted) {
      return;
    }
    await _loadOrderBadgeCountsIfNeeded(forceRefresh: true);
  }

  Future<void> _loadOrderBadgeCountsIfNeeded({
    bool forceRefresh = false,
  }) async {
    if (!mounted) {
      return;
    }

    if (!forceRefresh &&
        (_pendingCount > 0 ||
            _confirmedCount > 0 ||
            _shippingCount > 0 ||
            _reviewCount > 0)) {
      return;
    }

    try {
      final repository = OrderRepositoryImpl(
        apiService: OrderApiService(tokenStorage: _tokenStorage),
      );
      final reviewService = ReviewApiService(tokenStorage: _tokenStorage);
      final results = await Future.wait([
        repository.getOrders(),
        reviewService.getUserReviews(page: 1, limit: 100),
      ]);
      final orders = results[0] as List<OrderResponse>;
      final reviews = results[1] as List<UserReviewItem>;
      final reviewedProductIds = reviews
          .map((review) => review.productId.trim())
          .where((productId) => productId.isNotEmpty)
          .toSet();

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingCount = orders
            .where((order) => order.status.toLowerCase() == 'pending')
            .length;
        _confirmedCount = orders
            .where((order) => order.status.toLowerCase() == 'confirmed')
            .length;
        _shippingCount = orders
            .where((order) => order.status.toLowerCase() == 'shipping')
            .length;
        _reviewCount = orders
            .where((order) => order.status.toLowerCase() == 'delivered')
            .fold<int>(0, (count, order) {
              final pendingItems = order.items.where((item) {
                final productId = item.productId.trim();
                return productId.isNotEmpty &&
                    !reviewedProductIds.contains(productId);
              }).length;
              return count + pendingItems;
            });
      });
    } catch (_) {
      // Keep current badge counts when order API fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _loadUserIfNeeded(forceRefresh: true),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is UserLoaded) {
              final user = state.user;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Text(
                            'Tài khoản',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.avatar != null
                              ? NetworkImage(user.avatar!)
                              : null,
                          child: user.avatar == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đơn mua',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () => _openHistoryWithFilter('delivered'),
                              child: const Text(
                                'Xem lịch sử mua hàng >',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _OrderItem(
                              icon: Icons.receipt_long,
                              label: 'Chờ xác nhận',
                              badgeCount: _pendingCount,
                              onTap: () => _openHistoryWithFilter('pending'),
                            ),
                            _OrderItem(
                              icon: Icons.inventory_2_outlined,
                              label: 'Chờ lấy hàng',
                              badgeCount: _confirmedCount,
                              onTap: () => _openHistoryWithFilter('confirmed'),
                            ),
                            _OrderItem(
                              icon: Icons.local_shipping_outlined,
                              label: 'Chờ giao hàng',
                              badgeCount: _shippingCount,
                              onTap: () => _openHistoryWithFilter('shipping'),
                            ),
                            _OrderItem(
                              icon: Icons.star_border,
                              label: 'Đánh giá',
                              badgeCount: _reviewCount,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const OrderReviewScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const _MenuItem(title: 'Thông tin cá nhân'),
                        _MenuItem(
                          title: 'Địa chỉ',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddressScreen(),
                              ),
                            );
                          },
                        ),
                        const _MenuItem(title: 'Yêu thích'),
                        const _MenuItem(title: 'Trợ giúp'),
                        const _MenuItem(title: 'Hỗ trợ'),
                        Spacer(),
                        GestureDetector(
                          onTap: _handleLogout,
                          child: const Center(
                            child: Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback? onTap;

  const _OrderItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon, size: 28),
                if (badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu item widget
class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
