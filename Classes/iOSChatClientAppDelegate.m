//
//  iOSChatClientAppDelegate.m
//  iOSChatClient


#import "iOSChatClientAppDelegate.h"
#import "iOSChatClientViewController.h"

@implementation iOSChatClientAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
