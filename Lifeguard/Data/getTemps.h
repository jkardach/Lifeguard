//
//  getTemps.h
//  Lifeguard
//
//  Created by jim kardach on 8/1/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol getTempsDelegate
- (void)refreshData;
@end

@interface getTemps : NSObject {
    
}

@property (weak) id <getTempsDelegate> delegate;
@property (nonatomic, strong) NSString *poolTemp;
@property (nonatomic, strong) NSString *ambTemp;
@property (nonatomic, strong) NSString *spaTemp;
+ (id)sharedInstance;

- (void)getDevices;
- (void)refreshTemps;
@end

NS_ASSUME_NONNULL_END
