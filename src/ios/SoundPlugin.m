#import "SoundPlugin.h"
#import <Cordova/CDVPlugin.h>

@implementation SoundPlugin

- (void) pluginInitialize {
    NSError *error;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    self.audioTracks = [NSMutableDictionary new];
    self.documentDirectory = [searchPaths objectAtIndex:0];
    self.wwwDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];

    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error]) {
        NSLog(@"Unable to set audio session category: %@", error);
    }
}

- (void) play:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *path = [command.arguments objectAtIndex:0];
    NSString *track = [command.arguments objectAtIndex:1];
    NSString *trimmedPath = [path stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString *documentPath = [NSString stringWithFormat:@"%@%@", self.documentDirectory, trimmedPath];
    NSString *wwwPath = [NSString stringWithFormat:@"%@%@", self.wwwDirectory, trimmedPath];

    if (!self.audioTracks[track]) {
        self.audioTracks[track] = [NSMutableDictionary new];
    }

    [self.commandDelegate runInBackground:^{
        if (self.audioTracks[track][trimmedPath]) {
            AudioServicesPlaySystemSound((unsigned int)[self.audioTracks[track][trimmedPath] integerValue]);
        } else {
            if ([[NSFileManager defaultManager] fileExistsAtPath: wwwPath]) {
                NSURL *audioUrl = [NSURL fileURLWithPath:wwwPath];
                SystemSoundID soundId;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioUrl, &soundId);

                self.audioTracks[track][trimmedPath] = [NSNumber numberWithInteger:soundId];

                AudioServicesPlaySystemSound(soundId);
            } else if ([[NSFileManager defaultManager] fileExistsAtPath: documentPath]) {
                NSURL *audioUrl = [NSURL fileURLWithPath:documentPath];
                SystemSoundID soundId;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioUrl, &soundId);

                self.audioTracks[track][trimmedPath] = [NSNumber numberWithInteger:soundId];

                AudioServicesPlaySystemSound(soundId);
            } else {
                NSLog(@"Audio not found!");
            }
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) stop:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *trackKey = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
        for (id soundKey in self.audioTracks[trackKey]) {
            AudioServicesDisposeSystemSoundID((unsigned int)[self.audioTracks[trackKey][soundKey] integerValue]);
            [self.audioTracks[trackKey] removeObjectForKey:soundKey];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) stopAll:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate runInBackground:^{
        for (id trackKey in self.audioTracks) {
            for (id soundKey in self.audioTracks[trackKey]) {
                AudioServicesDisposeSystemSoundID((unsigned int)[self.audioTracks[trackKey][soundKey] integerValue]);
                [self.audioTracks[trackKey] removeObjectForKey:soundKey];
            }
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
