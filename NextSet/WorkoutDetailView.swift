//
//  WorkoutDetailView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI


struct WorkoutDetailView: View {
    
    @Environment(\.colorScheme) private var colorScheme             // Accesses the current color mode (dark/light)
    @Environment(\.managedObjectContext) private var viewContext    // Accesses the Core Data managed object context
    @Environment(\.presentationMode) private var presentationMode   // Accesses presentation mode for dismissal
    @Environment(\.dismiss) private var dismiss     // Dismissing current view

    @ObservedObject var workout: Workout            // The workout being edited
    
    @State private var workoutName: String = ""     // Local state for workout name input
    @State private var showAddExercise = false      // Controls sheet presentation to add exercise
    @State private var isDeleting = false           // Deletion of workout in progress
    @State private var showingDeleteConfirmation = false  // For triggering delete confirmation alert

    // Background color based on light/dark mode
    var backgroundColor: Color {colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.white)}

    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Trashcan button to delete workout
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .frame(width: 16, height: 16)
                        .foregroundColor(.red)
                }
                .padding(.leading)
                .buttonStyle(.plain)

                Spacer()

                // Title for sheet
                Text("Workout")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                // Done button to close
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .padding(.trailing)
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()

                            // // Workout Name (editable)
                            TextField("Workout Name", text: $workoutName)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                // Save changes immediately
                                .onChange(of: workoutName) { _, newName in
                                    workout.name = newName
                                    saveContext()
                                }

                            Spacer()
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

                                    // Delete exercise button
                                    Button(role: .destructive) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isDeleting.toggle()
                                            }
                                            deleteExercise(exercise)
                                        } label: {
                                            if isDeleting {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .scaleEffect(1.2)
                                                    .opacity(0.5)
                                            } else {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(backgroundColor))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal)
                                    .buttonStyle(.plain)
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
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .onAppear {
            workoutName = workout.name ?? ""
        }
        .sheet(isPresented: $showAddExercise) {
            // Pass workout's date and workout to AddExerciseView
            AddExerciseView(selectedDate: workout.date ?? nil, preAssignedWorkout: workout)
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Workout"),
                message: Text("Are you sure you want to delete this workout?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    deleteWorkout()
                }
            )
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

    // Deletes the workout
    private func deleteWorkout() {
        viewContext.delete(workout)
        saveContext()
        dismiss()
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
            isDeleting = false
            try viewContext.save()
        } catch {
            print("Failed to update context: \(error.localizedDescription)")
        }
    }
}
