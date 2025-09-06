import SwiftUI

struct ExerciseInputField: View {
    @ObservedObject var viewModel: TrainingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Упражнение")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .trailing) {
                TextField("Введите упражнение", text: $viewModel.exercise)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .focused($isFocused)
                    .onTapGesture {
                        viewModel.showExerciseSuggestions = true
                    }
                    .onChange(of: isFocused) { focused in
                        if focused {
                            viewModel.showExerciseSuggestions = true
                        }
                    }
                
                // Кнопка очистки
                if !viewModel.exercise.isEmpty {
                    Button(action: {
                        viewModel.exercise = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 8)
                }
            }
            
            // Выпадающий список suggestions
            if viewModel.showExerciseSuggestions && !viewModel.filteredExercises.isEmpty {
                ExerciseSuggestionsList(
                    suggestions: viewModel.filteredExercises,
                    onSelect: { exercise in
                        viewModel.selectExercise(exercise)
                        isFocused = false
                    },
                    onDismiss: {
                        isFocused = false
                    }
                )
            }
        }
    }
}

struct ExerciseSuggestionsList: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions, id: \.self) { exercise in
                Button(action: {
                    onSelect(exercise)
                }) {
                    HStack {
                        Text(exercise)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                
                if exercise != suggestions.last {
                    Divider()
                        .padding(.leading, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
