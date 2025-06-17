//
//  PostDetailView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/15.
//

import SwiftUI

// MARK: - Data Models
struct DreamDetail: Identifiable {
    let id = UUID()
    let username: String
    let title: String
    let imageName: String
    let text: String
    let emotions: [String]
    let topics: [String]
    let likes: Int
    let comments: [DreamComment]
}

struct DreamComment: Identifiable {
    let id = UUID()
    let userImage: String?
    let username: String
    let text: String
}

// MARK: - Main PostDetailView
struct PostDetailView: View {
    let articleId: String // Unique identifier for the article to fetch details
    @State private var detail: DreamDetail? = nil
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0
    @State private var showCommentInput: Bool = false
    @State private var newCommentText: String = ""
    @State private var comments: [DreamComment]? = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Title 
                if let detail = detail {
                    Text(detail.title)
                        .font(.system(size:32, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    // User name
                    Text(detail.username)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 2)
                        .padding(.bottom, 2)
                        .background(Color.white.opacity(0.18))
                        .cornerRadius(8)
                    
                    if detail.imageName.hasPrefix("http"){
                        AsyncImage(url: URL(string: detail.imageName)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // 載入中
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(18)
                                    .shadow(radius: 4)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                            case .failure:
                                Image(systemName: "xmark.octagon") // 載入失敗
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }else{
                        Image(detail.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(18)
                            .shadow(radius: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }

                    // Dream Text
                    Text(detail.text)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .lineSpacing(3)
                    
                    // Emotions and Topics chips
                    VStack(alignment: .leading, spacing: 8) {
                        if !detail.emotions.isEmpty {
                            Text("Emotions")
                                .font(.caption).foregroundColor(.white.opacity(0.72))
                            ChipsRowView(items: detail.emotions, color: .purple)
                        }

                        if !detail.topics.isEmpty {
                            Text("Topics")
                                .font(.caption).foregroundColor(.white.opacity(0.72))
                            ChipsRowView(items: detail.topics, color: .blue)
                        }
                    }
                    .padding(.top, 2)

                    // Likes / Comments Count
                    HStack(spacing: 22) {
                    // Likes Button
                        Button(action: {
                            isLiked.toggle()
                            if isLiked {
                                likesCount += 1
                            } else {
                                likesCount -= 1
                            }
                            // TODO: call API to update likes count
                        }){
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .pink : .white.opacity(0.5))
                                .scaleEffect(isLiked ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.18), value: isLiked)
                        }
                        Text("\(likesCount)")
                            .foregroundColor(.white)

                        // Comment Button
                        Button(action: {
                            withAnimation { showCommentInput.toggle() }
                        }){
                            Image(systemName: "bubble.right.fill")
                                .foregroundColor(showCommentInput ? .blue : .white.opacity(0.7))
                        }
                        Text("\(detail.comments.count)")
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .font(.subheadline)

                    if showCommentInput {
                        // Comment Input Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment:.bottom, spacing: 8) {
                                TextEditor(text: $newCommentText)
                                    .frame(minHeight: 36, maxHeight: 100)
                                    .padding(6)
                                    .background(Color.white.opacity(0.13))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                Button(action: {
                                    // TODO: call API to post new comment
                                    
                                    //let newComment = DreamComment(
                                    //    userImage: nil, // Placeholder for user image
                                    //    username: "current_user", // Replace with actual username
                                    //    text: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    //)
                                    //comments.insert(newComment, at: 0)
                                    newCommentText = "" // Clear input after posting
                                    withAnimation { showCommentInput = false }
                                }){
                                    Image(systemName: "paperplane.fill")
                                        .font(.title2)
                                        .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .purple)
                                }
                                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(.vertical, 4)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Divider().background(Color.white.opacity(0.25))
                        .padding(.vertical, 3)
                    
                    // Comments Section
                    if !detail.comments.isEmpty {
                        Text("Comments")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 2)

                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(detail.comments) { comment in
                                CommentRowView(comment: comment)  
                            }
                        }
                    } else {
                        Text("No comments yet.")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 36)
        }
        .background(Color(red: 20/255, green: 23/255, blue: 33/255).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var username = ""
            var get_comments: [DreamComment] = []
            // TODO: call API to fetch post details
            FirebaseService.fetchSingleArticle(articleId: self.articleId) { success, error, article in
                DispatchQueue.main.async {
                    if success, let article = article {
                        // Get article username
                        FirebaseService.fetchSingleUser(uid: article.authorUid) { userSuccess, userError, user in
                            if userSuccess, let user = user {
                                username = user.name
                            } else {
                                username = "Unknown User"
                            }
                        }

                        // Get article comments and call function to match DreanComment model 
                        FirebaseService.fetchComments(for: article.id) { commentSuccess, commentError, fetchedComments in
                            if commentSuccess, let current_comments = fetchedComments {
                                get_comments = self.fetchCommentsDetails(current_comments: current_comments)
                            } else {
                                print("Error fetching comments: \(String(describing: commentError))")
                            }
                        }

                        // Set detail
                        self.detail = DreamDetail(
                            username: username,
                            title: article.title,
                            imageName: article.image,
                            text: article.text,
                            emotions: article.emotions,
                            topics: article.topics,
                            likes: article.likedCount,
                            comments: get_comments
                        )
                    } else {
                        print("Error fetching article: \(String(describing: error))")
                    }
                    // Initialize likes count
                    self.likesCount = article?.likedCount ?? 0
                    // Initialize isLiked state
                    self.isLiked = false // Default to not liked, you can change this based on user data
                }
            }
        }
    }

    func fetchCommentsDetails(current_comments: [Comment]) -> [DreamComment] {
        // Because DreamComment model is different from Comment model, we need to convert it
        // And DreamComment has usrImage, username, it needs to call API to fetch user info
        var ret_comments: [DreamComment] = []
        // Loop through each comment and fetch user details
        for comment in current_comments {
            FirebaseService.fetchSingleUser(uid: comment.uid) { success, error, user in
                if success, let user = user {
                    let dreamComment = DreamComment(
                        userImage: user.avatar, // Assuming user.image is the image URL or name
                        username: user.name,
                        text: comment.text
                    )
                    ret_comments.append(dreamComment)
                } else {
                    print("Error fetching user for comment: \(String(describing: error))")
                }
            }
        }
        return ret_comments
    }
}

// MARK: - ChipsRowView (Emotions and Topics)
struct ChipsRowView: View {
    let items: [String]
    let color: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(color.opacity(0.21))
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .cornerRadius(14)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - One Comment View
struct CommentRowView: View {
    let comment: DreamComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // user image (SF Symbol(default) or custom image)
            if let img = comment.userImage, !img.isEmpty {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 38)
                    .foregroundColor(.gray.opacity(0.7))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(comment.username)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.83))

                Text(comment.text)
                    .font(.body)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}
