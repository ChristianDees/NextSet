//
//  AddExerciseView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData


struct AddExerciseView: View {
    
    @Environment(\.colorScheme) private var colorScheme             // Accesses the current color mode (dark/light)
    @Environment(\.managedObjectContext) private var viewContext    // Accesses the Core Data managed object context
    @Environment(\.dismiss) var dismiss                             // Dismissing current view

    // Optional prefilled data
    var selectedDate: Date? = nil           // Exercise date
    var preAssignedWorkout: Workout? = nil  // Workout assigned to exercise
    
    @State private var isDeleting = false   // Exercise delete in progress
    @State private var name = ""            // Name of exercise

    // Get saved exercise sorted by name
    @FetchRequest(
        entity: ExerciseTemplate.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]
    ) private var templates: FetchedResults<ExerciseTemplate>

    // Dynamic background color for boxes
    var backgroundColor: Color {Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.white)}

    // Dynamic background color
    var fullBackgroundColor: Color {Color(colorScheme == .dark ? UIColor.black : UIColor.secondarySystemBackground)}

    
    var body: some View {
        NavigationView {
            ZStack {
                Color(fullBackgroundColor).ignoresSafeArea() // Background color for whole page

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            TextField("Exercise Name", text: $name) // Title of exercise name
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Button {                                // Save exercise button
                                addExercise(withName: name)
                            } label: {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        name.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color.gray.opacity(0.4)
                                        : Color.blue
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(Color(backgroundColor))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                        // Display list of saved exercises to chose from
                        if !templates.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(templates, id: \.self) { template in
                                    ZStack {
                                        // Add exercise button
                                        Button(action: {
                                            addExercise(withName: template.name ?? "")
                                        }) {
                                            Text(template.name ?? "")
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                                .background(Color(backgroundColor))
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                        }
                                        .buttonStyle(.plain)

                                        HStack {
                                            Spacer()
                                            // Delete exercise button
                                            Button(role: .destructive) {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        isDeleting.toggle()
                                                    }
                                                    deleteTemplate(template)
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
                                                .padding(.trailing, 8)
                                                .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button to dismiss the view
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.blue)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // Adds a new exercise with the given name, or creates a new one if needed
    private func addExercise(withName name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newExercise = Exercise(context: viewContext)
        newExercise.name = trimmedName
        newExercise.date = selectedDate
        newExercise.workout = preAssignedWorkout

        // Save as a new template if it doesn't exist
        if !templates.contains(where: { $0.name?.lowercased() == trimmedName.lowercased() }) {
            let template = ExerciseTemplate(context: viewContext)
            template.name = trimmedName
        }

        try? viewContext.save()
        dismiss()
    }

    // Deletes the selected exercise template
    private func deleteTemplate(_ template: ExerciseTemplate) {
        viewContext.delete(template)

        // Save the changes
        do {
            isDeleting = false
            try viewContext.save()
        } catch {
            print("Failed to delete template: \(error)")
        }
    }
}
