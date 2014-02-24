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

- (WorldPatcher*)initWithURL:(NSString*)url Title:(NSString*)title;
- (void)tweetURL;
@end

@implementation WorldPatcher
- (WorldPatcher*)initWithURL:(NSString*)url Title:(NSString*)title {
    _url = url;
    _title = title;
    return self;
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
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    WorldPatcher *wp = [[[WorldPatcher alloc] initWithURL:url Title:title] autorelease];
    sheet.delegate = wp;
    [sheet addButtonWithTitle:@"Tweet this"];
    [sheet addButtonWithTitle:@"View on Safari"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    [sheet showInView:self.view];
}
%end

