#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "StackBaseVC.h"
#import "WebVC.h"

/*
 * Functions
 */
@interface WorldPatcher : NSObject <UIActionSheetDelegate>
@property (nonatomic, retain) UIViewController *view;
@property (retain) NSString *url;
@property (retain) NSString *title;
- (void)findTextViewAndMoveToTop:(UIView *)view;
@end

@implementation WorldPatcher
@synthesize view;
@synthesize url;
@synthesize title;
- (void)findTextViewAndMoveToTop:(UIView *)v {
         if ([v isKindOfClass:[UITextView class]]) {
             UITextView *textView = (UITextView *)v;
             textView.selectedRange = NSMakeRange(0, 0);
             return;
         }
         for (UIView *subview in [v subviews]) {
             [self findTextViewAndMoveToTop:subview];
         }
}
- (void)actionSheet:(id)sheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"TapBlock start: %ld", (long)buttonIndex);
    if (buttonIndex <= 1) {
        NSString *serviceType;
        switch (buttonIndex) {
            case 0:
                serviceType = SLServiceTypeTwitter;
                break;
            case 1:
                serviceType = SLServiceTypeFacebook;
                break;
        }
        if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
            SLComposeViewController *cmpview = [SLComposeViewController composeViewControllerForServiceType:serviceType];
            [cmpview setCompletionHandler:nil];
            [cmpview setInitialText:[NSString stringWithFormat:@" -- %@", title]];
            [cmpview addURL:[NSURL URLWithString:url]];
            [view presentViewController:cmpview animated:YES completion:^{
                [self findTextViewAndMoveToTop:cmpview.view];
            }];
            /*
            [win.rootViewController presentViewController:cmpview animated:YES completion:^{
                UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                UITextView *textView = [win performSelector:@selector(firstResponder)];
                textView.selectedRange = NSMakeRange(0, 0);
            }];
            */
            [cmpview release];
        }
    } else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }

    [view retain];
    [self release];
    self = nil;
}
@end


/*
 * Hooks
 */
%hook WebVC
- (void)naviSendto:(id)arg1 {
    %log;
    WorldPatcher *wp = [[%c(WorldPatcher) alloc] init];
    wp.view = self;

    UIWebView *web = MSHookIvar<UIWebView *>(self, "_web");
    wp.url = [web stringByEvaluatingJavaScriptFromString:@"location.href"];
    wp.title = [web stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"naviSendto: %@, %@", wp.url, wp.title);

    UIActionSheet *as = [[[UIActionSheet alloc] init] autorelease];
    [as setDelegate:wp];
    [as addButtonWithTitle:@"Share on Twitter"];
    [as addButtonWithTitle:@"Share on Facebook"];
    [as addButtonWithTitle:@"View on Safari"];
    [as addButtonWithTitle:@"Cancel"];
    as.cancelButtonIndex = 3;
    [as showInView:self.view];
}
%end

