import SwiftUI

struct ChatAIView: View {
    @State private var inputText = "我夢到自己站在一座高樓頂端，看著城市的夜景，突然整個城市陷入黑暗。我感到非常孤單和害怕，然後有一隻貓出現在我腳邊，帶我走進一條發光的小路，最後我出現在小時候的家門口"
    @State private var emotions: [String] = []
    @State private var topics: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("輸入夢境敘述：")
                    .font(.headline)

                TextEditor(text: $inputText)
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .cornerRadius(8)

                Button(action: {
                    analyzeDream()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                        }
                        Text("分析夢境")
                    }
                }
                .disabled(inputText.isEmpty || isLoading)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if let error = errorMessage {
                    Text("錯誤：\(error)")
                        .foregroundColor(.red)
                }

                if !emotions.isEmpty || !topics.isEmpty {
                    Divider()
                    Text("情緒：\(emotions.joined(separator: ", "))")
                    Text("主題：\(topics.joined(separator: ", "))")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("夢境 AI 分析")
        }
    }

    func analyzeDream() {
        isLoading = true
        emotions = []
        topics = []
        errorMessage = nil

        Task {
            do {
                let (resultEmotions, resultTopics) = try await FirebaseService.askOpenRouter(text: inputText)
                emotions = resultEmotions
                topics = resultTopics
            } catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    ChatAIView()
}
