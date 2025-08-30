//
//  MainTabView.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//
import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: Int = 0            // Tracks current tab
    @State private var showAddMenu = false             // Controls visibility of the add menu
    @State private var selectedDate = Date()           // Shared date across views

    // Background adapts to light/dark mode
    var backgroundColor: Color {
        colorScheme == .dark
        ? Color(UIColor.secondarySystemBackground)
        : Color(UIColor.white)
    }

    var body: some View {
        ZStack {
            // Full screen background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        // Home tab
                        HomeView(selectedDate: $selectedDate)
                            .background(Color.clear)
                    case 2:
                        // Workouts tab
                        WorkoutListView()
                            .background(Color.clear)
                    default:
                        HomeView(selectedDate: $selectedDate)
                            .background(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: 0) {
                    // Home Tab Button
                    tabBarButton(systemImage: "calendar", tag: 0, iconSize: 35)  // Smaller side icon size

                    Spacer()

                    // Center Plus Button (Increased size)
                    Button(action: {
                        showAddMenu.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 56, height: 56)  // Increased circle size

                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))  // Increased plus icon size
                                .foregroundColor(.white)
                        }
                    }
                    .confirmationDialog("Add New", isPresented: $showAddMenu, titleVisibility: .visible) {
                        if selectedTab == 0 {
                            Button("Add Exercise to Day") {
                                NotificationCenter.default.post(name: .addExercise, object: nil)
                            }
                            Button("Add Workout to Day") {
                                NotificationCenter.default.post(name: .addWorkout, object: nil)
                            }
                        } else if selectedTab == 2 {
                            Button("Create New Workout") {
                                NotificationCenter.default.post(name: .createWorkout, object: nil)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Workouts Tab Button
                    tabBarButton(systemImage: "list.bullet.rectangle", tag: 2, iconSize: 35)  // Smaller side icon size
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(backgroundColor).opacity(0.95))
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
    }

    @ViewBuilder
    private func tabBarButton(systemImage: String, tag: Int, iconSize: CGFloat) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = tag
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: iconSize, weight: .medium))  // Adjusted icon size
                    .foregroundColor(selectedTab == tag ? .blue : .gray)
            }
            .frame(minWidth: 60)
            .contentShape(Rectangle()) // Expands tap area
        }
        .buttonStyle(.plain)
    }
}

