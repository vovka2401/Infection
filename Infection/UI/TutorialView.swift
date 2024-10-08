import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @State var selectedPage: Page?
    @State var pages: [Page] = [
        Page(text: "In this game you have to infect cells. There are different modes with different objectives.", images: [UIImage(named: "2_1")!, UIImage(named: "2_2")!]),
        Page(text: "There are 4 types of cells: default cells, live cells, dead cells and portals.", images: [UIImage(named: "lock")!]),
        Page(text: "You can infect default cells and live cells of other players, which are boundary to your active clusters. But you can't infect dead cells.", images: [UIImage(named: "lock")!]),
        Page(text: "Active clusters are considered groups of cells of one color, which have at least one active cell.", images: [UIImage(named: "2_1")!, UIImage(named: "2_2")!]),
        Page(text: "Dead cells are not considered active, but they can be used as conductors to living cells.", images: [UIImage(named: "lock")!]),
        Page(text: "4", images: [UIImage(named: "lock")!]),
    ]

    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay {
                if let selectedPage {
                    PageView(page: selectedPage, selectNext: selectNextPage, selectPrevious: selectPreviousPage)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: selectedPage)
            .onAppear {
                selectedPage = pages.first
            }
    }
    
    func selectNextPage() {
        guard let currentIndex = pages.firstIndex(where: { $0 == selectedPage }),
              currentIndex + 1 < pages.count else { return }
        selectedPage = pages[currentIndex + 1]
    }
    
    func selectPreviousPage() {
        guard let currentIndex = pages.firstIndex(where: { $0 == selectedPage }),
              currentIndex - 1 >= 0 else { return }
        selectedPage = pages[currentIndex - 1]
    }
}

struct Page: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let images: [UIImage]
}

struct PageView: View {
    let page: Page
    let selectNext: () -> Void
    let selectPrevious: () -> Void
    @State var selectedImage: UIImage?

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: Screen.width * 0.8, height: Screen.width * 1.5)
            .frame(width: Screen.width * 0.8 - 20, height: Screen.width * 1.5 - 20)
            .overlay {
                VStack(spacing: 0) {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .transition(.identity)
                            .padding(.bottom, 10)
                    }
                    Text(page.text)
                        .foregroundStyle(.black)
                        .font(.title)
                    Spacer()
                    HStack {
                        Button {
                            selectPrevious()
                        } label: {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(white: 0.95))
                                .overlay {
                                    Text("Back")
                                        .foregroundStyle(.black)
                                        .font(.headline)
                                }
                        }
                        Spacer()
                        Button {
                            selectNext()
                        } label: {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(white: 0.95))
                                .overlay {
                                    Text("Forward")
                                        .foregroundStyle(.black)
                                        .font(.headline)
                                }
                        }
                    }
                    .frame(height: 70)
                }
            }
            .onAppear {
                selectedImage = page.images.first
            }
            .onChange(of: selectedImage) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    selectNextImage()
                }
            }
            .onChange(of: page) { value in
                selectedImage = value.images.first
            }
    }

    private func selectNextImage() {
        guard page.images.count > 1, let selectedImage,
            let index = page.images.firstIndex(of: selectedImage) else { return }
        withAnimation(.easeInOut(duration: 1)) {
            if index + 1 < page.images.count {
                self.selectedImage = page.images[index + 1]
            } else {
                self.selectedImage = page.images.first
            }
        }
    }
}
