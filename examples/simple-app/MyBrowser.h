#import <ChromiumTabs/ChromiumTabs.h>

// We provide our own CTBrowser subclass so we can create our own, custom tabs.
// See the implementation file for details.

@interface MyBrowser : CTBrowser {
}

@property (strong, nonatomic) NSArray *logFiles;
@property (assign, nonatomic) NSInteger currentIndex;

- (void)addTabsForFiles;
- (void)getFiles;
@end
