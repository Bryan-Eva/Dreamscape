//
//  FirebaseService.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/11.
//
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    // auth
    static func userRegister(
        mail: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: mail, password: password) {
            result,
            error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func userLogin(
        mail: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: mail, password: password) {
            result,
            error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func userLogout(completion: @escaping (Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let signOutError {
            completion(false, signOutError)
        }
    }

    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func changePassword(
        newPassword: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard let user = Auth.auth().currentUser else {
            completion(false, NSError(domain: "ChangePassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "尚未登入"]))
            return
        }

        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("變更密碼失敗: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("變更密碼成功")
                completion(true, nil)
            }
        }
    }

    // user (CRU)
    static func fetchSingleUser(
        uid: String,
        completion: @escaping (Bool, Error?, User?) -> Void
    ) {

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { document, error in
            if let error = error {
                completion(false, error, nil)
                return
            }

            guard let document = document, document.exists,
                let user = Utils.docToUser(doc: document)
            else {
                completion(false, nil, nil)
                return
            }

            completion(true, nil, user)
        }
    }

    static func updateUser(
        user: User,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.updateData(user.toDictionary()) { error in
            if let error = error {
                print("更新失敗: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("更新成功")
                completion(true, nil)
            }
        }
    }

    static func createUser(
        user: User,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.setData(user.toDictionary()) { error in
            if let error = error {
                print("建立失敗: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("建立成功")
                completion(true, nil)
            }
        }
    }

    // article (CRU)
    static func fetchSingleArticle(
        articleId: String,
        completion: @escaping (Bool, Error?, Article?) -> Void
    ) {
        let db = Firestore.firestore()
        let articleRef = db.collection("articles").document(articleId)

        articleRef.getDocument { document, error in
            if let error = error {
                completion(false, error, nil)
                return
            }

            guard let document = document, document.exists,
                let article = Utils.docToArticle(doc: document)
            else {
                completion(false, nil, nil)
                return
            }
            completion(true, nil, article)
        }
    }

    static func fetchTodayArticles(
        completion: @escaping (Bool, Error?, [Article]?) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, nil, nil)
            return
        }

        let db = Firestore.firestore()
        let articleRef = db.collection("articles")

        let calendar = Calendar.current
        let now = Date()
        guard
            let startOfDay = calendar.date(
                from: calendar.dateComponents([.year, .month, .day], from: now)
            ),
            let endOfDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: startOfDay
            )
        else {
            completion(false, nil, nil)
            return
        }

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        articleRef
            .whereField("authorUid", isEqualTo: userId)
            .whereField("time", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("time", isLessThan: endTimestamp)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, error, nil)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(false, nil, nil)
                    return
                }

                let articles = documents.compactMap {
                    Utils.docToArticle(doc: $0)
                }
                completion(true, nil, articles)
            }
    }

    static func fetchAuthorAllArticles(
        authorUid: String,
        completion: @escaping (Bool, Error?, [Article]?) -> Void
    ) {
        let db = Firestore.firestore()
        let articlesRef = db.collection("articles")

        articlesRef
            .whereField("authorUid", isEqualTo: authorUid)
            .order(by: "time", descending: true)  // 可選：照時間排序
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, error, nil)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(false, nil, nil)
                    return
                }
                let articles = documents.compactMap { doc in
                    Utils.docToArticle(doc: doc)
                }

                completion(true, nil, articles)
            }
    }

    static func createArticle(
        article: Article,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let data = article.toDictionary()

        // 用自動產生的 document ID
        db.collection("articles").addDocument(data: data) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func updateArticle(
        article: Article,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let data = article.toDictionary()

        db.collection("articles").document(article.id).setData(
            data,
            merge: true
        ) {
            error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func searchArticles(
        keyword: String?,
        startDate: Date?,
        endDate: Date?,
        completion: @escaping (Bool, Error?, [Article]?) -> Void
    ) {
        let db = Firestore.firestore()
        let articlesRef = db.collection("articles")

        var query: Query = articlesRef

        // 處理時間範圍
        if let start = startDate {
            query = query.whereField(
                "time",
                isGreaterThanOrEqualTo: Timestamp(date: start)
            )
        }
        if let end = endDate {
            query = query.whereField(
                "time",
                isLessThanOrEqualTo: Timestamp(date: end)
            )
        }

        // 處理關鍵字
        let keywordTrimmed =
            keyword?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasKeyword = !keywordTrimmed.isEmpty

        if hasKeyword {
            let endKeyword = keywordTrimmed + "\u{f8ff}"
            query = query.order(by: "title")
                .start(at: [keywordTrimmed])
                .end(at: [endKeyword])
        } else {
            // 沒關鍵字時，order by createdAt 避免無序查詢
            query = query.order(by: "time")
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(false, error, nil)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(false, nil, nil)
                return
            }

            let articles = documents.compactMap { Utils.docToArticle(doc: $0) }
            completion(true, nil, articles)
        }
    }
    
    static func likeArticle(
        like: Bool,
        articleId: String,
        userId: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        let articleRef = db.collection("articles").document(articleId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 取得使用者與文章
            let userDoc: DocumentSnapshot
            let articleDoc: DocumentSnapshot
            do {
                try userDoc = transaction.getDocument(userRef)
                try articleDoc = transaction.getDocument(articleRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            // 解析使用者按讚資料
            var likedArticles = userDoc.data()?["likedArticles"] as? [String] ?? []
            var likedCount = articleDoc.data()?["likedCount"] as? Int ?? 0

            if like {
                if !likedArticles.contains(articleId) {
                    likedArticles.append(articleId)
                    likedCount += 1
                }
            } else {
                if likedArticles.contains(articleId) {
                    likedArticles.removeAll { $0 == articleId }
                    likedCount = max(0, likedCount - 1)
                }
            }

            // 更新兩個文件
            transaction.updateData(["likedArticles": likedArticles], forDocument: userRef)
            transaction.updateData(["likedCount": likedCount], forDocument: articleRef)

            return nil
        }) { (_, error) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    // comment (CR)
    static func createComment(
        comment: Comment,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let data = comment.toDictionary()

        db.collection("comments").addDocument(data: data) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func fetchComments(
        for articleId: String,
        completion: @escaping (Bool, Error?, [Comment]?) -> Void
    ) {
        let db = Firestore.firestore()
        db.collection("comments")
            .whereField("articleId", isEqualTo: articleId)
            .order(by: "time", descending: false)  // 按時間排序（最舊到最新）
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, error, nil)
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(true, nil, [])  // 沒留言回空陣列
                    return
                }

                let comments = docs.compactMap { doc -> Comment? in
                    return Comment(
                        id: doc.documentID,
                        articleId: doc.data()["articleId"] as? String ?? "",
                        text: doc.data()["text"] as? String ?? "",
                        time: doc.data()["time"] as? Timestamp
                            ?? Timestamp(date: Date()),
                        uid: doc.data()["uid"] as? String ?? ""
                    )
                }
                completion(true, nil, comments)
            }
    }

    // other
    static func uploadImage(
        image: UIImage
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(
                domain: "ImgbbUploader",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "圖片轉換失敗"]
            )
        }

        let apiKey = try await getAPIKey(for: "imgbb")

        let url = URL(string: "https://api.imgbb.com/1/upload?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append(
            "Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n"
        )
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body
        request.timeoutInterval = 60

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoded = try JSONDecoder().decode(ImgbbResponse.self, from: data)
        return decoded.data.url
    }

    static func getAPIKey(for keyName: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let db = Firestore.firestore()
            db.collection("settings").document("api_keys").getDocument {
                document,
                error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let document = document, document.exists {
                    let data = document.data()
                    if let keyValue = data?[keyName] as? String {
                        continuation.resume(returning: keyValue)
                    } else {
                        continuation.resume(
                            throwing: NSError(domain: "APIKeyError", code: -1)
                        )
                    }
                } else {
                    continuation.resume(
                        throwing: NSError(domain: "APIKeyError", code: -2)
                    )
                }
            }
        }
    }

    static func askOpenRouter(text: String) async throws -> ([String], [String])
    {
        let apiKey = try await getAPIKey(for: "openrouter_ai")

        let prompt = """
            以下是使用者描述的一段夢境，請從中分析出「情緒」和「主題」。請以 JSON 格式回傳：
            {
                "emotions": ["情緒1", "情緒2"],
                "topics": ["主題1", "主題2"]
            }

            夢境內容：
            \(text)
            """

        guard
            let url = URL(
                string: "https://openrouter.ai/api/v1/chat/completions"
            )
        else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "openai/gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let responseString = String(data: data, encoding: .utf8) {
            print("API 回應：\(responseString)")
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw NSError(domain: "ParseError", code: -1)
        }

        let trimmedContent = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard
            let contentData = trimmedContent.data(using: .utf8),
            let parsed = try? JSONSerialization.jsonObject(with: contentData)
                as? [String: Any],
            let emotions = parsed["emotions"] as? [String],
            let topics = parsed["topics"] as? [String]
        else {
            print("解析失敗，content:\n\(content)")
            throw NSError(domain: "InvalidResponseFormat", code: -2)
        }

        return (emotions, topics)
    }
}
