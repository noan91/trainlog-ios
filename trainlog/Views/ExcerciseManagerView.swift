import SwiftUI

struct ExerciseManagementView: View {
    @ObservedObject var exerciseManager: ExerciseManager
    @State private var newExercise = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Добавить новое упражнение")) {
                    HStack {
                        TextField("Название упражнения", text: $newExercise)
                        Button(action: addExercise) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newExercise.isEmpty)
                    }
                }
                
                Section(header: Text("Недавние упражнения")) {
                    if exerciseManager.recentExercises.isEmpty {
                        Text("Нет недавних упражнений")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(exerciseManager.recentExercises, id: \.self) { exercise in
                            Text(exercise)
                        }
                    }
                }
                
                Section(header: Text("Избранные упражнения")) {
                    ForEach(exerciseManager.favoriteExercises, id: \.self) { exercise in
                        Text(exercise)
                    }
                    .onDelete { indexSet in
                        exerciseManager.favoriteExercises.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Управление упражнениями")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addExercise() {
        exerciseManager.addFavoriteExercise(newExercise)
        newExercise = ""
    }
}
