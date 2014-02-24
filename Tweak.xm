#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import "StackBaseVC.h"
#import "WebVC.h"

/*
 * Functions
 */
@interface WorldPatcher : NSObject <UIActionSheetDelegate> {
    NSString *_url;
    NSString *_title;
}

- (void)runActionWithURL:(NSString *)url title:(NSString *)title view:(UIView *)view;
- (void)tweetURL;
@end

@implementation WorldPatcher
- (void)runActionWithURL:(NSString *)url title:(NSString *)title view:(UIView *)view {
    _url = url;
    _title = title;
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    [sheet setDelegate:self];
    [sheet addButtonWithTitle:@"Tweet this"];
    [sheet addButtonWithTitle:@"View on Safari"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    [sheet showInView:view];
}

- (void)tweetURL {
    TWTweetComposeViewController* vc = [[TWTweetComposeViewController alloc] init];
    [vc setInitialText:[NSString stringWithFormat:@" -- %@", _title]];
    [vc addURL:[NSURL URLWithString:_url]];
    [(UIViewController *)self presentViewController:vc animated:YES completion:^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        UITextView *textView = [win performSelector:@selector(firstResponder)];
        textView.selectedRange = NSMakeRange(0, 0);
    }];
    [vc release];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self tweetURL];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
            break;
       default:
            break;
    }
}
@end

/*
 * Hooks
 */
%hook WebVC
- (void)naviSendto:(id)arg1 {
    UIWebView *web = MSHookIvar<UIWebView *>(self, "_web");
    NSString *url = [web stringByEvaluatingJavaScriptFromString:@"location.href"];
    NSString *title = [web stringByEvaluatingJavaScriptFromString:@"document.title"];
    WorldPatcher *wp = [[[WorldPatcher alloc] init] autorelease];
    [wp runActionWithURL:url title:title view:self.view];
}
%end

