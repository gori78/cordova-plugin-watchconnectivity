#import "WCiOS.h"

@implementation WCiOS
@synthesize messageReceiver;
@synthesize messageString;
- (void)init:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSString* callbackId = [command callbackId];
        CDVPluginResult* pluginResult = nil;
        if ([WCSession isSupported]) {
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"WCSession is not supported!"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}
- (void)messageReceiver:(CDVInvokedUrlCommand*)command {
    self.messageReceiver = [command callbackId];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSError *err;
    
    NSLog(@"received data: %@",message);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:&err] encoding:NSUTF8StringEncoding]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.messageReceiver];
    dispatch_async(dispatch_get_main_queue(), ^{
        replyHandler([[NSDictionary alloc] initWithObjects:@[self.messageString?self.messageString:@""] forKeys:@[@"message"]]);
    });
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error{
    NSLog(@"activationDidComplete with status: %ld and Error %@ ", (long)activationState, error);
}

- (void)sendMessage:(CDVInvokedUrlCommand*)command {
    NSString* message = [[command arguments] objectAtIndex:0];
    if (message != nil) {
        self.messageString = message;
    }
    
    NSLog(@"send data: %@", message);
    
    NSDictionary *messageDictionary = [[NSDictionary alloc] initWithObjects:@[message] forKeys:@[@"message"]];
    
    [[WCSession defaultSession] sendMessage:messageDictionary
                               replyHandler:^(NSDictionary *reply) {}
                               errorHandler:^(NSError *error) {}
     ];
    
}

@end
