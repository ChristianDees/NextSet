//
//  AddWorkoutView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData

struct AddWorkoutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    var selectedDate: Date? = nil

    // Fetch workout templates (workouts without dates)
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "date == nil")
    ) private var templates: FetchedResults<Workout>

    // Background color based on light/dark mode
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.secondarySystemBackground)
        } else {
            return Color(UIColor.white)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Screen title
                Text("Select Workout")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Show placeholder if there are no workout templates
                if templates.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.plaintext")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.4))

                        Text("No saved workout templates.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    // Show list of workout templates to choose from
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(templates, id: \.self) { template in
                                Button {
                                    addWorkout(withTemplate: template)
                                } label: {
                                    HStack {
                                        Text(template.name ?? "")
                                            .foregroundColor(.primary)
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .padding()
                                    .background(Color(backgroundColor))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button in nav bar
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // Creates a new workout from the selected template
    private func addWorkout(withTemplate template: Workout) {
        guard let selectedDate else { return }

        // New workout instance
        let newWorkout = Workout(context: viewContext)
        newWorkout.name = template.name
        newWorkout.date = selectedDate

        // Copies each Exercise from the template into the new Workout
        if let templateExercises = template.exercises as? Set<Exercise> {
            for templateExercise in templateExercises {
                let newExercise = Exercise(context: viewContext)
                newExercise.name = templateExercise.name
                newExercise.date = selectedDate
                newExercise.workout = newWorkout
            }
        }

        // Save new workout and leave
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to add workout with template: \(error.localizedDescription)")
        }
    }
}
