import SwiftUI

struct ContractionTimerView: View {
    @State private var session = ContractionSession()
    @State private var currentContraction: Contraction?
    @State private var isTimerRunning = false
    @State private var timerValue: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingIntensityPicker = false
    @State private var pendingContraction: Contraction?
    
    var body: some View {
        VStack {
            TimerDisplayView(
                isRunning: isTimerRunning,
                duration: timerValue,
                onStart: startContraction,
                onStop: stopContraction
            )
            
            if !session.contractions.isEmpty {
                StatisticsView(session: session)
                
                ContractionListView(contractions: session.contractions)
            } else {
                ContractionEmptyStateView()
            }
        }
        .navigationTitle("Contraction Timer")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Reset") {
            resetSession()
        }.disabled(session.contractions.isEmpty))
        .sheet(isPresented: $showingIntensityPicker) {
            IntensityPickerView(contraction: $pendingContraction) { contraction in
                if let finalContraction = contraction {
                    session.contractions.append(finalContraction)
                }
                showingIntensityPicker = false
                pendingContraction = nil
            }
        }
    }
    
    private func startContraction() {
        currentContraction = Contraction()
        isTimerRunning = true
        timerValue = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timerValue += 0.1
        }
    }
    
    private func stopContraction() {
        guard var contraction = currentContraction else { return }
        
        contraction.endTime = Date()
        pendingContraction = contraction
        
        currentContraction = nil
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        timerValue = 0
        
        showingIntensityPicker = true
    }
    
    private func resetSession() {
        session = ContractionSession()
        currentContraction = nil
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        timerValue = 0
    }
}

struct TimerDisplayView: View {
    let isRunning: Bool
    let duration: TimeInterval
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text(timeString(from: duration))
                .font(.system(size: 60, weight: .thin, design: .monospaced))
                .foregroundColor(isRunning ? .pink : .primary)
            
            Button(action: isRunning ? onStop : onStart) {
                ZStack {
                    Circle()
                        .fill(isRunning ? Color.red : Color.pink)
                        .frame(width: 120, height: 120)
                    
                    Text(isRunning ? "STOP" : "START")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 40)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let deciseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, deciseconds)
    }
}

struct StatisticsView: View {
    let session: ContractionSession
    
    var body: some View {
        HStack(spacing: 30) {
            StatCard(
                title: "Frequency",
                value: frequencyString,
                icon: "arrow.left.and.right"
            )
            
            StatCard(
                title: "Avg Duration",
                value: durationString,
                icon: "clock"
            )
            
            StatCard(
                title: "Last Hour",
                value: "\(session.lastHourContractions.count)",
                icon: "chart.bar"
            )
        }
        .padding()
    }
    
    private var frequencyString: String {
        guard let frequency = session.averageFrequency else { return "--" }
        return String(format: "%.1f/hr", frequency * 60)
    }
    
    private var durationString: String {
        guard let duration = session.averageDuration else { return "--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ContractionListView: View {
    let contractions: [Contraction]
    
    var body: some View {
        List {
            Section(header: Text("Contraction History")) {
                ForEach(contractions.reversed()) { contraction in
                    ContractionRow(contraction: contraction)
                }
            }
        }
    }
}

struct ContractionRow: View {
    let contraction: Contraction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(contraction.startTime, style: .time)
                    .font(.headline)
                
                if contraction.duration > 0 {
                    Text("Duration: \(durationString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let intensity = contraction.intensity {
                IntensityIndicator(intensity: intensity)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var durationString: String {
        let minutes = Int(contraction.duration) / 60
        let seconds = Int(contraction.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct IntensityIndicator: View {
    let intensity: ContractionIntensity
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < intensity.rawValue ? Color.pink : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 20)
            }
        }
    }
}

struct ContractionEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No contractions recorded")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap START when your contraction begins")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        
        Spacer()
    }
}

struct IntensityPickerView: View {
    @Binding var contraction: Contraction?
    let onComplete: (Contraction?) -> Void
    @State private var selectedIntensity: ContractionIntensity = .moderate
    @State private var notes = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("How was that contraction?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    ForEach(ContractionIntensity.allCases, id: \.self) { intensity in
                        IntensityButton(
                            intensity: intensity,
                            isSelected: selectedIntensity == intensity,
                            action: {
                                selectedIntensity = intensity
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Notes (optional)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(height: 100)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button("Skip") {
                        onComplete(contraction)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Button(action: {
                        if var updatedContraction = contraction {
                            updatedContraction.intensity = selectedIntensity
                            updatedContraction.notes = notes.isEmpty ? nil : notes
                            onComplete(updatedContraction)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.pink)
                            .cornerRadius(25)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

struct IntensityButton: View {
    let intensity: ContractionIntensity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(intensity.description)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index < intensity.rawValue ? (isSelected ? Color.white : Color.pink) : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 20)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.pink : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}