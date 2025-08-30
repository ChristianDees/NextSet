//
//  WorkoutListView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData


struct WorkoutListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch workouts without a date, sorted by name ascending
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "date == nil")
    ) private var workouts: FetchedResults<Workout>

    // Selected workout for editing
    @State private var selectedWorkout: Workout? = nil
    // Temporary workout for adding a new workout
    @State private var newWorkout: Workout? = nil
    @State private var showAddWorkout = false

    // Background color for appearance
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.secondarySystemBackground) // Dark mode background color
        } else {
            return Color(UIColor.white) // Light mode background color
        }
    }
    // Color for divider for appearance
    var dividerColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background color fills entire screen
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        Spacer().frame(height: 12)

                        HStack {
                            Spacer()
                            Text("Workouts")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }

                        Divider()
                            .background(Color(dividerColor))
                            .padding(.top, 12)
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 40)
                    // Workout list
                    if workouts.isEmpty {
                        // No workouts message
                        Spacer()
                        
                        Text("No workouts made yet!\nCreate one below")
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        // Use a ScrollView with LazyVStack to match exercise layout
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(workouts) { workout in
                                    Button {
                                        // Select workout to show details
                                        selectedWorkout = workout
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(workout.name ?? "Unnamed Workout")
                                                    .font(.headline)
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)

                                                if let date = workout.date {
                                                    Text(formattedDate(date))
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }

                                            Spacer()

                                            // Rotate arrow when selected
                                            Image(systemName: "chevron.down")
                                                .rotationEffect(.degrees(selectedWorkout?.objectID == workout.objectID ? 180 : 0))
                                                .animation(.easeInOut, value: selectedWorkout?.objectID == workout.objectID)
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                        .padding()  // Adjust padding for a tighter feel
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(backgroundColor))
                                        )
                                        .shadow(color: Color.primary.opacity(0.05), radius: 2, x: 0, y: 1)
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)
                        }

                        // If fewer than 3 workouts, show msg
                        if workouts.count < 3 {
                            VStack {
                                Text("Create a workout below")
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                Spacer()
                            }
                        }
                    }

                    Spacer(minLength: 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true) // Custom header, hide default nav bar
            .onReceive(NotificationCenter.default.publisher(for: .createWorkout)) { _ in
                createNewWorkout()
            }
        }
        // Workout Detail Sheet for Editing Selected Workout
        .sheet(isPresented: Binding(
            get: { selectedWorkout != nil },
            set: { if !$0 { selectedWorkout = nil } }
        )) {
            if let workout = selectedWorkout {
                NavigationView {
                    WorkoutDetailView(workout: workout)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .environment(\.managedObjectContext, viewContext)
            }
        }
        // Sheet for Adding a New Workout
        .sheet(isPresented: $showAddWorkout, onDismiss: {
            // Clean up temporary newWorkout after dismiss
            newWorkout = nil
        }) {
            if let workout = newWorkout {
                WorkoutDetailView(workout: workout)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Error: No workout to add")
            }
        }
    }

    // Creates a new workout and presents the add workout sheet
    private func createNewWorkout() {
        newWorkout = Workout(context: viewContext)
        newWorkout?.date = nil
        showAddWorkout = true
    }

    // Deletes workouts
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.map { workouts[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting workout: \(error.localizedDescription)")
        }
    }

    // Formats a Date to a string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
