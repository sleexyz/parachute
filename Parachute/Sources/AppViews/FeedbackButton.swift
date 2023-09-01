import MessageUI
import SwiftUI

struct FeedbackButton: View {
    private let messageComposeDelegate = MessageComposerDelegate()


    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.presentMessageCompose()
        }, label: {
            HStack {
                Text("Feedback?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.trailing, 4)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 28))
            }
        })
        .buttonStyle(.plain)
        .tint(.parachuteOrange)
        .foregroundColor(.parachuteOrange)
    }
}

// MARK: The message extension

extension FeedbackButton {
    private class MessageComposerDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            // Customize here
            controller.dismiss(animated: true)
        }
    }

    /// Present an message compose view controller modally in UIKit environment
    private func presentMessageCompose() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        let vc = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = messageComposeDelegate
        composeVC.recipients = ["13472623016"]

        vc?.present(composeVC, animated: true)
    }
}
