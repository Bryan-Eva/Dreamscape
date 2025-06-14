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
                                    "建立時間：\($article.createdAt.wrappedValue.dateValue().formatted(.dateTime.year().month().day()))"
                                )
                                .font(.subheadline)
                                .foregroundColor(.gray)
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
        FirebaseService.fetchAuthorAllArticles(authorUid: uid) {
            success,
            error,
            articles in
            DispatchQueue.main.async {
                isLoading = false
                if success, let articles = articles {
                    self.articles = articles
                } else {
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

        let article = Article(
            id: UUID().uuidString,
            title: title,
            authorUid: uid,
            content: content,
            photo: "",
            createdAt: Timestamp(),
            likedCount: 0,
            savedCount: 0,
            topic: "這裡測試一下喔"
        )

        FirebaseService.createArticle(article: article) { success, error in
            if success {
                onCreated()
                dismiss()
            }else{
                title = error?.localizedDescription ?? ""
            }
        }
    }
}

#Preview {
    ArticleView()
}
