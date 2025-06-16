import SwiftUI
import PhotosUI
import Firebase

struct PetAlbumView: View {
    @StateObject private var viewModel = AlbumViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showCommentInput = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.albumPhotos.isEmpty {
                    Text("앨범이 비어 있어요.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.albumPhotos) { photo in
                            let image = photo.image ?? UIImage()
                            let comment = photo.comment
                            let dateText = photo.date?.formatted(date: .abbreviated, time: .shortened) ?? "날짜 없음"
                            let locationText: String = {
                                if let loc = photo.location {
                                    return String(format: "위치: %.4f, %.4f", loc.latitude, loc.longitude)
                                }
                                return "위치 정보 없음"
                            }()

                            VStack(alignment: .leading) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                Text(comment)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(dateText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(locationText)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("사진 추가하기", systemImage: "plus.circle")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("앨범")
        }
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedImage = image
                    showCommentInput = true
                }
            }
        }
        .sheet(isPresented: $showCommentInput) {
            VStack(spacing: 20) {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding()
                }

                TextField("사진에 대한 코멘트를 입력하세요", text: $viewModel.commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("저장하기") {
                    viewModel.uploadPhoto { success in
                        showCommentInput = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Spacer()
            }
            .padding()
        }
    }
}

