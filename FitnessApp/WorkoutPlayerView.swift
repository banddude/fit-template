import SwiftUI
import AVFoundation
import AVKit

struct WorkoutPlayerView: View {
    let workoutName: String
    let workoutColor: Color
    let difficulty: WorkoutDifficulty
    let exercises: [WorkoutExercise]
    let startingIndex: Int

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentExerciseIndex: Int
    @State private var showExerciseDetails = false
    
    init(workoutName: String, workoutColor: Color, difficulty: WorkoutDifficulty, exercises: [WorkoutExercise], startingIndex: Int) {
        self.workoutName = workoutName
        self.workoutColor = workoutColor
        self.difficulty = difficulty
        self.exercises = exercises
        self.startingIndex = startingIndex
        self._currentExerciseIndex = State(initialValue: startingIndex)
        print("DEBUG: WorkoutPlayerView init with startingIndex: \(startingIndex)")
    }
    
    var body: some View {
        let _ = print("DEBUG: WorkoutPlayerView body rendering with currentExerciseIndex: \(currentExerciseIndex)")
        ZStack {
            TabView(selection: $currentExerciseIndex) {
                ForEach(exercises.indices, id: \.self) { index in
                    SingleExercisePageView(
                        exercise: exercises[index],
                        difficulty: difficulty,
                        index: index,
                        total: exercises.count,
                        showExerciseDetails: $showExerciseDetails
                    )
                    .tag(index)
                    .onAppear {
                        print("DEBUG: Page \(index) appeared")
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all)
            .onAppear {
                print("DEBUG: TabView appeared, should show index: \(currentExerciseIndex)")
            }
            
            // Custom navigation bar overlay
            VStack {
                HStack {
                    // Section badge - styled like WorkoutsView difficulty buttons
                    if currentExerciseIndex < exercises.count {
                        HStack(spacing: 4) {
                            Image(systemName: exercises[currentExerciseIndex].section.sectionIcon)
                                .font(.caption2)
                                .foregroundColor(exercises[currentExerciseIndex].section.sectionColor)
                            
                            Text(exercises[currentExerciseIndex].section)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(exercises[currentExerciseIndex].section.sectionColor.opacity(0.3), lineWidth: 1)
                        )
                        .fixedSize()
                    }
                    
                    Spacer()
                    
                    // Workout title
                    Text(workoutName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Done button
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top, 50) // Account for status bar
                .padding(.bottom, 10)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
            }
            
            // Exercise Details Overlay
            if showExerciseDetails && currentExerciseIndex < exercises.count {
                exerciseDetailsOverlay(for: exercises[currentExerciseIndex])
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // If dragged down more than 100 points, dismiss
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
    }
    
    // MARK: - Exercise Details Overlay
    private func exerciseDetailsOverlay(for exercise: WorkoutExercise) -> some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showExerciseDetails = false
                    }
                }
            
            // Details card
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.section)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Text(exercise.move)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showExerciseDetails = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Exercise details content
                ScrollView {
                    exerciseDetailsContent(exercise: exercise)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
            .padding(20)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Exercise Details Content
    private func exerciseDetailsContent(exercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Brief Description
            VStack(alignment: .leading, spacing: 2) {
                Text("Overview")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(exercise.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Detailed Description (if available)
            if let detailedDescription = exercise.detailedDescription, !detailedDescription.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Detailed Guide")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(detailedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Instructions for current difficulty
            VStack(alignment: .leading, spacing: 2) {
                Text("Instructions (\(difficulty.displayName))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundColor(difficulty.color)
                    
                    Text(exercise.instructions(for: difficulty))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            exerciseAdditionalInfo(exercise: exercise)
        }
    }
    
    // MARK: - Additional Exercise Info
    private func exerciseAdditionalInfo(exercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Equipment
            if let equipment = exercise.equipment, !equipment.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Equipment")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)

                    ForEach(equipment, id: \.self) { item in
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text(item.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Target Muscles
            if let muscles = exercise.targetMuscles, !muscles.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target Muscles")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)

                    ForEach(muscles, id: \.self) { muscle in
                        HStack(spacing: 6) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.caption2)
                                .foregroundColor(.red)
                            Text(muscle.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Benefit
            if let benefit = exercise.benefit, !benefit.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Benefit")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(benefit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Duration per rep
            if let duration = exercise.durationPerRep, !duration.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)

                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Exercise Type
            if let types = exercise.exerciseType, !types.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercise Type")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)

                    ForEach(types, id: \.self) { type in
                        HStack(spacing: 6) {
                            Image(systemName: "tag")
                                .font(.caption2)
                                .foregroundColor(.purple)
                            Text(type.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
}

// Simplified version of SingleExercisePlayerView for embedding
struct SingleExercisePageView: View {
    let exercise: WorkoutExercise
    let difficulty: WorkoutDifficulty
    let index: Int
    let total: Int
    @Binding var showExerciseDetails: Bool
    
    var body: some View {
        ZStack {
            // Full screen background video using custom player that properly fills
            GeometryReader { geometry in
                if let videoURL = exercise.getVideoURL() {
                    WorkoutVideoPlayerView(player: AVPlayer(url: videoURL))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            print("🎯 Long press detected directly on video!")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showExerciseDetails.toggle()
                            }
                            print("📋 Exercise details now: \(showExerciseDetails)")
                        }
                } else {
                    Color.black
                        .onLongPressGesture(minimumDuration: 0.5) {
                            print("🎯 Long press detected on black placeholder!")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showExerciseDetails.toggle()
                            }
                            print("📋 Exercise details now: \(showExerciseDetails)")
                        }
                }
            }
            .ignoresSafeArea(.all)
            
            // UI overlay that respects safe areas
            VStack {
                // Top UI with gradient background
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Exercise \(index + 1) of \(total)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    ProgressView(value: Double(index + 1) / Double(total))
                        .tint(.white)
                        .scaleEffect(y: 2)
                    
                    Text(exercise.move)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black, radius: 2)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.top, 80) // Extra padding for safe area and nav bar
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Bottom UI
                VStack(spacing: 20) {
                    Text(exercise.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .shadow(color: .black, radius: 2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(spacing: 4) {
                        Text(exercise.instructions(for: difficulty))
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(difficulty.color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4)
                }
                .padding(.bottom, 50) // Extra padding for safe area
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.2), Color.black.opacity(0.75)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            
        }
    }
    
}

#Preview {
    WorkoutPlayerView(
        workoutName: "Full Body Workout",
        workoutColor: .blue,
        difficulty: .intermediate,
        exercises: [],
        startingIndex: 0
    )
}