import NetworkExtension

public extension NEFilterFlow {
    func matchSocialMedia() -> App? {
        if self.sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return .tiktok
        }
        // FOR SPEED TESTING
        // if self.sourceAppIdentifier?.hasSuffix(".com.google.chrome.ios") ?? false {
        //     return .instagram
        // }
        if self.sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            // Check if is NEFilterSocketFlow
            if let flow = self as? NEFilterSocketFlow {
                if flow.remoteHostname?.hasPrefix("chat-e2ee") ?? false {
                    return nil
                }
                if flow.remoteHostname?.hasPrefix("mqtt.") ?? false {
                    return nil
                }
            }
            return .instagram
        }
        if self.sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return .twitter
        }
        if self.sourceAppIdentifier?.hasSuffix(".com.google.ios.youtube") ?? false {
            return .youtube
        }
        return nil
    }
}
