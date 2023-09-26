import SwiftUI

struct SelectionCell<Choice: Equatable, Label: View>: View {
    let choice: Choice
    @Binding var activeSelection: Choice

    @ViewBuilder let label: () -> Label

    var body: some View {
        HStack {
            label()
            Spacer()
            if activeSelection == choice {
                Image(systemName: "checkmark")
                    .foregroundColor(.parachuteOrange)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.activeSelection = self.choice
        }
    }
}
