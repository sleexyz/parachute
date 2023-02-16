//
//  DeviceCallbacks.swift
//  tunnel
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import Ffi
import Logging
import Common

class DeviceCallbacks: NSObject, FfiDeviceCallbacksProtocol {
    private let logger: Logger = Logger(label: "industries.strange.slowdown.tunnel.DeviceCallbacks")
    private var notificationsEnabled: Bool = false
    let notificationsHelper: NotificationsHelper
    
    override init() {
        self.notificationsHelper = NotificationsHelper()
        
        super.init()
        Task {
            do {
                self.notificationsEnabled = try await notificationsHelper.enableNotifications()
                logger.info("notification status: \(notificationsEnabled)")
            } catch {
                logger.error("notifications not enabled")
            }
        }
    }
    
    func sendNotification(_ title: String?, message: String?) {
        guard let title = title else {
            fatalError("not title: \(title.debugDescription)")
        }
        guard let message = message else {
            fatalError("not message: \(message.debugDescription)")
        }
        logger.info("Got message to send as notification: \(title):  \(message)")
        if notificationsEnabled {
            Task(priority: .background) {
                do {
                    notificationsHelper.clearNotifications()
                    try await notificationsHelper.sendMessage(title: title, body: message, fromNow: 1) // minimum time seems to be 1 second.
                } catch let error {
                    logger.error("error sending notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
