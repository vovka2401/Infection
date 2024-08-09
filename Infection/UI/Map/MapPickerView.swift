import SwiftUI

struct MapPickerView: View {
    @Binding var selectedMap: Map
    @State var maps: [Map]
    let selectedWinMode: GameWinMode
    let side = Screen.width * 0.8

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach($maps, id: \.id) {
                    mapView($0)
                }
            }
            .padding(.vertical, 20)
        }
        .frame(width: Screen.width)
    }

    func mapView(_ map: Binding<Map>) -> some View {
        Button {
            selectedMap = map.wrappedValue
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(map.wrappedValue == selectedMap ? Color.orange : Color.white)
                .frame(
                    width: side * map.wrappedValue.size.width / max(map.wrappedValue.size.width, map.wrappedValue.size.height),
                    height: side * map.wrappedValue.size.height / max(map.wrappedValue.size.width, map.wrappedValue.size.height)
                )
                .overlay {
                    PreviewMapView(map: map.wrappedValue, winMode: selectedWinMode, side: side)
                }
        }
    }
}
