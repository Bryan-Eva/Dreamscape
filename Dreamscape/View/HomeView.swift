//
//  HomeView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: Data Model
struct DreamData {
    let imageName: String
    let description: String
    let emotions: [String]
    let topics: [String]
}

// MARK: HomeView
struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    @State private var isdataEmpty = false
    @State private var isloading = true
    @State private var data: DreamData? = nil
    @State private var article: Article? = nil
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
           ZStack {
                // Background
                // call Dynamic Background
                AnimatedStarfieldBackground(starCount: 72)
                    .ignoresSafeArea()

                if isloading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentColor")))
                        .scaleEffect(1.2)
                        .padding()
                } else if isdataEmpty {
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Text("Dreamscape")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.top, 16)

                            // Dream Description(Text)
                            Text("No dreams found for today. Create your first dream!")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)


                            // Action Buttons
                            VStack(spacing: 20) {
                                Button(action: {
                                    navigationPath.append("create")
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Create Image")
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple.opacity(0.85))
                                    .foregroundColor(.white)
                                    .cornerRadius(18)  
                                }

                                Button(action: { 
                                    navigationPath.append("combine")
                                }) {
                                    HStack {
                                        Image(systemName: "square.grid.2x2")
                                        Text("Combine Images")
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                                }
                                
                            }
                            .padding(.top, 12)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 36)
                    }
                } else if let data = data {
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Text("Dreamscape")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.top, 16)

                            // Dream Image
                            if data.imageName.hasPrefix("http"){
                                AsyncImage(url: URL(string: data.imageName)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // 載入中
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 220)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(20)
                                            .shadow(radius: 8)
                                    case .failure:
                                        Image(systemName: "xmark.octagon") // 載入失敗
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }else{
                                Image(data.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 220)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(20)
                                    .shadow(radius: 8)
                            }

                            // Dream Description(Text)
                            Text(data.description)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)

                            // Emotions and Topics
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(data.emotions, id: \.self) { emotion in
                                        Text(emotion)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.15))
                                            .foregroundColor(.white)
                                            .cornerRadius(14)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(data.topics, id: \.self) { topic in
                                        Text(topic)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.15))
                                            .foregroundColor(.white)
                                            .cornerRadius(14)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Action Buttons
                            VStack(spacing: 20) {
                                Button(action: {
                                    navigationPath.append("create")
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Create Image")
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple.opacity(0.85))
                                    .foregroundColor(.white)
                                    .cornerRadius(18)  
                                }

                                Button(action: { 
                                    navigationPath.append("combine")
                                }) {
                                    HStack {
                                        Image(systemName: "square.grid.2x2")
                                        Text("Combine Images")
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                                }
                                
                            }
                            .padding(.top, 12)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 36)
                    }
                } 
           }
           .onAppear {  
                // TODO: Load data here and call Real Backend API
                FirebaseService.fetchTodayArticles { success, error, articles in
                    DispatchQueue.main.async {
                        if success, let articles = articles {
                            // Handle articles if needed
                            print("Fetched \(articles.count) articles")
                            if articles.isEmpty {
                                self.isdataEmpty = true
                            } else {
                                self.article = articles.first // use the first article for demonstration
                                self.data = DreamData (imageName: self.article?.image ?? "dream_image",
                                                    description: self.article?.text ?? "No description available.",
                                                    emotions: self.article?.emotions ?? ["Unknown"],
                                                    topics: self.article?.topics ?? ["Unknown"])                          
                            }
                        } else {
                            print("Error fetching articles: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
                self.isloading = false
            }
           .navigationDestination(for: String.self) { value in 
                switch value {
                case "create":
                    CreateImageView()
                case "combine":
                    CombineImageView()
                default:
                    EmptyView()
                }
           }
           .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: Preview
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//            .preferredColorScheme(.dark)
//    }
//}
