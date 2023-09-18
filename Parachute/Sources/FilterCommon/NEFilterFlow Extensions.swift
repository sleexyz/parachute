import NetworkExtension

public extension NEFilterFlow {
    func matchSocialMedia() -> App? {
        if sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return .tiktok
        }
        // FOR SPEED TESTING
        // if self.sourceAppIdentifier?.hasSuffix(".com.google.chrome.ios") ?? false {
        //     return .instagram
        // }
        if sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            return .instagram
        }
        if sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return .twitter
        }
        if sourceAppIdentifier?.hasSuffix(".com.google.ios.youtube") ?? false {
            return .youtube
        }
        if sourceAppIdentifier?.hasSuffix(".com.facebook.Facebook") ?? false {
            return .facebook
        }
        return nil
    }

    func blockForApp(app: App) -> Bool {
        // Allow all browser flows
        guard let flow = self as? NEFilterSocketFlow else {
            return false
        }

        if flow.remoteHostname?.hasPrefix("apple.com") ?? false {
            return false
        }

        switch app.appType {
        case .instagram:
            if flow.remoteHostname?.hasPrefix("chat-e2ee.") ?? false {
                return false
            }
            if flow.remoteHostname?.hasPrefix("mqtt.") ?? false {
                return false
            }
            return true
        default:
            return true
        }
    }
}
