//
//  SettingView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

// MARK: SettingView
struct SettingView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isLoggedIn = false
    @State private var userName: String? = ""
    @State private var userImage: String? = ""
    @State private var navPath = NavigationPath()
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                // Background
                // call Dynamic Background
                AnimatedStarfieldBackground(starCount: 72)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    // User Info 
                    VStack(spacing: 10) {
                        if let img = userImage, isLoggedIn {
                            if img.hasPrefix("http"){
                                AsyncImage(url: URL(string: img )) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // 載入中
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 74, height: 74)
                                            .clipped()
                                            .cornerRadius(12)
                                    case .failure:
                                        Image(systemName: "xmark.octagon") // 載入失敗
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }else{
                                Image(img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 94, height: 94)
                                    .clipShape(Circle())
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 94, height: 94)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        if let name = userName, !name.isEmpty {
                            Text(name)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        } else {
                            Text("Guest")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 44)

                    // Settings Menu
                    VStack(spacing: 18) {
                        NavigationLink(value: "MyDreams") {
                            SettingMenuRow(title: "My Dreams")
                        }
                        NavigationLink(value: "SavedDreams") {
                            SettingMenuRow(title: "Saved Dreams")
                        }
                        NavigationLink(value: "ChangePassword") {
                            SettingMenuRow(title: "Change Password")
                        }
                    }

                    Spacer()

                    // Logout or Login Button

                    Button(action: {
                        if isLoggedIn {
                            // Clear user data and log out
                            isLoggedIn = false
                            userName = "Guest"
                            userImage = nil
                            // TODO: Call API to log out
                            FirebaseService.userLogout { success, error in
                                if success {
                                    print("User logged out successfully.")
                                    alertMsg = "Logged out successfully."
                                } else if let error = error {
                                    print("Error logging out: \(error.localizedDescription)")
                                    alertMsg = "Error logging out: \(error.localizedDescription)"
                                }
                                showAlert = true
                            }
                        } else {
                            navPath.append("Auth")
                        }
                    }) {
                        Text(isLoggedIn ? "Log Out" : "Log In")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.10))
                            .cornerRadius(16)
                            .foregroundColor(isLoggedIn ? .red : .blue)
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                    }
                }
                .padding(.horizontal, 28)
            }
            .alert("Notification", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMsg)
            }
            .navigationDestination(for: String.self) { value in 
                switch value {
                case "MyDreams":
                    MyDreamsView()
                case "SavedDreams":
                    SavedDreamsView()
                case "ChangePassword":
                    ChangePasswordView()
                case "Auth":
                    // Navigate to authentication view
                    AuthView()
                default:
                    EmptyView()
                }
            }
        }
        .onAppear{
            // Check if user is logged in
            guard appViewModel.isLoggedIn != nil else {
                isLoggedIn = false
                userName = "Guest"
                userImage = nil
                return
            }
            isLoggedIn = appViewModel.isLoggedIn
            guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
            
            // Fetch user data from Firestore
            FirebaseService.fetchSingleUser(uid: uid) { success, error, user in
                if success, let user = user {
                    self.userName = user.name
                    self.userImage = user.avatar // Assuming avatar is the image URL or name
                    print("User data fetched successfully: \(user)")
                } else if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                } else {
                    print("Error fetching user data: \(String(describing: error))")
                }
            }
        }
    }
}


// MARK:  - Setting Menu Row
struct SettingMenuRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.medium))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.09))
        .cornerRadius(14)
    }
}

// MARK: - My Dreams View

struct MyDreamsView: View {
    // TODO: Get the user's dreams from the backend API
    @State private var myDreams: [CommunityPost] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(myDreams) { post in
                    // TODO: Replace real post detail view
                    NavigationLink(destination: PostDetailView(articleId: post.articleId)) {
                        PostRowView(post: post)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("My Dreams")
        .background(Color(red: 25/255, green: 24/255, blue: 40/255).ignoresSafeArea())
        .onAppear {
            // Get the user's dreams from the backend API
            // First Get the user's ID
            guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
                print("User not logged in")
                return
            }
            // Then call the API to fetch user's dreams
            FirebaseService.fetchAuthorAllArticles(authorUid: uid) { success, error, articles in
                if success {
                    if let articles = articles, !articles.isEmpty {
                        // Map articles to CommunityPost
                        myDreams = articles.map { article in
                            CommunityPost(
                                articleId: article.id,
                                imageName: article.image,
                                title: article.title,
                                text: article.text,
                                likes: article.likedCount
                            )
                        }
                    }
                } else if let error = error {
                    print("Error fetching user's dreams: \(String(describing: error))")
                } else {
                    print("No dreams found for this user.")
                }
            }
        }
    }
}

// MARK: - Saved Dreams View
struct SavedDreamsView: View {
    // TODO: Get the user's saved dreams from the backend API
    @State private var savedArticles: [String] = [] // Array of article IDs
    @State private var savedDreams: [CommunityPost] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(savedDreams) { post in
                    // TODO: Replace real post detail view
                    NavigationLink(destination: PostDetailView(articleId: post.articleId)) {
                        PostRowView(post: post)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Saved Dreams")
        .background(Color(red: 25/255, green: 24/255, blue: 40/255).ignoresSafeArea())
        .onAppear {
            // Get the user's saved dreams from the backend API
            // First Get the user's ID and Get user info of savedArticles
            guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
                print("User not logged in")
                return
            }
            FirebaseService.fetchSingleUser(uid: uid) { success, error, user in
                if success, let user = user {
                    // Assuming user.savedArticles is an array of article IDs
                    self.savedArticles = user.savedArticles
                    print("User's saved articles: \(self.savedArticles)")
                } else if let error = error {
                    print("Error fetching user's saved articles: \(error.localizedDescription)")
                } else {
                    print("No saved articles found for this user.")
                }
            }
            // And fetch all saved articles by the user savedArticles(String Array)
            for articleId in savedArticles {
                FirebaseService.fetchSingleArticle(articleId: articleId) { success, error, article in
                    if success, let article = article {
                        // Map articles to CommunityPost
                        let post = CommunityPost(
                            articleId: article.id,
                            imageName: article.image,
                            title: article.title,
                            text: article.text,
                            likes: article.likedCount
                        )
                        savedDreams.append(post)
                    } else if let error = error {
                        print("Error fetching saved article \(articleId): \(error.localizedDescription)")
                    } else {
                        print("No article found for ID \(articleId).")
                    }
                }
            }
        }
    }
}

// MARK: - Change Password View 
struct ChangePasswordView: View {
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showOld = false
    @State private var showNew = false
    @State private var showConfirm = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        VStack(spacing: 26) {
            Group {
                PasswordField(placeholder: "Old Password", text: $oldPassword, isSecure: !showOld, toggle: { showOld.toggle() })
                PasswordField(placeholder: "New Password", text: $newPassword, isSecure: !showNew, toggle: { showNew.toggle() })
                PasswordField(placeholder: "Confirm New Password", text: $confirmPassword, isSecure: !showConfirm, toggle: { showConfirm.toggle() })
            }
            .padding(.top, 18)

            Button(action: {
                // Basic validation
                guard !oldPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
                    alertMsg = "Please fill in all fields."
                    showAlert = true
                    return
                }
                guard newPassword == confirmPassword else {
                    alertMsg = "New passwords do not match."
                    showAlert = true
                    return
                }
                // TODO: Call API to change password
                FirebaseService.changePassword(newPassword: newPassword){ success, error in
                    if success{
                        alertMsg = "Password changed successfully"
                        showAlert = true
                    }else{
                        alertMsg = "Something went wrong while changing the password"
                        showAlert = true
                    }
                }
//                alertMsg = "New Password was sented to the server."
//                showAlert = true
            }) {
                Text("Confirm Change")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.85))
                    .cornerRadius(14)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Change Password")
        .background(Color(red: 25/255, green: 24/255, blue: 40/255).ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMsg), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: Password Field View
struct PasswordField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    let toggle: () -> Void

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            Button(action: toggle) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .padding()
        .background(Color.white.opacity(0.14))
        .cornerRadius(10)
    }
}

// MARK: - One Post View Row (Rank and Explore use this)
struct PostRowView: View {
    let post: CommunityPost
    
    var body: some View {
        HStack(spacing: 14) {
            if post.imageName.hasPrefix("http"){
                AsyncImage(url: URL(string: post.imageName)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // 載入中
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 74, height: 74)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "xmark.octagon") // 載入失敗
                    @unknown default:
                        EmptyView()
                    }
                }
            }else{
                Image(post.imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 74, height: 74)
                    .clipped()
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(post.text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "right.arrow")
                .foregroundColor(.pink)
                .font(.caption)
        }
        .padding(10)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }
}

// MARK: - Preview
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .preferredColorScheme(.dark)
            .environmentObject(AppViewModel()) // Provide AppViewModel for preview
    }
}
