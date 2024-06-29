import SwiftUI

struct MapPickerView: View {
    @Binding var selectedMap: Map
    @Binding var maps: [Map]
    let side = Screen.width * 0.8
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(maps, id: \.id) { mapView($0) }
            }
            .padding(.vertical, 20)
        }
        .frame(width: Screen.width)
    }
    
    func mapView(_ map: Map) -> some View {
        Button {
            selectedMap = map
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(map === selectedMap ? Color.red : Color.green)
                .frame(width: side, height: side)
                .overlay {
                    PreviewMapView(map: map, side: side)
                }
        }
    }
}
