import SwiftUI
import DI
import Controllers

struct Logo: View {
    var body: some View {
        HStack {
            // Image(systemName: "drop.fill")
            //     .font(.system(size: 48, design: .rounded))
            //     .fontWeight(.bold)
            //     .foregroundStyle(Color.parachuteOrange)
            //     .padding(.trailing, 4)

            Text("parachute.")
                .font(.system(size: 54, design: .rounded))
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
            Text("Delete the **binge scrolling**")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 24)
            Text("without deleting your apps")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                //.padding(.top, 24)
            
            Text("Delete the **compulsive checking.**")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 48)
            Text("Instant one week dopamine detox.")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
               // .padding(.top, 48)
            
            Text("**Unwire your mind.**")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.parachuteOrange)
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
            .padding(.bottom, 48)
        }.padding(.horizontal)
    }
}

struct Page1: View {
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    var body: some View {
        SetupView()
    }
}
