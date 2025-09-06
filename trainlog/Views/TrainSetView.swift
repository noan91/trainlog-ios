import SwiftUI

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @State private var showingExerciseManagement = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Список подходов (сверху)
                listSection
                
                // Форма ввода (снизу)
                inputSection
            }
            .navigationTitle("Тренировка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingExerciseManagement = true
                    }) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.trainSets.isEmpty {
                        clearButton
                    }
                }
            }
            .sheet(isPresented: $showingExerciseManagement) {
                ExerciseManagementView(exerciseManager: viewModel.exerciseManager)
            }
        }
    }
    

    
    private var listSection: some View {
        Group {
            if viewModel.trainSets.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.trainSets) { trainSet in
                        TrainingSetRow(trainSet: trainSet, viewModel: viewModel)
                    }
                    .onDelete(perform: viewModel.deleteSet)
                }
                .listStyle(PlainListStyle())
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            TrainingInputForm(viewModel: viewModel)
                .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "dumbbell")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("Нет подходов")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Добавьте первый подход используя форму ниже")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var clearButton: some View {
        Button(action: {
            viewModel.trainSets.removeAll()
        }) {
            Text("Очистить")
                .foregroundColor(.red)
        }
    }
}


struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
    }
}
