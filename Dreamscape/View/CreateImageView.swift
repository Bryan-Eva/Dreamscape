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
    var imageName: String
    let emotions: [String]
    let topics: [String]
}

// MARK: - Subviews

struct DreamTextEditor: View {
    @Binding var inputText: String

    var body: some View {
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
    }
}

struct GeneratedResultView: View {
    let result: GeneratedResult
    @Binding var additionalInput: String
    @Binding var image:UIImage?
    let onImageTap: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .cornerRadius(14)
                    .shadow(radius: 6)
                    .onTapGesture {
                        onImageTap()
                    }
            }else{
                Image(result.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .cornerRadius(14)
                    .shadow(radius: 6)
                    .onTapGesture {
                        onImageTap()
                    }
            }
        
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
}

struct ButtonBarView: View {
    let isLoading: Bool
    let hasGenerated: Bool
    let generatedResult: GeneratedResult?
    let inputText: String
    let onCreate: () -> Void
    let onSave: () async -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onCreate) {
                Text("Create")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(18)
            }
            .disabled(inputText.isEmpty || isLoading)
            
            Button{
                Task{
                    await onSave()
                }
            }label: {
                Text("Save")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.13))
                    .foregroundColor(.white)
                    .cornerRadius(18)
            }
            .disabled(!hasGenerated || isLoading || generatedResult == nil)
        }
        .padding(.horizontal)
        .padding(.bottom, 18)
    }
}

// MARK: - Main View
struct CreateImageView: View {
    @State private var isLoading = false
    @State private var hasGenerated = false
    @State private var inputText: String = ""
    @State private var additionalInput: String = ""
    @State private var generatedResult: GeneratedResult? = nil
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack {
            AnimatedStarfieldBackground(starCount: 72)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                DreamTextEditor(inputText: $inputText)

                if isLoading {
                    ProgressView("Generating your dream...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.vertical, 32)
                }

                if let result = generatedResult, hasGenerated, !isLoading {
                    GeneratedResultView(result: result, additionalInput: $additionalInput,image: $selectedImage,onImageTap: {
                        showImagePicker = true
                    })
                }

                Spacer()

                ButtonBarView(
                    isLoading: isLoading,
                    hasGenerated: hasGenerated,
                    generatedResult: generatedResult,
                    inputText: inputText,
                    onCreate: {
                        guard !inputText.isEmpty else { return }
                        isLoading = true
                        hasGenerated = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            // Call your backend API here
                            Task {
                                do {
                                    let (resultEmotions, resultTopics) = try await FirebaseService.askOpenRouter(text: inputText)
                                    self.generatedResult = GeneratedResult(
                                        imageName: "dream_image", // Replace with actual image name from backend
                                        emotions: resultEmotions ?? [],
                                        topics: resultTopics ?? []
                                    )
                                    self.isLoading = false
                                    withAnimation { self.hasGenerated = true }
                                } catch {
                                    print("error: \(error.localizedDescription)")
                                    showAlert = true
                                    alertMessage = "Error generating image: \(error.localizedDescription)"
                                    isLoading = false
                                    return
                                }
                            }
                        }
                    },
                    onSave: {
                        guard let result = generatedResult else { return }
                        if let img = selectedImage{
                            do{
                                let url = try await FirebaseService.uploadImage(image: img)
                                generatedResult?.imageName = url
                            }catch{
                                
                            }
                        }
                        createPost()
                    }
                )
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
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                self.selectedImage = image
            }
        }
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

        FirebaseService.createArticle(article: newArticle) { success, error in
            if success {
                inputText = ""
                additionalInput = ""
                generatedResult = nil
                hasGenerated = false
                showAlert = true
                alertMessage = "Article created successfully!"
            } else {
                showAlert = true
                alertMessage = "Error creating article: \(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }
}

#Preview {
    CreateImageView()
        .preferredColorScheme(.dark)
}
