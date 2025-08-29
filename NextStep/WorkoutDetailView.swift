//
//  WorkoutDetailView.swift
//  NextStep
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workout: Workout            // The workout being edited
    @State private var workoutName: String = ""     // Local state for workout name input
    @State private var showAddExercise = false      // Controls sheet presentation to add exercise

    // Background color adapts to dark/light mode
    var backgroundColor: Color {
        colorScheme == .dark
        ? Color(UIColor.secondarySystemBackground)
        : Color(UIColor.white)
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                // Back button to dismiss the view
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }

                Spacer()

                // Title centered
                Text("Workout")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                // Done button to close
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)


            ScrollView {
                VStack(spacing: 24) {
                    // Workout Name
                    VStack(spacing: 12) {
                        TextField("Workout Name", text: $workoutName)
                            .font(.title3)
                            // Save changes immediately when user edits name
                            .onChange(of: workoutName) { workoutName, _ in
                                workout.name = workoutName
                                saveContext()
                            }
                    }
                    .padding()
                    .background(Color(backgroundColor))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // Exercise list

                    VStack(spacing: 12) {
                        if workout.exercisesArray.isEmpty {
                            // Placeholder when no exercises exist
                            Text("No exercises yet.")
                                .foregroundColor(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        } else {
                            // List all exercises and delete button
                            ForEach(workout.exercisesArray) { exercise in
                                HStack {
                                    Text(exercise.name ?? "Unnamed")
                                        .foregroundColor(.primary)
                                    Spacer()

                                    // Delete exercise button with destructive role
                                    Button(role: .destructive) {
                                        deleteExercise(exercise)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(backgroundColor))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Add exercise button

                    Button {
                        showAddExercise = true
                    } label: {
                        Text("Add Exercise")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer() // Push content up
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarHidden(true) // Hide default nav bar since using custom one
        .onAppear {
            workoutName = workout.name ?? ""
        }
        .sheet(isPresented: $showAddExercise) {
            // Pass workout's date and workout to AddExerciseView
            AddExerciseView(selectedDate: workout.date ?? nil, preAssignedWorkout: workout)
        }
    }

    // Save the workout
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    // Deletes an exercise and manages relationships
    private func deleteExercise(_ exercise: Exercise) {
        
        // Remove exercise from workout's relationship
        if let workout = exercise.workout {
            workout.removeFromExercises(exercise)
        }

        // If exercise has no date, delete it completely
        if exercise.date == nil {
            viewContext.delete(exercise)
        }

        // Save changes 
        do {
            try viewContext.save()
        } catch {
            print("Failed to update context: \(error.localizedDescription)")
        }
    }
}
