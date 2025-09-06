import SwiftUI

struct TrainingSetRow: View {
    let trainSet: TrainSet
    let viewModel: TrainingViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Exercise and details
            VStack(alignment: .leading, spacing: 4) {
                Text(trainSet.exercise)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text("\(trainSet.weight) кг")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("\(trainSet.reps) повтор.")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Text(viewModel.formatDuration(trainSet.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Time
            VStack(alignment: .trailing, spacing: 2) {
                Text(trainSet.startTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(trainSet.endTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
