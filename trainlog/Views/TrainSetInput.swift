import SwiftUI

struct TrainingInputForm: View {
    @ObservedObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Exercise input with suggestions
            ExerciseInputField(viewModel: viewModel)
            
            // Weight and reps steppers
            HStack(spacing: 16) {
                // Weight stepper
                VStack(alignment: .leading, spacing: 4) {
                    Text("Вес (кг)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    NumericStepper(
                        value: $viewModel.weight,
                        numberType: .integer,
                        step: 1,
                        range: 0...500,
                        swipeSensitivity: 30.0
                    )
                }
                
                // Reps stepper
                VStack(alignment: .leading, spacing: 4) {
                    Text("Повторения")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    NumericStepper(
                        value: $viewModel.reps,
                        numberType: .integer,
                        step: 1,
                        range: 1...100,
                        swipeSensitivity: 30.0
                    )
                }
            }
            
            // Time section
            //timeSection
            
            // Save button
            saveButton
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            // Скрываем suggestions при тапе вне поля ввода
            if viewModel.showExerciseSuggestions {
                viewModel.showExerciseSuggestions = false
            }
        }
    }
    
    private var timeSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Начало")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $viewModel.startTime, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Окончание")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $viewModel.endTime, in: viewModel.startTime..., displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
            }
            
            if viewModel.endTime > viewModel.startTime {
                let duration = viewModel.endTime.timeIntervalSince(viewModel.startTime)
                Text("Длительность: \(viewModel.formatDuration(duration))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            viewModel.saveTrainingSet()
            viewModel.showExerciseSuggestions = false
        }) {
            Text("Добавить подход")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.canSave ? Color.blue : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!viewModel.canSave)
    }
}
