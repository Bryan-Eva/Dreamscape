//
//  CommunityView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: - Data Model
struct CommunityPost: Identifiable,  Equatable {
    let id = UUID()
    let articleId: String
    let imageName: String
    let title: String
    let text: String
    let likes: Int
    // topics(Optiona) only for Explore Section when filtering by topic
    var topics: [String]?
}

struct CommunityTopic: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String
}

// MARK: - ENUM for Tab
enum CommunityTab: Int, CaseIterable {
    case popular = 0
    case explore = 1

    var title: String {
        switch self {
        case .popular:  return "熱門與分類"
        case .explore:  return "探索"
        }
    }
}

// MARK: Main CommunityView
struct CommunityView: View {
    @State private var selectedTab: CommunityTab = .popular
    @State private var allPosts: [CommunityPost] = []
    @State private var allTopics: [CommunityTopic] = []
    @State private var top5Posts: [CommunityPost] = []
    @State private var top5Topics: [CommunityTopic] = []
    @State private var topicCounts: [String: Int] = [:]
    @State private var topicSetIndex = 0
    @State private var currentTopicFilter: String? = nil
    
    // User to Topics Images (fix)
        let topicImages: [String] = [
            "dream_image1", "dream_image2", "dream_image3", "dream_image4", "dream_image5",
            "dream_image6", "dream_image7", "dream_image8", "dream_image9", "dream_image10",
            "dream_image11", "dream_image12", "dream_image13", "dream_image14", "dream_image15"
        ]

    // Switch to Explore Tab and with topic filter
    func goToExplore(with topic: String) {
        currentTopicFilter = topic
        selectedTab = .explore
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                // call Dynamic Background
                AnimatedStarfieldBackground(starCount: 72)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("Community 社群探索")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 32)

                    // Custom Tab Bar
                    CommunityTabBar(selected: $selectedTab)
                        .padding(.top, 12)
                        .padding(.bottom, 18)

                    // Animated Content Switch
                    ZStack {
                        if selectedTab == .popular {
                            PopularAndTopicsSection(
                                posts: top5Posts,
                                topics: top5Topics,
                                onSelectTopic: { topic in
                                    goToExplore(with: topic.name)
                                }
                            )
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        if selectedTab == .explore {
                            ExploreSection(
                                allPosts: allPosts,
                                topicFilter: currentTopicFilter,
                                onClearTopic: {
                                    currentTopicFilter = nil
                                }
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: selectedTab)

                    Spacer()
                }
            }.onAppear {
                // Reset topic index when view appears
                topicSetIndex = 0
                // call Backend API to all posts and topics, and set the top 5 posts by likes and topics
                FirebaseService.searchArticles(keyword: nil, startDate: nil, endDate: nil) { success, error, articles in
                    if error != nil {
                        print("Error fetching articles: \(error!.localizedDescription)")
                        return
                    }
                    guard success, let articles = articles else {
                        print("No articles found")
                        return
                    }
                    // Convert articles to CommunityPost
                    self.allPosts = articles.map { article in
                        CommunityPost(articleId: article.id, imageName: article.image, title: article.title, text: article.text, likes: article.likedCount, topics: article.topics)
                    }
                    // First: Get and Store all topics from articles
                    let topicsSet = Set(articles.flatMap { $0.topics })
                    self.allTopics = topicsSet.enumerated().map { idx, topicName in
                        // Use a default image for now, can be replaced with actual images later
                        let imageName = self.topicImages[idx % self.topicImages.count] // Placeholder image
                        return CommunityTopic(name: topicName, imageName: imageName)
                    }
                    // And count each topic's number of occurrences when iterating through articles
                    self.topicCounts = [:]
                    for article in articles {
                        for topic in article.topics {
                            topicCounts[topic, default: 0] += 1
                        }
                    }
                    // Second: Sort and get top 5 posts by likes
                    self.top5Posts = self.allPosts.sorted(by: { $0.likes > $1.likes }).prefix(5).map { $0 }
                    // Third: Sort and get top 5 topics by occurrences
                    self.top5Topics = self.allTopics.sorted(by: { topicCounts[$0.name, default: 0] > topicCounts[$1.name, default: 0] }).prefix(5).map { $0 }
                }
            }
        }
    }
}

// MARK: - Custom Tab Bar (Threads Style)
struct CommunityTabBar: View {
    @Binding var selected: CommunityTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CommunityTab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation { selected = tab }
                }) {
                    VStack(spacing: 4) {
                        Text(tab.title)
                            .font(.system(size: 14, weight: selected == tab ? .bold : .regular))
                            .foregroundColor(selected == tab ? .white : Color.white.opacity(0.55))

                        // indicator
                        Capsule()
                            .fill(selected == tab ? Color.white : Color.clear)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 40)
                }   
            }
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}


// MARK: - Popular Posts and Topics
struct PopularAndTopicsSection: View {
    let posts: [CommunityPost]
    let topics: [CommunityTopic]
    let onSelectTopic: (CommunityTopic) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Popular Posts
                Text("每週熱門夢境排行榜")  
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(articleId: post.articleId)) {
                            CommunityPostRowView(post: post)
                        }
                    }
                }
                .padding(.horizontal)

                // Topics
                Text("主題分類")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(topics) { topic in
                            Button(action: {
                                onSelectTopic(topic)
                            }) {
                                CommunityTopicCardView(topic: topic)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .padding(.top)
        }
    }
}

// MARK: - Explore Section
struct ExploreSection: View {
    let allPosts: [CommunityPost]
    let topicFilter: String?
    let onClearTopic: () -> Void

    var filteredPosts: [CommunityPost] {
        // we only return match at leat one topic in posts
        if let topic = topicFilter, !topic.isEmpty {
            return allPosts.filter { $0.topics?.contains(topic) == true }
        }
        return allPosts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let topic = topicFilter {
                HStack {
                    Text("Topics: \(topic)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("Clear") {
                        onClearTopic()
                    }
                    .foregroundColor(.purple)
                }
                .padding(.horizontal)
            } else {
                Text("All Posts") 
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(filteredPosts) { post in
                        NavigationLink(destination: PostDetailView(articleId: post.articleId)) {
                            CommunityPostRowView(post: post)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 18)
            }
        }
        .padding(.top)
    }
}

// MARK: - One Post View Row (Rank and Explore use this)
struct CommunityPostRowView: View {
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
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.caption)
                Text("\(post.likes)")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }
}

// MARK: - Topics Card View
struct CommunityTopicCardView: View {
    let topic: CommunityTopic
    
    var body: some View {
        VStack(spacing: 4) {
            Image(topic.imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 74, height: 74)
                .clipped()
                .cornerRadius(12)

            Text(topic.name)
                .font(.caption)
                .foregroundColor(.white)
                .frame(maxWidth: 74)
                .lineLimit(1)
                .padding(.top, 2)
                .padding(.bottom, 2)
                .background(Color.black.opacity(0.2))
                .cornerRadius(6)
        }
        .frame(width: 74)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .shadow(radius:1)
    }
}

// Preview for CommunityView
// struct CommunityView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunityView()
//            .preferredColorScheme(.dark)
//    }
//}
