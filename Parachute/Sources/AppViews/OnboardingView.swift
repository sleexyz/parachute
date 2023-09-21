import Controllers
import DI
import SwiftUI

struct Logo: View {
    var fontSize: CGFloat = 60
    var body: some View {
        HStack {
            // Image(systemName: "drop.fill")
            //     .font(.system(size: 48, design: .rounded))
            //     .fontWeight(.bold)
            //     .foregroundStyle(Color.parachuteOrange)
            //     .padding(.trailing, 4)

            Text("parachute.")
                .font(.system(size: fontSize, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.parachuteOrange)
        }
    }
}

public struct OnboardingView: View {
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    public init() {}
    public var body: some View {
        Group {
            // if onboardingViewController.currentPage == 0 {
            Page0()
                .transition(.scale)
                .animation(.easeInOut(duration: 0.2), value: onboardingViewController.currentPage)
            // } else {
            //     Page1()
            //         .transition(.scale)
            //         .animation(.easeInOut(duration: 0.2), value: onboardingViewController.currentPage)
            // }
        }
        .provideDeps([OnboardingViewController.Provider()])
    }
}

struct Page0: View {
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    var body: some View {
        VStack(alignment: .leading) {
            Logo()
                .padding(.top, 48)

            Spacer()

            Text("**Unwire your mind.**")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.parachuteOrangeLight.opacity(1))

            Text("Stop getting **sucked in**")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 12)
            Text("every time you check a message.")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)

            Text("Stop the **compulsive checking**")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 12)
            Text("from breaking your flow.")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)

            Text("Stop **deleting apps**")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 12)
            Text("just to reinstall and binge again.")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)

            Text("Start your 1 week dopamine detox, **now.**")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(.parachuteOrangeLight.opacity(1))
                .padding(.top, 60)

            Spacer()

            HStack {
                Spacer()
                Button(action: {
                    onboardingViewController.isOnboardingCompleted = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // onboardingViewController.currentPage = 1
                }) {
                    Text("Start")
                }
                .tint(.parachuteOrange)
                .buttonStyle(.bordered)
                Spacer()
            }
            Spacer()
        }.padding(.horizontal)
    }
}

struct Page1: View {
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    var body: some View {
        SetupView()
    }
}
