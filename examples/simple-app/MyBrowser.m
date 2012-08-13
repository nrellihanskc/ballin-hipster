#import "MyBrowser.h"
#import "MyTabContents.h"

@implementation MyBrowser
@synthesize logFiles;
@synthesize currentIndex;

// This method is called when a new tab is being created. We need to return a
// new CTTabContents object which will represent the contents of the new tab.
-(CTTabContents*)createBlankTabBasedOn:(CTTabContents*)baseContents {
  // Create a new instance of our tab type
    self.currentIndex++;
  return [[MyTabContents alloc] initWithBaseTabContents:baseContents andFiles:[self.logFiles objectAtIndex:self.currentIndex - 1]];
}

- (void)addTabsForFiles {
    self.currentIndex = 0;
    for (NSArray *array in self.logFiles) {
        [self addBlankTabInForeground:YES];
    }
}
- (CTTabContents *)addBlankTab {
    [self getFiles];
    return nil;
}
- (CTToolbarController *)createToolbarController {
    return nil;
}
- (void)getFiles {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:@[@"log"]];
    [panel setAllowsMultipleSelection:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSFileManager *manager = [NSFileManager defaultManager];
            
            NSArray *actualLogFiles;
            if ([[panel URLs] count] > 1) {
                //selected multiple log files
                NSMutableArray *_logFiles = [[NSMutableArray alloc] init];
                for (NSURL *url in [panel URLs]) {
                    NSString *path = [url path];
                    
                    BOOL isDirectory;
                    BOOL exists;
                    exists = [manager fileExistsAtPath:path isDirectory:&isDirectory];
                    
                    if (exists && isDirectory) {
                        NSArray *filesInDirectory = [self logFilesFromDirectory:url];
                        if (filesInDirectory == nil) {
                            return;
                        }
                        [_logFiles addObjectsFromArray:filesInDirectory];
                    }
                    else if (exists) {
                        [_logFiles addObject:path];
                    }
                }
                self.logFiles = @[_logFiles];
                [self addTabsForFiles];
                }
                else if ([[panel URLs] count] == 1) {
                    //selected just one file.
                    BOOL isDirectory;
                    NSString *path = [[panel URL] path];
                    BOOL exists = [manager fileExistsAtPath:path isDirectory:&isDirectory];
                    if (exists && isDirectory) {
                        NSArray *filesInDirectory = [self logFilesFromDirectory:[panel URL]];
                        if (filesInDirectory == nil) {
                            return;
                        }
                        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[filesInDirectory count]];
                        
                        for (NSString *string in filesInDirectory) {
                            [array addObject:@[string]];
                        }
                        
                        actualLogFiles = [NSArray arrayWithArray:array];
                    }
                    else if (exists) {
                        actualLogFiles = @[@[[[panel URL] path]]];
                        
                    }
                    else {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:@"No log files in this directory, please try again"];
                        [alert addButtonWithTitle:@"Ok"];
                        [alert runModal];
                        return;
                    }
                    self.logFiles = actualLogFiles;
                    [self addTabsForFiles];
                }
                }
                }];
                
                
}
- (NSArray *)logFilesFromDirectory:(NSURL *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *files = [manager contentsOfDirectoryAtURL:path includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSMutableArray *mutable = [[NSMutableArray alloc] initWithCapacity:[files count]];
    for (NSURL *url in files) {
        [mutable addObject:[url path]];
    }
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.log'"];
    NSArray *actualLogFiles = [mutable filteredArrayUsingPredicate:filter];
    
    if ([actualLogFiles count] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No log files in this directory, please try again"];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return nil;
    }
    
    return actualLogFiles;
}
@end
