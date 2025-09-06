import Foundation
import Combine

class TrainingViewModel: ObservableObject {
    @Published var exercise: String = ""
    @Published var weight: Double = 0
    @Published var reps: Double = 0
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var trainSets: [TrainSet] = []
    @Published var showExerciseSuggestions = false
    
    private var cancellables = Set<AnyCancellable>()
    let exerciseManager: ExerciseManager
    
    init(exerciseManager: ExerciseManager = ExerciseManager()) {
        self.exerciseManager = exerciseManager
        setupBindings()
    }
    
    private func setupBindings() {
        $endTime
            .sink { [weak self] newEndTime in
                guard let self = self else { return }
                if newEndTime < self.startTime {
                    self.endTime = self.startTime
                }
            }
            .store(in: &cancellables)
        
        // Автоматически показываем suggestions при фокусе
        $exercise
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if !text.isEmpty {
                    self.showExerciseSuggestions = true
                }
            }
            .store(in: &cancellables)
    }
    
    var canSave: Bool {
        return !exercise.isEmpty &&
              // weight > 0 &&
               reps > 0 &&
               endTime >= startTime
    }
    
    var filteredExercises: [String] {
        if exercise.isEmpty {
            return exerciseManager.recentExercises + exerciseManager.favoriteExercises
        } else {
            let allExercises = exerciseManager.recentExercises + exerciseManager.favoriteExercises
            return allExercises.filter {
                $0.lowercased().contains(exercise.lowercased())
            }
        }
    }
    
    func saveTrainingSet() {
        guard canSave else { return }
        
        let newSet = TrainSet(
            exercise: exercise,
            weight: Int(weight),
            reps: Int(reps),
            startTime: startTime,
            endTime: endTime
        )
        
        // Добавляем в историю упражнений
        exerciseManager.addRecentExercise(exercise)
        
        trainSets.insert(newSet, at: 0)
    }
    
    func clearForm() {
        exercise = ""
        weight = 0
        reps = 0
        startTime = Date()
        endTime = Date()
        showExerciseSuggestions = false
    }
    
    func selectExercise(_ selectedExercise: String) {
        exercise = selectedExercise
        showExerciseSuggestions = false
    }
    
    func deleteSet(at offsets: IndexSet) {
        trainSets.remove(atOffsets: offsets)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
