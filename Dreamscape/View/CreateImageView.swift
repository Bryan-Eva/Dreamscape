//
//  CreateImageView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

// MARK: - Data Model
struct GeneratedResult: Equatable {
    let imageName: String
    let emotions: [String]
    let topics: [String]
}

// MARK: - Main CreateImageView (Before Generate)
struct CreateImageView: View {
    @State private var isLoading = false
    @State private var hasGenerated = false
    @State private var inputText: String = ""
    @State private var additionalInput: String = ""
    @State private var generatedResult: GeneratedResult? = nil
    @State private var showAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack {
            // Background
            // call Dynamic Background
            AnimatedStarfieldBackground(starCount: 72)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Text Input Field
                TextEditor(text: $inputText)
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(14)
                    .frame(height: 80)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.purple.opacity(0.35), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if inputText.isEmpty {
                                Text("Describe your dream...")
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                    )
                    .padding(.horizontal)
                
                if isLoading {
                    // Loading Indicator
                    ProgressView("Generating your dream...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.vertical, 32)
                }

                // after generate (sub view)
                if let result = generatedResult, hasGenerated, !isLoading {
                    VStack(spacing: 18) {
                        Image(result.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .cornerRadius(14)
                            .shadow(radius: 6)

                        HStack(spacing: 8) {
                            ForEach(result.emotions, id: \.self) { emotion in
                                Text(emotion)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.purple.opacity(0.24))
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                        }
                        HStack(spacing: 8) {
                            ForEach(result.topics, id: \.self) { topic in
                                Text(topic)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.24))
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                        }
                        TextField("Add or Modify the theme...", text: $additionalInput)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.purple.opacity(0.25), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .padding(.top)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: result)
                }

                Spacer()

                // Create and Save Button
                HStack(spacing: 16) {
                    Button(action: {
                        // TODO: call Backend API to generate image
                        // simulate loading and return mock data
                        guard !inputText.isEmpty else { return }
                        isLoading = true
                        hasGenerated = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.generatedResult = GeneratedResult(
                                imageName: "dream_image", // 請記得放在 Asset
                                emotions: ["Peaceful", "Mysterious"],
                                topics: ["Fantasy", "Night", "Sky"]
                            )
                            self.isLoading = false
                            withAnimation { self.hasGenerated = true }
                        }
                    }) {
                        Text("Create")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(18)
                    }

                    Button(action: {
                        // TODO: call Backend API to save data
                        guard let result = generatedResult else { return }
                        createPost()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.13))
                            .foregroundColor(.white)
                            .cornerRadius(18)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 18)
            }
            .padding(.top, 32)
        }
        .alert("Notification", isPresented: $showAlert) {
            Button("OK") {
                showAlert = false
            }
        } message: {
            Text(alertMessage)
        }
        .navigationBarTitle("Create Dream Image", displayMode: .inline)
    }

    func createPost() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let newArticle = Article(
            id: "",
            authorUid: uid,
            emotions: generatedResult?.emotions ?? [],
            image: generatedResult?.imageName ?? "dream_image",
            likedCount: 0,
            savedCount: 0,
            text: inputText,
            time: Timestamp(date: Date()),
            title: additionalInput.isEmpty ? "Dream Image" : additionalInput,
            topics: generatedResult?.topics ?? [],
            visible: true
        )
        print("Creating article with data: \(newArticle.toDictionary())")
        print("Current user ID: \(uid)")
        print("Article UID: \(newArticle.id)")
        
        FirebaseService.createArticle(article: newArticle) { success, error in
            if success {
                print("Article created successfully")
                // Reset state after saving
                inputText = ""
                additionalInput = ""
                generatedResult = nil
                hasGenerated = false
                showAlert = true
                alertMessage = "Article created successfully!"
            } else {
                showAlert = true
                alertMessage = "Error creating article: \(error?.localizedDescription ?? "Unknown error")"
                print("Error creating article: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}