#import <ChromiumTabs/ChromiumTabs.h>

// This class represents a tab. In this example application a tab contains a
// simple scrollable text area.
@class GTMFileSystemKQueue;

@interface MyTabContents : CTTabContents {
}
@property (strong, nonatomic) NSMutableAttributedString *text;
@property (strong, nonatomic) NSArray *files;
@property (strong, nonatomic) NSArray *queues;
@property (strong, nonatomic) NSTextView *tv;
@property (assign, nonatomic) BOOL multipleFiles;

- (id)initWithBaseTabContents:(CTTabContents *)baseContents andFiles:(NSArray *)fileNames;
@end
