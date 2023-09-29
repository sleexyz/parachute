//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Sean Lee on 9/14/23.
//

import Controllers
import ManagedSettings

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for _: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            // ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "instagram")).shield.applications = []
            AppController.instagram.dac.unblock()
            // DeviceActivityController.shared.initiateMonitoring()
            completionHandler(.none)
        case .secondaryButtonPressed:
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }

    override func handle(action _: ShieldAction, for _: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }

    override func handle(action _: ShieldAction, for _: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
}
