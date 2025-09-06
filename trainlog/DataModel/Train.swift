//
//  Train.swift
//  trainlog
//
//  Created by Стас Чечура on 6.09.25.
//

import Foundation

struct TrainSet: Identifiable, Codable {
    let id: UUID
    var exercise: String
    var weight: Int
    var reps: Int
    var startTime: Date
    var endTime: Date
    
    init(id: UUID = UUID(), exercise: String, weight: Int, reps: Int, startTime: Date, endTime: Date) {
        self.id = id
        self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}

// Модель для управления списком упражнений
class ExerciseManager: ObservableObject {
    @Published var favoriteExercises: [String] = [
        "Жим лёжа",
        "Приседания",
        "Становая тяга",
        "Подтягивания",
        "Отжимания",
        "Жим штанги стоя",
        "Тяга штанги в наклоне",
        "Бицепс со штангой",
        "Трицепс на блоке",
        "Жим ногами",
        "Выпады",
        "Планка"
    ]
    
    @Published var recentExercises: [String] = []
    private let maxRecentExercises = 5
    
    func addRecentExercise(_ exercise: String) {
        // Убираем дубликаты
        recentExercises.removeAll { $0.lowercased() == exercise.lowercased() }
        
        // Добавляем в начало
        recentExercises.insert(exercise, at: 0)
        
        // Ограничиваем количество
        if recentExercises.count > maxRecentExercises {
            recentExercises = Array(recentExercises.prefix(maxRecentExercises))
        }
    }
    
    func addFavoriteExercise(_ exercise: String) {
        if !favoriteExercises.contains(where: { $0.lowercased() == exercise.lowercased() }) {
            favoriteExercises.append(exercise)
            favoriteExercises.sort()
        }
    }
}

struct TrainLog {
    var date: Date
    var trains: [TrainSet]
}
