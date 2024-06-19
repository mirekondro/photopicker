import SwiftUI
import PhotosUI

enum PhotoPickerError: Error {
    case failedToLoadImageData
    case failedToConvertDataToImage
}

struct PhotoPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        VStack {
            if !selectedImages.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
                .frame(width: 300, height: 500)
            }

            PhotosPicker(selection: $selectedItems, matching: .images) {
                Label("Pick Photos", systemImage: "photo.fill.on.rectangle.fill")
            }
        }
        .onChange(of: selectedItems) { newItems in
            selectedImages = []
            newItems.forEach { item in
                Task {
                    do {
                        guard let data = try? await item.loadTransferable(type: Data.self) else {
                            throw PhotoPickerError.failedToLoadImageData
                        }
                        guard let image = UIImage(data: data) else {
                            throw PhotoPickerError.failedToConvertDataToImage
                        }
                        selectedImages.append(image)
                    } catch {
                        print("Error loading image \(error)")
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            PhotoPickerView()
                .tabItem {
                    Label("Photos", systemImage: "photo")
                }
            Text("Other Tab")
                .tabItem {
                    Label("Other", systemImage: "square.and.pencil")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
