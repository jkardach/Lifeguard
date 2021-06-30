//
//  FileRoutines.h
//  FinsixSRBot
//
//  Created by jim kardach on 3/22/16.
//  Copyright © 2016 Forkbeardlabs. All rights reserved.
//

//@import Foundation;
@import UIKit;

@interface FileRoutines : NSObject
// creates a filename with prefix, eventKey, postfix and "." extension
- (NSString *)filenameWithPrefix:(NSString *)prefix
                        eventKey:(NSString *)eventKey
                         postfix:(NSString *)postfix
                             ext:(NSString *)ext;

// archives the object with the filename in docs directory
- (void)saveObject:(id)object filename:(NSString *)filename;

// unarchives filename to object
- (id)restoreObjectFromFilename:(NSString *)filename;

- (void)saveTxtFile:(NSString *)txtString filename:(NSString *)filename;

// deletes the file with filename in docs dir
- (void)deleteDocFile:(NSString *)filename;

// deletes all of the files in the docs dir
- (void)deleteDocs;

// returns the docs dir
- (NSString *)docDir;

// does a printf of the files in the doc directory
- (NSString *)dirDoc;

// returns YES if the file exists in the docs directory
- (BOOL)fileExists:(NSString *)filename;

// iOS only routines
- (void)saveImage:(UIImage *)image filename:(NSString *)filename;
- (UIImage *)restoreImageFromFilename:(NSString *)filename;

- (void)savePng:(UIImage *)image filename:(NSString *)filename;

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
@end
