import UserNotifications

import OneSignalExtension
import AppHelpers
import Controllers
import OSLog

class NotificationService: UNNotificationServiceExtension {

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationService")
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            /* DEBUGGING: Uncomment the 2 lines below to check this extension is executing
                          Note, this extension only runs when mutable-content is set
                          Setting an attachment or action buttons automatically adds this */
            // print("Running NotificationServiceExtension")
            // bestAttemptContent.body = "[Modified] " + bestAttemptContent.body
            
//            if bestAttemptContent.categoryIdentifier == "unpause" {
//                logger.info("unpausing 1")
//                Task { @MainActor in
//                    logger.info("unpausing 2")
//                    try await SettingsStore.shared.load()
//                    if #available(iOS 16.2, *) {
//                        await ActivitiesHelper.shared.startOrUpdate(settings: SettingsStore.shared.settings, isConnected: true)
//                    }
//                    logger.info("unpausing 3")
//                    // VPNLifecycleManager.shared.unpauseConnection()
//                }
//            }
            
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
