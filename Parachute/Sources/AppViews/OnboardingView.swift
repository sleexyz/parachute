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
                .padding(.top, 24)
            
            Text("Freedom from scrolling")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 24)
            
            
                Text("Instant 2-week dopamine detox")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(.parachuteOrange.opacity(0.7))
                    .padding(.top, 48)
                    .padding(.bottom, 200)

            HStack {
                Spacer()
                Button(action: {
                    onboardingViewController.isOnboardingCompleted = true
                    // onboardingViewController.currentPage = 1
                }) {
                    Text("Continue")
                }   
                .tint(.parachuteOrange) 
                .buttonStyle(.bordered)
                Spacer()
            }
        }.padding(.horizontal)
    }
}

struct Page1: View {
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    var body: some View {
        SetupView()
    }
}
