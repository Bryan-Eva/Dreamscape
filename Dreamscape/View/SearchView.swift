//
//  SearchView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: - Data Model
struct DreamSearchResult: Identifiable, Equatable {
    let id = UUID()
    let articleId: String
    let title: String
    let text: String
}

// MARK: - Search Mode 
enum SearchMode: String, CaseIterable {
    case normal = "Normal"
    case time = "Time"
}

// MARK: SearchView
struct SearchView: View {
    @State private var mode: SearchMode = .normal
    @State private var keyword: String = ""
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var results: [DreamSearchResult] = []
    @State private var isSearching = false


    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                // call Dynamic Background
                AnimatedStarfieldBackground(starCount: 72)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Search Dreams")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Segmented Picker for Search Mode
                    Picker("Mode", selection: $mode) {
                        ForEach(SearchMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Search Bar
                    if mode == .normal {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Enter keyword...", text: $keyword)
                                .foregroundColor(.white)
                                .disableAutocorrection(true)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.09))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Start Time").foregroundColor(.white).font(.caption)
                            DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .colorScheme(.dark)
                            Text("End Time").foregroundColor(.white).font(.caption)
                            DatePicker("End", selection: $endDate, displayedComponents: [.date])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .colorScheme(.dark)
                        }
                        .padding(.horizontal)
                    }
                    // Search Button
                    Button(action: {
                        // TODO: call Backend API with keyword or date range
                        isSearching = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if mode == .normal {                               
                                print("Searching by keyword: \(keyword)")
                                // Search by keyword
                                FirebaseService.searchArticles(keyword: keyword, startDate: nil, endDate: nil) { success, error, articles in
                                    if let error = error {
                                        print("Error searching articles: \(error.localizedDescription)")
                                        self.isSearching = false
                                        return
                                    }
                                    guard let articles = articles else {
                                        self.results = []
                                        self.isSearching = false
                                        return
                                    }
                                    
                                    // Convert articles to search results
                                    self.results = articles.map { article in
                                        DreamSearchResult(articleId: article.id, title: article.title, text: article.text)
                                    }
                                }
                            } else {
                                print("Searching by date range: \(startDate) to \(endDate)")
                                // Search by date range
                                FirebaseService.searchArticles(keyword: "", startDate: startDate, endDate: endDate) { sucess, error, articles in
                                    if let error = error {
                                        print("Error searching articles: \(error.localizedDescription)")
                                        self.isSearching = false
                                        return
                                    }
                                    guard let articles = articles else {
                                        self.results = []
                                        self.isSearching = false
                                        return
                                    }
                                    
                                    // Convert articles to search results
                                    self.results = articles.map { article in
                                        DreamSearchResult(articleId: article.id, title: article.title, text: article.text)
                                    }                                   
                                }
                            }
                            self.isSearching = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Search")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.purple.opacity(0.85))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 2)
                    

                    // Divider
                    Divider().background(Color.white.opacity(0.15)).padding(.horizontal, 4)

                    // Search Results
                    ScrollView {
                        if isSearching {
                            ProgressView("Searching...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        } else if results.isEmpty {
                            Text("No results found")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                // Each result is a DreamSearchResult
                                ForEach(results) { result in
                                    NavigationLink(destination: PostDetailView(articleId: result.articleId)) {
                                        SearchResultView(result: result)
                                    }
                                }
                            }
                            .padding(.bottom, 32)
                        }
                    }
                    .background(Color.clear)
                    .scrollIndicators(.hidden)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


// MARK: Sub Views for a search Result
struct SearchResultView: View {
    let result: DreamSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(result.text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.77))
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .shadow(radius: 1)
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}