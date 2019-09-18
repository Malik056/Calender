#import <Flutter/Flutter.h>
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "UserNotifications/UserNotifications.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* nativeChannel = [FlutterMethodChannel
                                           methodChannelWithName:@"flutter.rapid.programers.calender"
                                           binaryMessenger:controller];
    
    [nativeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"createEventNotification"  isEqualToString:call.method]) {
            NSString* eventDate = call.arguments[@"event"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss.SSS"];
            NSDate *date = [dateFormatter dateFromString:eventDate];
            
            NSDate *today = [NSDate date];
            NSTimeInterval secondsBetween = [date timeIntervalSinceDate:today];
            int numberOfDays = secondsBetween / 86400;
            if(numberOfDays > 1) {
                NSDateComponents* comps = [[NSDateComponents alloc]init];
                comps.day = -1;
                NSCalendar* calendar = [NSCalendar currentCalendar];
                NSDate* yesterday = [calendar dateByAddingComponents:comps toDate:date options:nil];
                date = yesterday;
            }
            NSLog(@"NSDate:%@",date);
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            [calendar setTimeZone:[NSTimeZone localTimeZone]];
            
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
            
            UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
            NSMutableString* title = call.arguments[@"title"];
            objNotificationContent.title = title;
            NSString* body = @"Starting At: ";
            [body stringByAppendingString:eventDate];
            objNotificationContent.body = [NSString localizedUserNotificationStringForKey:body arguments:nil];
            
            objNotificationContent.sound = [UNNotificationSound defaultSound];
            /// 4. update application icon badge number
            objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
            
            UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
            
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventDate
                                                                                  content:objNotificationContent trigger:trigger];
            /// 3. schedule localNotification
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Local Notification succeeded");
                    result(@"Success");
                }
                else {
                    NSLog(@"Local Notification failed");
                    result(@"Error");
                }
            }];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
