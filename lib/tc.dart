import 'package:flutter/material.dart';
import 'package:tc_serverside_plugin/events/TCCustomEvent.dart';
import 'package:tc_serverside_plugin/tc_serverside.dart';
import 'dart:io' show Platform;

class TCArguments {
  TCArguments();

  Map<String, dynamic> to_tc() {
    return {};
  }
}

class TC {
  TCServerside serverside = TCServerside();

  late TCObserver tcObserver;

  TC({required int siteId, required int privacyId, required String sourceKey}) {
    tcObserver = TCObserver(tc: this);

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        serverside.initServerSide(siteId, sourceKey);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  TCObserver getTCObserver() {
    return tcObserver;
  }

  Future<void> sendCustomEvent(
      {required String page_name,
      required String key,
      required dynamic value}) async {
    //  await serverside.enableRunningInBackground();
    // await serverside.enableServerSide();
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        Future<void>.delayed(
          const Duration(milliseconds: 100),
          () async {
            serverside.execute(makeTCCustomEvent(
                key: key, value: value, page_name: page_name));
          },
        );
      } catch (e) {
        print(e.toString());
      }
    }
    return;
  }

  static TCCustomEvent makeTCCustomEvent(
      {required String page_name,
      required String key,
      required dynamic value}) {
    var event = TCCustomEvent("custom_event");
    event.pageName = page_name;
    event.pageType = "event_page_type";
    if (value is int) {
      event.addAdditionalPropertyWithIntValue(key, value);
    }
    if (value is List) {
      event.addAdditionalPropertyWithListValue(key, value);
    }
    if (value is Map) {
      event.addAdditionalPropertyWithMapValue(key, value);
    }
    if (value is double) {
      event.addAdditionalPropertyWithDoubleValue(key, value);
    }
    if (value is bool) {
      event.addAdditionalPropertyWithBooleanValue(key, value);
    }
    if (value is String) {
      event.addAdditionalProperty(key, value);
    }
    event.addAdditionalProperty("test_code", "test_code_value");
    return event;
  }
}

class TCObserver extends NavigatorObserver {
  late TC tc;
  TCObserver({required this.tc});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Map<String, dynamic> event = makeEvent("didPush", route, previousRoute);

    Map<String, dynamic> value = event["arguments"].to_tc();

    event["arguments"] = value;
    tc.sendCustomEvent(
        page_name: route.settings.name!, key: "GoRoute", value: event);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Map<String, dynamic> event = makeEvent("didPop", route, previousRoute);

    Map<String, dynamic> value = event["arguments"].to_tc();

    event["arguments"] = value;
    tc.sendCustomEvent(
        page_name: route.settings.name!, key: "GoRoute", value: event);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Map<String, dynamic> event = makeEvent("didRemove", route, previousRoute);

    Map<String, dynamic> value = event["arguments"].to_tc();

    tc.sendCustomEvent(
        page_name: route.settings.name!, key: "GoRoute", value: value);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    Map<String, dynamic> event = makeEvent("didReplace", newRoute!, oldRoute);

    Map<String, dynamic> value = event["arguments"].to_tc();

    tc.sendCustomEvent(
        page_name: newRoute.settings.name!, key: "GoRoute", value: value);
  }

  Map<String, dynamic> makeEvent(
      String action, Route<dynamic> route, Route<dynamic>? previousRoute) {
    var arguments;
    if (route.settings.arguments != null) {
      arguments = route.settings.arguments;
    } else {
      arguments = TCArguments();
    }
    Map<String, dynamic> event = {"action": action, "arguments": arguments};
    if (previousRoute != null) {
      event["previous_route"] = previousRoute.settings.name;
    }
    return event;
  }
}
