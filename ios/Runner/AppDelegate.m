#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"
@import Firebase;
@import Flutter;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [FIRApp configure];
  [GMSServices provideAPIKey:@"AIzaSyAUyNQ9r00rEwl4AYu9efh-2fOa5iDb7QE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // Override point for customization after application launch.

  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* flavorChannel = [FlutterMethodChannel methodChannelWithName:@"flavor" binaryMessenger:controller];
  [flavorChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
  NSString* flavor = (NSString*)[[NSBundle mainBundle].infoDictionary valueForKey:@"Flavor"];
  result(flavor);
  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
