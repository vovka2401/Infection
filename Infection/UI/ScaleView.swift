import SwiftUI

struct ScaleView: View {
    @Binding var selectedStepsCount: Int
    let range: ClosedRange<Int>
    let color: Color
    let strokeColor: Color
    let isDisabled: Bool
    private let size = CGSize(width: Screen.width / 10, height: Screen.width / 20)
    private let spacing = 5.0
    
    init(selectedStepsCount: Binding<Int> = .constant(0), range: ClosedRange<Int>, color: Color, strokeColor: Color, isDisabled: Bool = false) {
        _selectedStepsCount = selectedStepsCount
        self.range = range
        self.color = color
        self.strokeColor = strokeColor
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< range.upperBound, id: \.self) { step in
                RoundedRectangle(cornerRadius: 5)
                    .fill(step < selectedStepsCount ? color : Color.black.opacity(0.5))
                    .frame(size: size)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 2)
                            .fill(strokeColor)
                            .frame(size: size)
                    }
            }
        }
        .animation(.easeInOut, value: selectedStepsCount)
        .transition(.slide)
        .disabled(isDisabled)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !isDisabled else { return }
                    selectedStepsCount = min(max(Int(value.location.x / (size.width + spacing)) + 1, range.lowerBound), range.upperBound)
                }
        )
    }
}
