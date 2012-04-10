//
//  iOSChatClientAppDelegate.h
//  iOSChatClient

#import <UIKit/UIKit.h>

@class iOSChatClientViewController;

@interface iOSChatClientAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iOSChatClientViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iOSChatClientViewController *viewController;

@end

