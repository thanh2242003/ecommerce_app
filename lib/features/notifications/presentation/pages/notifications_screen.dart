import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:ecommerce_app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:ecommerce_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:ecommerce_app/features/order/presentation/pages/order_detail_screen.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<NotificationCubit>().initForCurrentUser(refresh: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 160;
    if (_scrollController.position.pixels < threshold) {
      return;
    }

    final cubit = context.read<NotificationCubit>();
    cubit.loadMoreForCurrentUser();
  }

  Future<void> _onRefresh() {
    return context.read<NotificationCubit>().initForCurrentUser(refresh: true);
  }

  IconData _iconForNotification(NotificationModel item) {
    switch (item.type) {
      case 'order':
        return Icons.receipt_long_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.settings_outlined;
      case 'test':
        return Icons.bug_report_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Future<void> _onTapNotification(NotificationModel item) async {
    final cubit = context.read<NotificationCubit>();
    await cubit.markAsRead(item.id);

    if (!mounted) {
      return;
    }

    if (item.type == 'order') {
      final orderId = (item.data['orderId'] ?? item.data['order_id'] ?? '')
          .toString();

      if (orderId.isEmpty) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        titleText: 'Thông báo',
        titleStyle: AppTextStyle.h2.copyWith(color: Colors.black87),
        showBack: false,
        action: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final hasUnreadItems = state.notifications.any(
              (item) => !item.isRead,
            );

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.black87),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                if (value == 'mark_all' && hasUnreadItems) {
                  context
                      .read<NotificationCubit>()
                      .markAllAsReadForCurrentUser();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'mark_all',
                  enabled: hasUnreadItems,
                  child: const Text('Đánh dấu tất cả đã đọc'),
                ),
              ],
            );
          },
        ),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.error == null || state.error!.isEmpty) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        },
        builder: (context, state) {
          if (state.loading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Chưa có thông báo nào')),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        state.notifications.length +
                        (state.loadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 0.5),
                    itemBuilder: (context, index) {
                      if (index == state.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = state.notifications[index];
                      return InkWell(
                        onTap: () => _onTapNotification(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: item.isRead
                                    ? Colors.grey.shade200
                                    : Colors.blue.shade50,
                                child: Icon(
                                  _iconForNotification(item),
                                  size: 18,
                                  color: item.isRead
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                              ),
                              if (!item.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title.isEmpty
                                          ? 'Thông báo'
                                          : item.title,
                                      style: TextStyle(
                                        fontWeight: item.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatTimeAgo(item.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_horiz,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                position: PopupMenuPosition.under,
                                onSelected: (value) {
                                  if (value == 'mark_read' && !item.isRead) {
                                    context
                                        .read<NotificationCubit>()
                                        .markAsRead(item.id);
                                  } else if (value == 'delete') {
                                    context
                                        .read<NotificationCubit>()
                                        .deleteNotification(item.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (!item.isRead)
                                    const PopupMenuItem<String>(
                                      value: 'mark_read',
                                      child: Text('Đánh dấu đã đọc'),
                                    ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Xóa'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime input) {
    final now = DateTime.now();
    final diff = now.difference(input);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return '${input.day}/${input.month}/${input.year}';
  }
}
