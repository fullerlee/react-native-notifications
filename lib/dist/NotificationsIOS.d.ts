import { Notification } from './DTO/Notification';
import { Commands } from './commands/Commands';
import { EventsRegistryIOS } from './events/EventsRegistryIOS';
import { RequestPermissionsOptions } from './adapters/NativeCommandsSender';
export declare class NotificationsIOS {
    private readonly commands;
    private readonly eventsRegistry;
    constructor(commands: Commands, eventsRegistry: EventsRegistryIOS);
    /**
    * Request permissions to send remote notifications
    */
    registerRemoteNotifications(options?: RequestPermissionsOptions[]): void;
    /**
    * Unregister for all remote notifications received via Apple Push Notification service
    */
    abandonPermissions(): void;
    /**
   * registerPushKit
   */
    registerPushKit(): void;
    /**
     * getBadgeCount
     */
    getBadgeCount(): Promise<number>;
    /**
     * setBadgeCount
     * @param count number of the new badge count
     */
    setBadgeCount(count: number): void;
    /**
     * cancelAllLocalNotifications
     */
    cancelAllLocalNotifications(): void;
    /**
     * checkPermissions
     */
    checkPermissions(): Promise<import("./interfaces/NotificationPermissions").NotificationPermissions>;
    /**
     * removeDeliveredNotifications
     * @param identifiers Array of notification identifiers
     */
    removeDeliveredNotifications(identifiers: Array<string>): void;
    /**
     * getDeliveredNotifications
     */
    getDeliveredNotifications(): Promise<Notification[]>;
    /**
     * Obtain the events registry instance
     */
    events(): EventsRegistryIOS;
}
