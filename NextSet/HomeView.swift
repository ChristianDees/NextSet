//
//  HomeView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date

    // UI State
    @State private var showCalendar = false
    @State private var showAddExercise = false
    @State private var showAddWorkout = false
    @State private var selectedExercise: Exercise? = nil
    @State private var tappedExerciseID: NSManagedObjectID? = nil

    // Fetch all exercises filtered by date
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    )
    private var allExercises: FetchedResults<Exercise>

    // Background colors for appearance
    var backgroundColor: Color {
        colorScheme == .dark
        ? Color(UIColor.secondarySystemBackground)
        : Color(UIColor.white)
    }
    
    // Color for divider for appearance
    var dividerColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Date header
                    VStack(spacing: 10) {
                        Spacer().frame(height: 12)

                        // Navigation Arrows + Date Display
                        HStack(spacing: 20) {
                            Button { changeDate(by: -1) } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                            }

                            Spacer()

                            // Tappable date to toggle calendar
                            Button {
                                withAnimation(.easeInOut) {
                                    showCalendar.toggle()
                                }
                            } label: {
                                Text(formattedDate(selectedDate))
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color(backgroundColor))
                                    .clipShape(Capsule())
                                    .shadow(color: Color.primary.opacity(0.1), radius: 3)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .fixedSize()

                            Spacer()

                            Button { changeDate(by: 1) } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)

                        // --- Calendar Picker ---
                        if showCalendar {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(backgroundColor))
                                    .shadow(color: Color.primary.opacity(0.1), radius: 3)
                            )
                            .padding(.horizontal)
                            .onChange(of: selectedDate) {
                                withAnimation(.easeInOut) {
                                    showCalendar = false
                                }
                            }
                        }

                        Divider()
                            .background(Color(dividerColor))
                            .padding(.top, 12)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40) // Push content downward slightly

                    // Exercises
                    let exercisesToday = filteredExercises(for: selectedDate)

                    if exercisesToday.isEmpty {
                        // Empty list
                        VStack(spacing: 12) {
                            Spacer()

                            Image(systemName: "calendar.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color.secondary.opacity(0.4))

                            Text("No workouts or exercises for this day.\n Add one below")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()

                            Spacer()
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(exercisesToday) { exercise in
                                    Button {
                                        tappedExerciseID = exercise.objectID
                                        selectedExercise = exercise
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(exercise.name ?? "Unnamed Exercise")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                if let workoutName = exercise.workout?.name {
                                                    Text(workoutName)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }

                                            Spacer()

                                            // Expand to see exercise details
                                            Image(systemName: "chevron.down")
                                                .rotationEffect(
                                                    .degrees(selectedExercise?.objectID == exercise.objectID ? 180 : 0)
                                                )
                                                .animation(.easeInOut, value: selectedExercise?.objectID == exercise.objectID)
                                                .foregroundColor(Color.primary.opacity(0.5))
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(backgroundColor))
                                        )
                                        .shadow(color: Color.primary.opacity(0.05), radius: 2, x: 0, y: 1)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }

                        // Message to add more
                        if exercisesToday.count <= 3 {
                            VStack(spacing: 12) {
                                Text("Add an exercise or workout below")
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()

                                Spacer()
                            }
                            .padding()
                        }
                    }

                    Spacer(minLength: 60)
                }
            }
            .navigationBarHidden(true)

            // Listen for add exercise/workout actions
            .onReceive(NotificationCenter.default.publisher(for: .addExercise)) { _ in
                showAddExercise = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .addWorkout)) { _ in
                showAddWorkout = true
            }

            // Show exercise details
            .sheet(isPresented: Binding(
                get: { selectedExercise != nil },
                set: { if !$0 { selectedExercise = nil } }
            )) {
                if let exercise = selectedExercise {
                    ExerciseDetailView(exercise: exercise)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }

            // Show add exercise modal
            .sheet(isPresented: $showAddExercise) {
                AddExerciseView(selectedDate: selectedDate)
            }

            // Show add workout modal
            .sheet(isPresented: $showAddWorkout) {
                AddWorkoutView(selectedDate: selectedDate)
            }
        }
    }

    // Formats a Date into a readable string (e.g., August 29, 2025)
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    // Changes selected date by a given number of days
    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }

    // Filters all exercises to only include those tied to the selected day
    func filteredExercises(for date: Date) -> [Exercise] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return allExercises.filter {
            // Direct date or workout's date matches selected date
            ($0.date != nil && $0.date! >= startOfDay && $0.date! < endOfDay) ||
            ($0.workout?.date != nil && $0.workout!.date! >= startOfDay && $0.workout!.date! < endOfDay)
        }
    }
}

extension Exercise: Identifiable {}
