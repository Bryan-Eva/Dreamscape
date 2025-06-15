//
//  CreateArticleView.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ArticleView: View {
    @State private var articles: [Article] = []
    @State private var comments: [Comment] = []
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var showCreateSheet = false

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text("錯誤：\(errorMessage)")
                        .foregroundColor(.red)
                } else if isLoading {
                    ProgressView("載入中...")
                } else if articles.isEmpty {
                    Text("你還沒有發佈任何文章")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach($articles) { $article in
                            VStack(alignment: .leading) {
                                Text($article.title.wrappedValue)
                                    .font(.headline)
                                Text(
                                    "建立時間：\($article.time.wrappedValue.dateValue().formatted(.dateTime.year().month().day()))"
                                )
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                        ForEach(comments) { comment in
                            VStack {
                                Text(comment.id)
                                Text(comment.text)
                            }
                        }
                    }
                }

                Button(action: {
                    showCreateSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("新增文章")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .sheet(isPresented: $showCreateSheet) {
                    CreateArticleSheet {
                        loadMyArticles()
                    }
                }
                Button(action: {
                    let comment = Comment(
                        id: "",
                        articleId: articles[0].id,
                        text: "test comment",
                        time: Timestamp(date: Date()),
                        uid: Auth.auth().currentUser!.uid
                    )
                    FirebaseService.createComment(comment: comment) {
                        success,
                        error in
                        if success {
                            loadMyArticles()
                        }else{
                            print(error?.localizedDescription)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("add comment")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("我的文章")
            .onAppear {
                loadMyArticles()
            }
        }
    }

    func loadMyArticles() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "尚未登入"
            return
        }

        isLoading = true
        FirebaseService.fetchTodayArticles() {
            success,
            error,
            articles in
            DispatchQueue.main.async {
                isLoading = false
                if success, let articles = articles {
                    self.articles = articles
                    if !articles.isEmpty {
                        FirebaseService.fetchComments(for: articles[0].id) {
                            success,
                            error,
                            comments in
                            if success, let comments = comments {
                                self.comments = comments
                            }
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "error")
                    self.errorMessage = error?.localizedDescription ?? "讀取失敗"
                }
            }
        }
    }
}

struct CreateArticleSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""

    var onCreated: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("標題", text: $title)
                TextEditor(text: $content)
                    .frame(height: 150)

                Button("送出") {
                    createArticle()
                }
            }
            .navigationTitle("新增文章")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    func createArticle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // 假設你先初始化一個 Article，並且把 authorUid 填入 uid
        let newArticle = Article(
            id: "",  // Firestore 會自動產生 id，可以先空著
            authorUid: uid,
            emotions: [],
            image: "",
            likedCount: 0,
            savedCount: 0,
            text: content,
            time: Timestamp(date: Date()),
            title: title,
            topics: [],
            visible: true
        )

        FirebaseService.createArticle(article: newArticle) { success, error in
            if success {
                onCreated()
                dismiss()
            } else {
                title = error?.localizedDescription ?? ""
            }
        }
    }
}

#Preview {
    ArticleView()
}
