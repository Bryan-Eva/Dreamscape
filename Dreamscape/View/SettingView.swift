//
//  SettingView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: SettingView
struct SettingView: View {
    @State private var isLoggedIn = true // Simulate login state
    @State private var userName: String = "User123" // Simulate user name
    @State private var userImage: String? = "dream_image" // Simulate user image
    @State private var navPath = NavigationPath()

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
                            Image(img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 94, height: 94)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 94, height: 94)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Text(isLoggedIn ? userName : "Guest")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.top, 4)
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
                            // TODO: Call API to log out
                            isLoggedIn = false
                            userName = "Guest"
                            userImage = nil
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
    let mockPosts: [CommunityPost] = [
        .init(imageName: "dream_image", title: "迷幻森林", text: "在森林裡與動物對話", likes: 123),
        .init(imageName: "dream_image", title: "天空之城", text: "飄浮的島嶼和水晶橋", likes: 88)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(mockPosts) { post in
                    // TODO: Replace real post detail view
                    NavigationLink(destination: DetailView(post: post)) {
                        PostRowView(post: post)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("My Dreams")
        .background(Color(red: 25/255, green: 24/255, blue: 40/255).ignoresSafeArea())
    }
}

// MARK: - Saved Dreams View
struct SavedDreamsView: View {
    // TODO: Get the user's saved dreams from the backend API
    let mockPosts: [CommunityPost] = [
        .init(imageName: "dream_image", title: "三月夜夢", text: "夜空閃耀的星辰與月亮", likes: 77)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(mockPosts) { post in
                    // TODO: Replace real post detail view
                    NavigationLink(destination: DetailView(post: post)) {
                        PostRowView(post: post)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Saved Dreams")
        .background(Color(red: 25/255, green: 24/255, blue: 40/255).ignoresSafeArea())
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
                alertMsg = "New Password was sented to the server."
                showAlert = true
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
            Image(post.imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 74, height: 74)
                .clipped()
                .cornerRadius(12)
            
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