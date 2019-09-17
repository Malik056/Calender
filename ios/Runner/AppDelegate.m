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

        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.weekday = 3  // Tuesday
        dateComponents.hour = 14    // 14:00 hours

        // Create the trigger as a repeating event.    
        let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true)

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
