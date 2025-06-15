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

    // User to Topics Images (fix)
    let topicImages: [[String]] = [
        ["dream_image", "dream_image", "dream_image", "dream_image", "dream_image"],
        ["dream_image", "dream_image", "dream_image", "dream_image", "dream_image"],
        ["dream_image", "dream_image", "dream_image", "dream_image", "dream_image"]
    ]

    @State private var topicSetIndex = 0

    // Sample Data for Popular Posts
    let mockPopularPosts: [CommunityPost] = [
        .init(articleId: "0", imageName: "dream_image", title: "奇幻夢", text: "在充滿魔法的古堡裡探險", likes: 142),
        .init(articleId: "1", imageName: "dream_image", title: "在一座城市的夢", text: "穿梭在現代與虛幻之間", likes: 105),
        .init(articleId: "2", imageName: "dream_image", title: "充滿奇異月亮的夢", text: "夜空下的三個新月", likes: 89)
    ]
    
    // Sample Data for Topics
    let mockTopics: [String] = ["奇幻夢", "現實夢", "詭異夢", "冒險夢", "溫馨夢"]

    // Sample Data for Explore/Topic Posts
    let mockAllPosts: [CommunityPost] = [
        .init(articleId: "3", imageName: "dream_image", title: "奇幻夢", text: "在充滿魔法的古堡裡探險", likes: 142),
        .init(articleId: "4", imageName: "dream_image", title: "現實夢", text: "現實交錯的奇妙瞬間", likes: 95),
        .init(articleId: "5",imageName: "dream_image", title: "冒險夢", text: "一場前往未知世界的冒險", likes: 80),
        .init(articleId: "6",imageName: "dream_image", title: "詭異夢", text: "黑暗走廊盡頭的綠光", likes: 72)
    ]

    // State
    @State private var currentTopicFilter: String? = nil

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
                                posts: mockPopularPosts,
                                topics: Array(mockTopics.prefix(5)).enumerated().map { idx, name in 
                                    CommunityTopic(name: name, imageName: topicImages[topicSetIndex % topicImages.count][idx])
                                },
                                onSelectTopic: { topic in
                                    goToExplore(with: topic.name)
                                }
                            )
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        if selectedTab == .explore {
                            ExploreSection(
                                allPosts: mockAllPosts,
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
                        NavigationLink(destination: DetailView(post: post)) {
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
        if let topic = topicFilter, !topic.isEmpty {
            return allPosts.filter { $0.title == topic }
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
                        NavigationLink(destination: DetailView(post: post)) {
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