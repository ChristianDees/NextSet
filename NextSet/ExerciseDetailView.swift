//
//  ExerciseDetailView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData

// Custom round corners
struct RoundedCorners: Shape {
    var radius: CGFloat = 16.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
}

struct ExerciseDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var exercise: Exercise
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var weight = ""
    @State private var reps = ""

    // Background color based on appearance
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.secondarySystemBackground)
        } else {
            return Color(UIColor.white)
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Exercise title
                    Text(exercise.name ?? "Exercise")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)

                    // Add sets
                    VStack(spacing: 12) {
                        Text("Add Set")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            TextField("Weight (lbs)", text: $weight)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextField("Reps", text: $reps)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        Button {
                            addSet()
                        } label: {
                            Text("Add Set")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canAddSet ? Color.blue : Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!canAddSet)
                    }
                    .padding()
                    .background(Color(backgroundColor))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    // Display sets
                    if exercise.setsArray.isEmpty {
                        Text("No sets added yet.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 12) {
                            // Header row
                            HStack {
                                Text("Weight")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Reps")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Spacer(minLength: 44)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal)
                            .background(Color(backgroundColor))
                            .cornerRadius(16, corners: [.topLeft, .topRight])
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

                            // List of sets
                            ForEach(exercise.setsArray, id: \.self) { set in
                                HStack(spacing: 16) {
                                    Text("\(set.weight, specifier: "%.1f") lbs")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("\(set.reps)")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Spacer()

                                    // Delete Set Button
                                    Button(role: .destructive) {
                                        deleteSet(set)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .frame(width: 36, height: 36)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                            }
                        }
                        .padding()
                        .background(Color(backgroundColor))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }

            // Delete exercise button
            Button(role: .destructive) {
                deleteExerciseImmediately()
            } label: {
                Text("Delete Exercise")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // Validate set inputs
    private var canAddSet: Bool {
        guard let w = Double(weight), w > 0,
              let r = Int(reps), r > 0 else { return false }
        return true
    }

    // Add a new set to the exercise
    private func addSet() {
        guard canAddSet else { return }

        let newSet = Seti(context: viewContext)
        newSet.weight = Double(weight) ?? 0
        newSet.reps = Int16(reps) ?? 0
        newSet.exercise = exercise
        newSet.timestamp = Date()

        do {
            try viewContext.save()
            weight = ""
            reps = ""
        } catch {
            print("Error saving set: \(error.localizedDescription)")
        }
    }

    // Delete an individual set
    private func deleteSet(_ set: Seti) {
        viewContext.delete(set)
        try? viewContext.save()
    }

    // Immediately delete the exercise and its sets
    private func deleteExerciseImmediately() {
        if let workout = exercise.workout {
            workout.removeFromExercises(exercise) // Remove relationship
        }

        if exercise.date != nil {
            exercise.date = nil // Unlink from a calendar date
        }

        // Only delete if no references remain
        if exercise.workout == nil && exercise.date == nil {
            viewContext.delete(exercise)
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete or update exercise: \(error.localizedDescription)")
        }
    }
}

// Sorted array of sets for display based on date added
extension Exercise {
    var setsArray: [Seti] {
        let set = sets as? Set<Seti> ?? []
        return set.sorted {
            ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast)
        }
    }
}

