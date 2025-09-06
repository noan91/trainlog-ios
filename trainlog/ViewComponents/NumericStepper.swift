import SwiftUI

struct NumericStepper: View {
    // MARK: - Configuration
    enum NumberType {
        case integer
        case decimal
    }
    
    // MARK: - Properties
    @Binding var value: Double
    @State private var isEditing = false
    @State private var swipeOffset: CGFloat = 0
    @State private var initialValue: Double = 0
    @State private var lastStepChange: Double = 0
    @State private var hapticFeedbackCounter: Int = 0
    
    let numberType: NumberType
    let step: Double
    let range: ClosedRange<Double>?
    let formatter: NumberFormatter
    let swipeSensitivity: CGFloat
    
    // MARK: - Init
    init(value: Binding<Double>,
         numberType: NumberType = .decimal,
         step: Double = 1.0,
         range: ClosedRange<Double>? = nil,
         formatter: NumberFormatter? = nil,
         swipeSensitivity: CGFloat = 30.0) {
        self._value = value
        self.numberType = numberType
        self.step = step
        self.range = range
        self.swipeSensitivity = swipeSensitivity
        
        // Configure default formatter
        if let formatter = formatter {
            self.formatter = formatter
        } else {
            let defaultFormatter = NumberFormatter()
            defaultFormatter.numberStyle = .decimal
            defaultFormatter.minimumFractionDigits = numberType == .integer ? 0 : 1
            defaultFormatter.maximumFractionDigits = numberType == .integer ? 0 : 2
            self.formatter = defaultFormatter
        }
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            // Decrement button
            StepperButton(systemImage: "minus", action: decrement)
                .disabled(isAtMin)
                .padding(.horizontal,4)
            // Text field with swipe gesture
            TextField("", text: textBinding)
                .multilineTextAlignment(.center)
                .keyboardType(numberType == .integer ? .numberPad : .decimalPad)
                .frame(minWidth: 40)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEditing ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    SwipeFeedbackView(offset: swipeOffset, isActive: isEditing)
                )
                .gesture(
                    DragGesture(minimumDistance: 3)
                        .onChanged { gesture in
                            handleSwipeChange(gesture)
                        }
                        .onEnded { gesture in
                            handleSwipeEnd(gesture)
                        }
                )
                .onTapGesture {
                    isEditing = true
                }
            
            // Increment button
            StepperButton(systemImage: "plus", action: increment)
                .disabled(isAtMax)
                .padding(.horizontal,4)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
    
    // MARK: - Computed Properties
    private var isAtMin: Bool {
        guard let range = range else { return false }
        return value <= range.lowerBound
    }
    
    private var isAtMax: Bool {
        guard let range = range else { return false }
        return value >= range.upperBound
    }
    
    private var textBinding: Binding<String> {
        Binding<String>(
            get: {
                if let formattedString = formatter.string(from: NSNumber(value: self.value)) {
                    return formattedString
                }
                return String(format: numberType == .integer ? "%.0f" : "%.2f", self.value)
            },
            set: { newValue in
                // Remove non-numeric characters except decimal point for decimal numbers
                var cleanedValue = newValue
                    .replacingOccurrences(of: formatter.groupingSeparator ?? ",", with: "")
                    .replacingOccurrences(of: formatter.decimalSeparator ?? ".", with: ".")
                
                // Allow only numbers and decimal point for decimal, only numbers for integer
                if numberType == .integer {
                    cleanedValue = cleanedValue.filter { $0.isNumber }
                } else {
                    cleanedValue = cleanedValue.filter { $0.isNumber || $0 == "." }
                    // Ensure only one decimal point
                    if cleanedValue.components(separatedBy: ".").count > 2 {
                        cleanedValue = String(cleanedValue.dropLast())
                    }
                }
                
                if let newDouble = Double(cleanedValue) {
                    var validatedValue = newDouble
                    
                    // Apply range constraints
                    if let range = range {
                        validatedValue = max(range.lowerBound, min(range.upperBound, validatedValue))
                    }
                    
                    // For integer type, round to nearest integer
                    if numberType == .integer {
                        validatedValue = round(validatedValue)
                    }
                    
                    self.value = validatedValue
                } else if cleanedValue.isEmpty {
                    self.value = 0
                }
            }
        )
    }
    
    // MARK: - Swipe Handling
    private func handleSwipeChange(_ gesture: DragGesture.Value) {
        if !isEditing {
            isEditing = true
            initialValue = value
            lastStepChange = 0
            hapticFeedbackCounter = 0
        }
        
        let translation = gesture.translation.width
        swipeOffset = translation
        
        // Calculate how many steps we've moved based on sensitivity
        let swipeDistance = Double(translation)
        let stepsMoved = swipeDistance / Double(swipeSensitivity)
        
        // Calculate the integer number of steps (whole steps only)
        let wholeSteps = (stepsMoved).rounded(.towardZero)
        
        // Only update value when we cross a whole step boundary
        if wholeSteps != lastStepChange {
            let stepDifference = wholeSteps - lastStepChange
            updateValue(by: stepDifference)
            lastStepChange = wholeSteps
        }
    }
    
    private func handleSwipeEnd(_ gesture: DragGesture.Value) {
        // Apply final adjustment based on the remaining fraction
        let translation = gesture.translation.width
        let swipeDistance = Double(translation)
        let finalSteps = swipeDistance / Double(swipeSensitivity)
        let remainingFraction = finalSteps - lastStepChange
        
        // If we've moved more than half a step in the final gesture, apply one more step
        if abs(remainingFraction) >= 0.5 {
            updateValue(by: remainingFraction > 0 ? 1 : -1)
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            swipeOffset = 0
        }
        
        isEditing = false
    }
    
    private func updateValue(by steps: Double) {
        let direction = steps > 0 ? 1.0 : -1.0
        let absoluteSteps = abs(steps)
        
        var newValue = value
        
        // Apply each step individually
        for _ in 0..<Int(absoluteSteps) {
            let potentialNewValue = newValue + (direction * step)
            
            // Check range constraints
            if let range = range {
                if direction > 0 && potentialNewValue > range.upperBound {
                    break
                }
                if direction < 0 && potentialNewValue < range.lowerBound {
                    break
                }
            }
            
            newValue = potentialNewValue
            
            // For integer type, ensure whole numbers
            if numberType == .integer {
                newValue = round(newValue)
            }
        }
        
        // Provide haptic feedback for each step
        if Int(absoluteSteps) > hapticFeedbackCounter {
            provideHapticFeedback()
            hapticFeedbackCounter = Int(absoluteSteps)
        }
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
            value = newValue
        }
    }
    
    // MARK: - Actions
    private func increment() {
        var newValue = value + step
        
        if let range = range {
            newValue = min(newValue, range.upperBound)
        }
        
        // For integer type, ensure whole numbers
        if numberType == .integer {
            newValue = round(newValue)
        }
        
        provideHapticFeedback()
        
        withAnimation(.easeInOut(duration: 0.15)) {
            value = newValue
        }
    }
    
    private func decrement() {
        var newValue = value - step
        
        if let range = range {
            newValue = max(newValue, range.lowerBound)
        }
        
        // For integer type, ensure whole numbers
        if numberType == .integer {
            newValue = round(newValue)
        }
        
        provideHapticFeedback()
        
        withAnimation(.easeInOut(duration: 0.15)) {
            value = newValue
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Stepper Button
private struct StepperButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Swipe Feedback View
private struct SwipeFeedbackView: View {
    let offset: CGFloat
    let isActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background highlight
                if isActive {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                }
                
                // Direction indicator
                if isActive {
                    HStack {
                        if offset > 20 {
                            Spacer()
                            IndicatorView(direction: .right, intensity: min(offset / 100, 1.0))
                                .padding(.trailing, 8)
                        } else if offset < -20 {
                            IndicatorView(direction: .left, intensity: min(abs(offset) / 100, 1.0))
                                .padding(.leading, 8)
                            Spacer()
                        }
                    }
                    .animation(.easeOut, value: offset)
                }
            }
        }
    }
}

// MARK: - Indicator View
private struct IndicatorView: View {
    enum Direction {
        case left, right
    }
    
    let direction: Direction
    let intensity: CGFloat
    
    var body: some View {
        Image(systemName: direction == .right ? "plus.circle.fill" : "minus.circle.fill")
            .font(.system(size: 16))
            .foregroundColor(.blue.opacity(0.7 + intensity * 0.3))
            .scaleEffect(1.0 + intensity * 0.2)
    }
}

// MARK: - Preview
struct NumericStepper_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Integer stepper with step-based swipe
            VStack {
                Text("Integer Stepper (step: 2)")
                    .font(.headline)
                NumericStepper(
                    value: .constant(5.0),
                    numberType: .integer,
                    step: 2,
                    range: 0...100,
                    swipeSensitivity: 40.0
                )
                Text("Свайп изменяет значение с шагом 2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Decimal stepper with small step
            VStack {
                Text("Decimal Stepper (step: 0.5)")
                    .font(.headline)
                NumericStepper(
                    value: .constant(5.0),
                    numberType: .decimal,
                    step: 0.5,
                    range: 0...20,
                    swipeSensitivity: 50.0
                )
                Text("Свайп изменяет значение с шагом 0.5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Custom step size
            VStack {
                Text("Custom Step (шаг: 5)")
                    .font(.headline)
                NumericStepper(
                    value: .constant(25),
                    numberType: .integer,
                    step: 5,
                    range: 0...100,
                    swipeSensitivity: 60.0
                )
                Text("Свайп изменяет значение с шагом 5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .padding()
    }
}
