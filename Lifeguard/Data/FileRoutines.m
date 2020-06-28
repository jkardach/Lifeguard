//
//  FileRoutines.m
//  FinsixSRBot
//
//  Created by jim kardach on 3/22/16.
//  Copyright © 2016 Forkbeardlabs. All rights reserved.
//

#import "FileRoutines.h"

@implementation FileRoutines
- (NSString *)filenameWithPrefix:(NSString *)prefix
                        eventKey:(NSString *)eventKey
                         postfix:(NSString *)postfix
                             ext:(NSString *)ext
{
    NSString *filename = [NSString stringWithFormat:@"%@%@%@.%@",
                          prefix,
                          eventKey,
                          postfix,
                          ext];
    return filename;
}


// this archieves the object into the doc directory with  filename and
// extension 
- (void)saveObject:(id)object filename:(NSString *)filename
{
    NSError *error = nil;
    
    //Get the device's data directory:
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
    
    //Archive using iOS 12 compliant coding:
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:&error];
    [data writeToFile:databasePath options:NSDataWritingAtomic error:&error];
    if (error == nil) {
        NSLog(@"Write returned error: %@", [error localizedDescription]);
    }
}

- (void)saveTxtFile:(NSString *)txtString filename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory

    NSError *error;
    BOOL succeed = [filename writeToFile:[documentsDirectory stringByAppendingPathComponent:@"DataCVS.txt"]
                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        NSLog(@"Write returned error: %@", [error localizedDescription]);
    }
}
// this un-archieves the file "filename" from the doc directory and returns the objec
- (id)restoreObjectFromFilename:(NSString *)filename
{
    NSError *error = nil;
    
    //Get the device's data directory:
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
    
    //Unarchive the data:
    NSData *newData = [NSData dataWithContentsOfFile:databasePath];
    
    return [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:newData error:&error];
}

// delete a file with the passed filename in the docs directory
- (void)deleteDocFile:(NSString *)filename
{
    // initialize filesystem
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    
    // create datafilepath by appending path and filename
    NSString *dataFilePath = [[self docDir] stringByAppendingPathComponent:filename];
    // delete file
    NSError *error;
    if (![filemgr removeItemAtPath:dataFilePath error:&error])
        printf("did not delete file: %s\n", [dataFilePath UTF8String]);
}

// returns path for the documents directory
- (NSString *)docDir
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
    return [dirPaths objectAtIndex:0];
}

// does a printf of the contents of the docs directory and returns a string inkind
- (NSString *)dirDoc
{
    
    NSArray *directoryContent = [[NSFileManager defaultManager]
                                 contentsOfDirectoryAtPath:[self docDir]
                                 error:NULL];
    NSString *dirContents = @"Files in documents directory:\n";
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *file = directoryContent[count];
        dirContents = [dirContents stringByAppendingFormat:@"%@\n", file];
    }
    return dirContents;
}

- (void)deleteDocs
{
    NSArray *directoryContent = [[NSFileManager defaultManager]
                                 contentsOfDirectoryAtPath:[self docDir]
                                 error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *file = directoryContent[count];
        [self deleteDocFile:file];
    }
}

// checks to see if the file "filename" exists in the docs directory
- (BOOL)fileExists:(NSString *)filename
{
    NSString* filePath = [[self docDir] stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - iOS library only

// this archieves the school into the doc directory with school filename and
// extension extension
- (void)saveImage:(UIImage *)image filename:(NSString *)filename
{
    // turn image into jpeg
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    // create datafilepath by appending path and filename
    NSString *dataFilePath = [[self docDir] stringByAppendingPathComponent:filename];
    // archieve file
    [data writeToFile:dataFilePath atomically:YES];
}

- (void)savePng:(UIImage *)image filename:(NSString *)filename
{
    // turn image into jpeg
    NSData *data = UIImagePNGRepresentation(image);
    
    // create datafilepath by appending path and filename
    NSString *dataFilePath = [[self docDir] stringByAppendingPathComponent:filename];
    // archieve file
    [data writeToFile:dataFilePath atomically:YES];
}


// this un-archieves the file "filename" from the doc directory and returns the object
- (UIImage *)restoreImageFromFilename:(NSString *)filename
{
    NSString *dataFilePath = [[self docDir] stringByAppendingPathComponent:filename];
    UIImage *image = [UIImage imageWithContentsOfFile:dataFilePath];
    return image;
}

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    // Create a color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    return color;
}

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

@end
