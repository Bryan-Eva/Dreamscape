//
//  FirebaseService.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/11.
//
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
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

    static func fetchUser(
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

    static func fetchArticle(
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

    static func uploadImage(
        image: UIImage,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(
                nil,
                NSError(
                    domain: "ImgbbUploader",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "圖片轉換失敗"]
                )
            )
            return
        }
        let apiKey = "6fc6470e718bf330be05fa4b4d4995f8"

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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(
                    nil,
                    NSError(
                        domain: "ImgbbUploader",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "沒有回傳資料"]
                    )
                )
                return
            }

            do {
                let decoded = try JSONDecoder().decode(
                    ImgbbResponse.self,
                    from: data
                )
                completion(decoded.data.url, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
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
}
