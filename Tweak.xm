#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
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
    _url = [[NSString stringWithString:url] retain];
    _title = [[NSString stringWithString:title] retain];
    NSLog(@"runActionWithURL: %@, %@", _url, _title);
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    [sheet setDelegate:self];
    [sheet addButtonWithTitle:@"Tweet this"];
    [sheet addButtonWithTitle:@"View on Safari"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    [sheet showInView:view];
}

- (void)tweetURL {
    NSLog(@"call tweetURL");
    NSLog(@"args: %@, %@", _url, _title);
    NSString *serviceType = SLServiceTypeTwitter;
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *cmpview = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [cmpview setCompletionHandler:nil];
        [cmpview setInitialText:[NSString stringWithFormat:@" -- %@", _title]];
        [cmpview addURL:[NSURL URLWithString:_url]];
    }
    [(UIViewController *)self presentViewController:cmpview animated:YES completion:^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        UITextView *textView = [win performSelector:@selector(firstResponder)];
        textView.selectedRange = NSMakeRange(0, 0);
    }];
    [vc release];
}

-(void)actionSheet:(UIActionSheet*)actionSheet
        clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"actionSheet index:%ld", (long)buttonIndex);
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
    [self release];
}
@end

/*
 * Hooks
 */
%hook WebVC
- (void)naviSendto:(id)arg1 {
    %log;
    UIWebView *web = MSHookIvar<UIWebView *>(self, "_web");
    NSString *url = [web stringByEvaluatingJavaScriptFromString:@"location.href"];
    NSString *title = [web stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"naviSendto: %@, %@", url, title);
    WorldPatcher *wp = [[[WorldPatcher alloc] init] retain];
    [wp runActionWithURL:url title:title view:self.view];
}
%end

