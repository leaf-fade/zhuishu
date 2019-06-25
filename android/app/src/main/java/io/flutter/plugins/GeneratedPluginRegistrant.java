package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.battery.BatteryPlugin;
import io.flutter.plugins.connectivity.ConnectivityPlugin;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import flutter.plugins.screen.screen.ScreenPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    BatteryPlugin.registerWith(registry.registrarFor("io.flutter.plugins.battery.BatteryPlugin"));
    ConnectivityPlugin.registerWith(registry.registrarFor("io.flutter.plugins.connectivity.ConnectivityPlugin"));
    DeviceInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.deviceinfo.DeviceInfoPlugin"));
    FluttertoastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    ScreenPlugin.registerWith(registry.registrarFor("flutter.plugins.screen.screen.ScreenPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
