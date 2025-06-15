//
//  ProfileExample.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUI

struct ProfileView: View {
    @State private var user: User? = nil
    @State private var url: String = ""
    @State private var errorMsg: String?
    @State private var likedArticles: [Article] = []

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack(spacing: 20) {
            if let errorMsg = errorMsg {
                Text("錯誤：\(errorMsg)")
                    .foregroundColor(.red)
            } else {
                if let avatarURL = URL(string: url),
                    !url.isEmpty
                {
                    AsyncImage(url: avatarURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .onTapGesture {
                                    showImagePicker = true
                                }
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    showImagePicker = true
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // 沒有圖片時點擊也能開啟選擇器
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showImagePicker = true
                        }
                }
                if let u = user {
                    Text("使用者名稱：\(u.name)")
                }
                List {
                    ForEach(likedArticles) { article in
                        VStack(alignment: .leading) {
                            Text("標題：\(article.title)")
                                .fontWeight(.bold)
                            Text("作者：\(article.authorUid)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                uploadAndUpdateAvatar(image: image)
            }
        }
        .onAppear {
            loadUser()
        }
    }

    func loadUser() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        FirebaseService.fetchSingleUser(uid: uid) { success, error, user in
            if success, let user = user {
                self.user = user
                self.url = user.avatar
                self.likedArticles.removeAll()
                user.likedArticles.forEach { likedArticle in
                    FirebaseService.fetchSingleArticle(articleId: likedArticle) {
                        success,
                        _,
                        article in
                        if success, let article = article {
                            self.likedArticles.append(article)
                        }
                    }
                }
            } else {
                errorMsg = error?.localizedDescription ?? "讀取失敗"
            }
        }
    }

    func uploadAndUpdateAvatar(image: UIImage) {
        FirebaseService.uploadImage(image: image) {
            imgUrl,
            error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMsg = "上傳失敗：\(error.localizedDescription)"
                }
                return
            }
            guard let imgUrl = imgUrl else {
                DispatchQueue.main.async {
                    errorMsg = "上傳失敗：沒有取得圖片網址"
                }
                return
            }

            var newUser = user
            newUser?.avatar = imgUrl

            FirebaseService.updateUser(user: newUser!) { success, err in
                DispatchQueue.main.async {
                    if success {
                        errorMsg = nil
                        loadUser()
                    } else {
                        errorMsg = "Firebase 更新失敗：\(err?.localizedDescription)"
                    }
                }
            }
        }
    }
}

// MARK: - PHPickerViewController包裝
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
