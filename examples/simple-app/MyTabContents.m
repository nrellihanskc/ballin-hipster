#import "MyTabContents.h"
#import "GTMFileSystemKQueue.h"

@implementation MyTabContents
@synthesize text;
@synthesize files;
@synthesize queues;
@synthesize tv;
@synthesize multipleFiles;

- (id)initWithBaseTabContents:(CTTabContents *)baseContents andFiles:(NSArray *)fileNames {
    
    if (!(self = [super initWithBaseTabContents:baseContents])) return nil;
    self.files = fileNames;
    if ([self.files count] > 1) {
        self.multipleFiles = YES;
    }
    else
        self.multipleFiles = NO;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    self.text = [[NSMutableAttributedString alloc] init];
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:[self.files count]];
    BOOL first = YES;
    NSMutableString *string = [[NSMutableString alloc] init];

    for (NSString *str in self.files) {
        if (first) {
            [string appendFormat:@"%@",[[str lastPathComponent] stringByDeletingPathExtension]];
            first = NO;
        }
        else
            [string appendFormat:@"+%@",[[str lastPathComponent] stringByDeletingPathExtension]];
        NSData *data = [manager contentsAtPath:str];
        if (self.multipleFiles) {
            NSAttributedString *tag = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]",[[str lastPathComponent] stringByDeletingPathExtension]] attributes:@{ NSForegroundColorAttributeName : [NSColor blueColor]}];
            NSAttributedString *tex = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self.text appendAttributedString:tag];
            [self.text appendAttributedString:tex];
        }
        else
            [self.text appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
        GTMFileSystemKQueue *queue = [[GTMFileSystemKQueue alloc] initWithPath:str forEvents:kGTMFileSystemKQueueWriteEvent acrossReplace:NO target:self action:@selector(fileSystemKQueue:events:)];
        [tmp addObject:queue];
    }
    self.queues = [NSArray arrayWithArray:tmp];
    self.title = string;

    // Create a simple NSTextView
    self.tv = [[NSTextView alloc] initWithFrame:NSZeroRect];
    [self.tv setEditable:NO];
    [self.tv setFont:[NSFont userFixedPitchFontOfSize:13.0]];
    [self.tv setAutoresizingMask:                  NSViewMaxYMargin|
     NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|
     NSViewHeightSizable|
     NSViewMinYMargin];
    [self.tv.textStorage setAttributedString:self.text];
    // Create a NSScrollView to which we add the NSTextView
    NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [sv setDocumentView:tv];
    [sv setHasVerticalScroller:YES];

    // Set the NSScrollView as our view
    self.view = sv;
    return self;
}
-(id)initWithBaseTabContents:(CTTabContents*)baseContents {

  // Setup our contents -- a scrolling text view
    


  return self;
}

-(void)viewFrameDidChange:(NSRect)newFrame {
  // We need to recalculate the frame of the NSTextView when the frame changes.
  // This happens when a tab is created and when it's moved between windows.
  [super viewFrameDidChange:newFrame];
  NSRect frame = NSZeroRect;
  frame.size = [(NSScrollView*)(view_) contentSize];
  [self.tv setFrame:frame];
}
 - (void)fileSystemKQueue:(GTMFileSystemKQueue *)fskq
                   events:(GTMFileSystemKQueueEvents)events {
     NSFileManager *manager = [NSFileManager defaultManager];
     NSInteger index = [self.queues indexOfObject:fskq];
     NSData *data = [manager contentsAtPath:[self.files objectAtIndex:index]];
     if (self.multipleFiles) {
         NSAttributedString *tag = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]",[[[self.files objectAtIndex:index] lastPathComponent] stringByDeletingPathExtension]] attributes:@{ NSForegroundColorAttributeName : [NSColor blueColor]}];
         NSAttributedString *tex = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
         [self.text appendAttributedString:tag];
         [self.text appendAttributedString:tex];
     }
     else
         [self.text appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
     NSRange range;
     range.location = [self.text length];
     NSLog(@"%lu", range.location);
     
     NSRange deleteRange;
     if (range.location > 10000) {
         deleteRange.location = 1;
         deleteRange.length = 2500;
     }
     [self.text deleteCharactersInRange:deleteRange];
     [self.tv.textStorage setAttributedString:self.text];

     [self.tv scrollRangeToVisible:range];
 }
@end
