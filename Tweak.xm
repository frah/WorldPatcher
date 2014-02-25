#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "StackBaseVC.h"
#import "WebVC.h"

/*
 * Hooks
 */
%hook WebVC
- (void)naviSendto:(id)arg1 {
    %log;
    NSLog(@"Call naviSendto:%@",arg1);

    UIActionSheet *as = [[[UIActionSheet alloc] init] autorelease];
    [as setDelegate:self];
    [as addButtonWithTitle:@"Share on Twitter"];
    [as addButtonWithTitle:@"Share on Facebook"];
    [as addButtonWithTitle:@"View on Safari"];
    [as addButtonWithTitle:@"Cancel"];
    as.cancelButtonIndex = 3;
    [as showInView:self.view];
}

%new(v@:@)
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

%new(v@:@i)
- (void)actionSheet:(id)sheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"TapBlock start: %ld", (long)buttonIndex);

    UIWebView *web = MSHookIvar<UIWebView *>(self, "_web");
    NSString *url = [web stringByEvaluatingJavaScriptFromString:@"location.href"];
    NSString *title = [web stringByEvaluatingJavaScriptFromString:@"document.title"];

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
            [self presentViewController:cmpview animated:YES completion:^{
                //[self findTextViewAndMoveToTop:cmpview.view];
                UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                UITextView *textView = [win performSelector:@selector(firstResponder)];
                textView.selectedRange = NSMakeRange(0, 0);
            }];
            //[cmpview release];
        }
    } else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
%end

%ctor {
    %init
}
