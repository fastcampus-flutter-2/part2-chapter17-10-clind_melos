import 'package:core_flutter_bloc/flutter_bloc.dart';
import 'package:core_util/util.dart';
import 'package:feature_community/clind.dart';
import 'package:feature_my/clind.dart';
import 'package:feature_notification/clind.dart';
import 'package:feature_search/clind.dart';
import 'package:flutter/material.dart';
import 'package:notification_domain/domain.dart';
import 'package:notification_presentation/presentation.dart';
import 'package:presentation/presentation.dart';
import 'package:tool_clind_component/component.dart';
import 'package:tool_clind_theme/theme.dart';
import 'package:ui/ui.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
    super.initState();
  }

  Future<void> _refresh() async {
    await context.readFlowBloc<NotificationListCubit>().load();
  }

  Future<void> _landing(String route) async {
    final Uri uri = Uri.tryParse(route) ?? Uri();

    int? tabIndex;
    if (uri.path == CommunityRoute.community.path) {
      tabIndex = 0;
    } else if (uri.path == NotificationRoute.notification.path) {
      tabIndex = 1;
    } else if (uri.path == MyRoute.my.path) {
      tabIndex = 2;
    }

    if (tabIndex != null) {
      context.readFlowBloc<HomeTabCubit>().change(index: tabIndex);

      if (tabIndex == 0) {
        final int nestedTabIndex = switch (uri.queryParameters['type'] ?? '') {
          'popular' => 1,
          _ => 0,
        };
        context.readFlowBloc<HomeNestedTabCubit>().change(index: nestedTabIndex);
      }

      return;
    }

    final CommunityRoute communityRoute = CommunityRoute.decode(uri.path);
    if (communityRoute != CommunityRoute.unknown) {
      Navigator.of(context).push(ICommunityRoutes.find(RouteSettings(name: route)));
      return;
    }

    final NotificationRoute notificationRoute = NotificationRoute.decode(uri.path);
    if (notificationRoute != NotificationRoute.unknown) {
      Navigator.of(context).push(INotificationRoutes.find(RouteSettings(name: route)));
      return;
    }

    final MyRoute myRoute = MyRoute.decode(uri.path);
    if (myRoute != MyRoute.unknown) {
      Navigator.of(context).push(IMyRoutes.find(RouteSettings(name: route)));
      return;
    }

    final SearchRoute searchRoute = SearchRoute.decode(uri.path);
    if (searchRoute != SearchRoute.unknown) {
      Navigator.of(context).push(ISearchRoutes.find(RouteSettings(name: route)));
      return;
    }

    final Route<dynamic> findRoute = IClindRoutes.find(RouteSettings(name: route));
    Navigator.of(context).push(findRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.darkBlack,
      appBar: ClindAppBar(
        context: context,
        title: ClindAppBarTitle.simple(
          context,
          text: '알림',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.5,
            ),
            child: ClindAppBarIconAction(
              icon: ClindIcon.settings(
                color: context.colorScheme.gray300,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: ClindDivider.horizontal(),
        ),
      ),
      body: CoreRefreshIndicator(
        onRefresh: () => _refresh(),
        indicator: ClindIcon.restartAlt(
          color: context.colorScheme.gray600,
        ),
        child: CoreLoadMore(
          onLoadMore: () async {},
          child: FlowBlocBuilder<NotificationListCubit, List<ClindNotification>>(
            builder: (context, state) {
              final List<ClindNotification> items = state.data ?? [];
              return ListView.separated(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final ClindNotification item = items[index];
                  return NotificationTile.item(
                    item,
                    onTap: () => _landing(item.route),
                  );
                },
                separatorBuilder: (context, index) => ClindDivider.horizontal(),
              );
            },
          ),
        ),
      ),
    );
  }
}
