#import "RNNotificationCenter.h"
#import "RCTConvert+RNNotifications.h"

@implementation RNNotificationCenter

- (void)requestPermissions:(NSArray *)options {
    UNAuthorizationOptions authOptions = (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
    if ([options count] > 0) {
        for (NSString* option in options) {
            if ([option isEqualToString:@"ProvidesAppNotificationSettings"]) {
                if (@available(iOS 12.0, *)) {
                    authOptions = authOptions | UNAuthorizationOptionProvidesAppNotificationSettings;
                }
            }
            if ([option isEqualToString:@"Provisional"]) {
                if (@available(iOS 12.0, *)) {
                    authOptions = authOptions | UNAuthorizationOptionProvisional;
                }
            }
        }
    }
    
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error && granted) {
            [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }
            }];
        }
    }];
}

- (void)setCategories:(NSArray *)json {
    NSMutableSet<UNNotificationCategory *>* categories = nil;
    
    if ([json count] > 0) {
        categories = [NSMutableSet new];
        for (NSDictionary* categoryJson in json) {
            [categories addObject:[RCTConvert UNMutableUserNotificationCategory:categoryJson]];
        }
    }
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
}

- (void)postLocalNotification:(NSDictionary *)notification withId:(NSNumber *)notificationId {
    UNNotificationRequest* localNotification = [RCTConvert UNNotificationRequest:notification withId:notificationId];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:localNotification withCompletionHandler:nil];
}

- (void)cancelLocalNotification:(NSNumber *)notificationId {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers:@[[notificationId stringValue]]];
}

- (void)removeAllDeliveredNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllDeliveredNotifications];
}

- (void)removeDeliveredNotifications:(NSArray<NSString *> *)identifiers {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeDeliveredNotificationsWithIdentifiers:identifiers];
}

- (void)getDeliveredNotifications:(RCTResponseSenderBlock)callback {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        NSMutableArray<NSDictionary *> *formattedNotifications = [NSMutableArray new];
        
        for (UNNotification *notification in notifications) {
            [formattedNotifications addObject:[RCTConvert UNNotificationPayload:notification]];
        }
        callback(@[formattedNotifications]);
    }];
}

- (void)cancelAllLocalNotifications {
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

- (void)isRegisteredForRemoteNotifications:(RCTPromiseResolveBlock)resolve {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.alertSetting == UNNotificationSettingEnabled || settings.soundSetting == UNNotificationSettingEnabled || settings.badgeSetting == UNNotificationSettingEnabled) {
            resolve(@(YES));
        } else {
            resolve(@(NO));
        }
    }];
}

- (void)checkPermissions:(RCTPromiseResolveBlock)resolve {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        resolve(@{
                  @"badge": [NSNumber numberWithBool:settings.badgeSetting == UNNotificationSettingEnabled],
                  @"sound": [NSNumber numberWithBool:settings.soundSetting == UNNotificationSettingEnabled],
                  @"alert": [NSNumber numberWithBool:settings.alertSetting == UNNotificationSettingEnabled],
                  });
    }];
}
@end
