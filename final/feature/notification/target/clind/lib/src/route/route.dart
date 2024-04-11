import 'package:feature_notification/clind.dart';
import 'package:flutter/material.dart';
import 'package:notification_di/di.dart';

enum NotificationRoute {
  notification,
  unknown;

  static String encode(NotificationRoute value) => value.path;

  static NotificationRoute decode(String value) => NotificationRoute.values.firstWhere(
        (e) => e.path == value,
        orElse: () => NotificationRoute.unknown,
      );
}

extension NotificationRouteExtension on NotificationRoute {
  String get path {
    if (this == NotificationRoute.notification) return '/$name';
    return '${NotificationRoute.notification.path}/$name';
  }
}

abstract class INotificationRoutes {
  static Route<dynamic> find(RouteSettings settings) {
    final Uri uri = Uri.tryParse(settings.name ?? '') ?? Uri();
    final Map<String, String> queryParameters = {...uri.queryParameters};
    final bool fullscreenDialog = bool.tryParse(queryParameters['fullscreenDialog'] ?? '') ?? false;
    return MaterialPageRoute(
      builder: (context) => findScreen(uri),
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  static Widget findScreen(Uri uri) {
    final NotificationRoute route = NotificationRoute.decode(uri.path);
    switch (route) {
      case NotificationRoute.notification:
        return const NotificationBlocProvider(
          child: NotificationScreen(),
        );
      case NotificationRoute.unknown:
        return const SizedBox();
    }
  }
}

abstract class INotificationRouteTo {
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context, {
    required String path,
    Map<String, String>? queryParameters,
    bool fullscreenDialog = false,
  }) async {
    final Map<String, String> params = {
      if (queryParameters != null) ...queryParameters,
      'fullscreenDialog': fullscreenDialog.toString(),
    };

    final Uri uri = Uri(
      path: path,
      queryParameters: params,
    );

    final Object? result = await Navigator.of(context).pushNamed<Object?>(uri.toString());
    return result as T?;
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context, {
    required NotificationRoute route,
    Map<String, String>? queryParameters,
    bool fullscreenDialog = false,
  }) {
    return pushNamed<T>(
      context,
      path: route.path,
      queryParameters: queryParameters,
      fullscreenDialog: fullscreenDialog,
    );
  }

  static Future<void> notification(BuildContext context) {
    return push<void>(
      context,
      route: NotificationRoute.notification,
    );
  }
}
