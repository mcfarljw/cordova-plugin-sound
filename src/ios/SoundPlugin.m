#import "SoundPlugin.h"
#import <Cordova/CDVPlugin.h>

@implementation SoundPlugin

- (void) pluginInitialize {
    NSError *error;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    self.documentDirectory = [searchPaths objectAtIndex:0];
    self.wwwDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];

    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error]) {
        NSLog(@"Unable to set audio session category: %@", error);
    }
}

- (void) play:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *path = [command.arguments objectAtIndex:0];
    NSNumber *track = [command.arguments objectAtIndex:1];
    NSString *trimmedPath = [path stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString *documentPath = [NSString stringWithFormat:@"%@%@", self.documentDirectory, trimmedPath];
    NSString *wwwPath = [NSString stringWithFormat:@"%@%@", self.wwwDirectory, trimmedPath];

    [self.commandDelegate runInBackground:^{
        NSURL *audioUrl = nil;

        if ([[NSFileManager defaultManager] fileExistsAtPath: wwwPath]) {
            audioUrl = [NSURL fileURLWithPath:wwwPath];
        } else if ([[NSFileManager defaultManager] fileExistsAtPath: documentPath]) {
            audioUrl = [NSURL fileURLWithPath:documentPath];
        }

        if (audioUrl != nil) {
            if ([track  isEqual: [NSNumber numberWithInt:0]]) {
                self.audioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
                self.audioPlayer1.delegate = self.appDelegate;

                [self.audioPlayer1 play];
            } else if ([track  isEqual: [NSNumber numberWithInt:1]]) {
                self.audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
                self.audioPlayer2.delegate = self.appDelegate;

                [self.audioPlayer2 play];
            } else if ([track  isEqual: [NSNumber numberWithInt:2]]) {
                self.audioPlayer3 = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
                self.audioPlayer3.delegate = self.appDelegate;

                [self.audioPlayer3 play];
            } else {
                self.audioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
                self.audioPlayer1.delegate = self.appDelegate;

                [self.audioPlayer1 play];
            }
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) stop:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *track = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
        if ([track  isEqual: [NSNumber numberWithInt:0]]) {
            [self.audioPlayer1 stop];
        } else if ([track  isEqual: [NSNumber numberWithInt:1]]) {
            [self.audioPlayer2 stop];
        } else if ([track  isEqual: [NSNumber numberWithInt:2]]) {
            [self.audioPlayer3 stop];
        } else {
            [self.audioPlayer1 stop];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) stopAll:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate runInBackground:^{
        [self.audioPlayer1 stop];
        [self.audioPlayer2 stop];
        [self.audioPlayer3 stop];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
