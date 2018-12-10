#import <Cordova/CDVPlugin.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlugin : CDVPlugin

@property (strong, nonatomic) NSMutableDictionary *audioTracks;
@property (strong, nonatomic) NSString *documentDirectory;
@property (strong, nonatomic) NSString *wwwDirectory;

- (void) play:(CDVInvokedUrlCommand*)command;
- (void) stop:(CDVInvokedUrlCommand*)command;
- (void) stopAll:(CDVInvokedUrlCommand*)command;

@end
