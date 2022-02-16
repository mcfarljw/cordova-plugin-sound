#import <Cordova/CDVPlugin.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlugin : CDVPlugin

@property (strong, nonatomic) AVAudioPlayer *audioPlayer1;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer2;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer3;
@property (strong, nonatomic) NSArray *audioPlayers;
@property (strong, nonatomic) NSString *documentDirectory;
@property (strong, nonatomic) NSString *wwwDirectory;
@property (strong, nonatomic) NSString *publicDirectory;

- (void) play:(CDVInvokedUrlCommand*)command;
- (void) stop:(CDVInvokedUrlCommand*)command;
- (void) stopAll:(CDVInvokedUrlCommand*)command;

@end
