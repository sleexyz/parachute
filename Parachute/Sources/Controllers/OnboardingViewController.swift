import SwiftUI
import DI

public class OnboardingViewController: ObservableObject {
    public struct Provider : Dep {
        public func create(r: Registry) -> OnboardingViewController {
            return OnboardingViewController.shared
        }
        public init() {}
    }

    @AppStorage("isOnboardingCompleted") public var isOnboardingCompleted = false

    @Published public var currentPage = 0
    public static let shared = OnboardingViewController()  
}