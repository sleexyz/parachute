//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Sean Lee on 9/14/23.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import CommonViews

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    func buttonMessage(application: Application) -> String {
        return "Okay"
        // if let name = application.{
        //     return "Open \(name)"
        // }
        // return "Open app"
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: .clear,
            // icon:  UIImage(systemName: "tortoise.fill")?.withTintColor(.white),
            title: .init(text: "Slowing down content...", color: UIColor(.parachuteOrange)),
            subtitle: .init(text: "Want to keep scrolling? Open the Parachute app.", color: UIColor(.white)),
            primaryButtonLabel: .init(text: buttonMessage(application: application), color: UIColor(.white)),
            primaryButtonBackgroundColor: UIColor(.parachuteOrange)
            //secondaryButtonLabel: .init(text: "I'm done", color: UIColor(.white))
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
}
