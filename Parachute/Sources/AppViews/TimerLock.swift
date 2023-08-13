import SwiftUI
import Combine

public struct TimerLock<Content: View>: View{
    var duration: Int = 10

    @ViewBuilder var content: (_ timeLeft: Int) -> Content
//    @Environment(\.scenePhase) var scenePhase

    @State var timeLeft: Int
    @State var timer: AnyCancellable?

    public init(duration: Int, @ViewBuilder content: @escaping (_ timeLeft: Int) -> Content) {
        self.duration = duration
        self.content = content
        self._timeLeft = State(initialValue: duration)
        self._timer = State(initialValue: nil)
    }
    

    public var body: some View {
        content(timeLeft)
//            .onChange(of: scenePhase) { newPhase in
//                if newPhase == .active {
//                    startSubscription()
//                } else {
//                    timer?.cancel()
//                }
//            }
            .onAppear {
                startSubscription()
            }
    }
    
    func startSubscription() {
        timeLeft = duration
        timer?.cancel()
        timer = Timer.publish(every: 1, tolerance: 0, on: .main, in: .common).autoconnect()
            .sink { _ in
                if timeLeft == 0 {
                    timer?.cancel()
                    return
                }
                timeLeft -= 1
            }
    }
}
