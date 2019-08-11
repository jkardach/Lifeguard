//
//  getTemps.m
//  Lifeguard
//
//  Created by jim kardach on 8/1/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "getTemps.h"
#import "ParticleCloud.h"

@interface getTemps ()
@property (nonatomic, strong) ParticleDevice *poolDevice;
@property (nonatomic, strong) ParticleDevice *spaDevice;

@property (nonatomic) int poolErrorCnt;
@property (nonatomic) int spaErrorCnt;
@property (nonatomic) int ambErrorCnt;
@property (nonatomic) int poolDevErrorCnt;
@property (nonatomic) int spaDevErrorCnt;
@end


@implementation getTemps

+ (id)sharedInstance {
    static getTemps *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _poolErrorCnt = 0;
        _spaErrorCnt = 0;
        _ambErrorCnt = 0;
        _poolDevErrorCnt = 0;
        _spaDevErrorCnt = 0;
        _poolTemp = @"";
        _spaTemp = @"";
        _ambTemp = @"";
    }
    return self;
}

- (void)getDevices
{
    [[ParticleCloud sharedInstance] loginWithUser:@"jim@kardach.com" password:@"victory123" completion:^(NSError *error) {
        if (!error) {
            [self getPoolDevice];
        } else {
            NSLog(@"wrong particle.io credentials or no internet");
        }
    }];
}

- (void)getPoolDevice {
    NSString *deviceID = @"1c003f001647353236343033";
    [[ParticleCloud sharedInstance] getDevice:deviceID completion:^(ParticleDevice *device, NSError *error) {
        if (!error) {
            self.poolDevice = device;
            [self getSpaDevice];
        } else {
            self.poolDevErrorCnt++;
            if (self.poolDevErrorCnt > 5) {
                NSLog(@"failed to get pool device, timing out");
                [self getSpaDevice];
            } else {
                NSLog(@"failed to get pool device, trying again");
                [self getPoolDevice];
            }
        }
    }];
}

- (void)getSpaDevice {
    NSString *deviceID = @"330036001347353236343033";
    [[ParticleCloud sharedInstance] getDevice:deviceID completion:^(ParticleDevice *device, NSError *error) {
        if (!error) {
            self.spaDevice = device;
            [self getPoolTemp];
        } else {
            self.spaDevErrorCnt++;
            if (self.spaDevErrorCnt > 5) {
                NSLog(@"failed to get spa device, timing out");
            } else {
                NSLog(@"failed to get spa device, trying again");
                [self getSpaDevice];
            }
            
        }
    }];
}

- (void)refreshTemps
{
    if (!self.poolDevice || !self.spaDevice) {
        NSLog(@"particle device not found");
        return;
    }
    [self getPoolTemp];
}

- (void)getPoolTemp {
    [self.poolDevice getVariable:@"poolTmp" completion:^(id result, NSError *error) {
        if (!error) {
            self.poolTemp = result;
            [self getAmbTemp];
        } else {
            self.poolErrorCnt++;
            if (self.poolErrorCnt > 5) {
                NSLog(@"Failed pool temperature from pool device, timing out, %@", error);
                [self getAmbTemp];
            } else {
                NSLog(@"Failed pool temperature from pool device, trying again, %@", error);
                [self getPoolTemp];
            }
        }
    }];
}

- (void)getAmbTemp {
    [self.poolDevice getVariable:@"AmbTemp" completion:^(id result, NSError *error) {
        if (!error) {
            self.ambTemp = result;
            [self getSpaTemp];
        } else {
            self.ambErrorCnt++;
            if (self.ambErrorCnt > 5) {
                NSLog(@"Failed reading ambient temperature from pool device, timing out");
                [self getSpaTemp];
            } else {
                NSLog(@"Failed reading ambient temperature from pool device, trying again");
                [self getAmbTemp];
            }
        }
    }];
}

- (void)getSpaTemp {
    [self.spaDevice getVariable:@"SpaTemp" completion:^(id result, NSError *error) {
        if (!error) {
            self.spaTemp = result;
            [self.delegate refreshData];  // generate callback
        } else {
            self.ambErrorCnt++;
            if (self.ambErrorCnt > 5) {
                NSLog(@"Failed reading spa temperature from spa device, timing out");
            } else {
                NSLog(@"Failed reading spa temperature from spa device, trying again");
                [self getSpaTemp];
            }
        }
    }];
}

@end
