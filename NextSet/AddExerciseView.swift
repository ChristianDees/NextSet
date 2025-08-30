//
//  AddExerciseView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData

struct AddExerciseView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // Optional prefilled data
    var selectedDate: Date? = nil
    var preAssignedWorkout: Workout? = nil
    @State private var isDeleting = false
    @State private var name = ""

    // Fetch saved exercise templates sorted by name
    @FetchRequest(
        entity: ExerciseTemplate.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]
    ) private var templates: FetchedResults<ExerciseTemplate>

    // Dynamic background based on current color scheme
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.secondarySystemBackground)
        } else {
            return Color(UIColor.white)
        }
    }
    
    // Dynamic background based on current color scheme
    var fullBackgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.black)
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }
    

    var body: some View {
        NavigationView {
            ZStack {
                // Apply the background color to the entire screen
                Color(fullBackgroundColor).ignoresSafeArea()

                ScrollView {  // Wrap the entire content inside a ScrollView
                    VStack(spacing: 24) {
                        // Manual name input + Save button
                        VStack(spacing: 12) {
                            TextField("Exercise Name", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Button {
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

                        // Display list of template exercises to quickly select from
                        if !templates.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(templates, id: \.self) { template in
                                    ZStack {
                                        // Capsule button for exercise name
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

                                        // Trash can inside the capsule
                                        HStack {
                                            Spacer()
                                            // Delete exercise button with destructive role
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
                                                .padding(.trailing, 8) // Padding to ensure the trash can is not too close
                                                .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        Spacer() // Keeps content aligned to top
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

    // Adds a new exercise with the given name.
    // Also adds a new template if it's a new name.
    private func addExercise(withName name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newExercise = Exercise(context: viewContext)
        newExercise.name = trimmedName
        newExercise.date = selectedDate
        newExercise.workout = preAssignedWorkout

        // Save as a new template if it doesn't already exist
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
