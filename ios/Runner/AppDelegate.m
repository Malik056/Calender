#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
        FlutterMethodChannel* nativeChannel = [FlutterMethodChannel
        methodChannelWithName:@"flutter.rapid.programers.calender"
        binaryMessenger:controller];

      [nativeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([@"craeteBackgroudService"  isEqualToString:call.method]) {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Staff Meeting"
        content.body = "Every Tuesday at 2pm"

      result(strNative);
      } else {
        result(FlutterMethodNotImplemented);
      }
}];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
