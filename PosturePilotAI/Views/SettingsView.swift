import SwiftData
import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var appServices: AppServices
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("appearance") private var appearance = "dark"
    @AppStorage("watchRemindersEnabled") private var watchRemindersEnabled = true
    @AppStorage("watchStandAlertsEnabled") private var watchStandAlertsEnabled = true
    @AppStorage("widgetsEnabled") private var widgetsEnabled = true
    @AppStorage("widgetSittingTimerEnabled") private var widgetSittingTimerEnabled = true
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section("Reminders") {
                Picker("Sensitivity", selection: $viewModel.reminderSensitivity) {
                    ForEach(ReminderSensitivity.allCases) { sensitivity in
                        Text(sensitivity.title).tag(sensitivity)
                    }
                }

                Toggle("Notifications enabled", isOn: $viewModel.notificationsEnabled)

                Button("Schedule next posture reminder") {
                    Task {
                        await appServices.notificationService.scheduleBreakReminder(
                            afterMinutes: viewModel.reminderSensitivity.intervalMinutes
                        )
                    }
                }
            }

            Section("Permissions") {
                Button("Request camera permission") {
                    Task { _ = await appServices.cameraService.requestPermission() }
                }
                Button("Request motion access") {
                    Task { _ = await appServices.motionService.requestPlaceholderAccess() }
                }
                Button("Open iOS Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }

            Section("Appearance") {
                Picker("Mode", selection: $appearance) {
                    Text("Dark").tag("dark")
                    Text("Light").tag("light")
                    Text("System").tag("system")
                }
                .pickerStyle(.segmented)
            }

            Section("Apple Watch Placeholder") {
                Toggle("Posture reminders", isOn: $watchRemindersEnabled)
                Toggle("Stand alerts and vibration prompts", isOn: $watchStandAlertsEnabled)
                Text("Watch app architecture placeholders live in the WatchPlaceholder folder.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Widgets Placeholder") {
                Toggle("Posture score widget", isOn: $widgetsEnabled)
                Toggle("Sitting timer and next break widgets", isOn: $widgetSittingTimerEnabled)
                Text("WidgetKit timelines are scaffolded as placeholders for a future widget extension target.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Legal and wellness") {
                NavigationLink("Privacy Policy") {
                    LegalTextView(title: "Privacy Policy", bodyText: privacyPolicyText)
                }
                NavigationLink("Terms of Use") {
                    LegalTextView(title: "Terms of Use", bodyText: termsText)
                }
                NavigationLink("Wellness Disclaimer") {
                    WellnessDisclaimerView()
                        .padding()
                        .navigationTitle("Disclaimer")
                        .appBackground()
                }
            }

            Section("Subscription") {
                NavigationLink(value: AppRoute.paywall) {
                    Label("Manage plan", systemImage: "crown")
                }
            }

            Section("Share and support") {
                ShareLink(
                    item: GrowthService.shareText(for: .general),
                    subject: Text("PosturePilot AI"),
                    preview: SharePreview("PosturePilot AI", image: Image("ShareCardVisual"))
                ) {
                    Label("Share PosturePilot AI", systemImage: "square.and.arrow.up")
                }

                Button {
                    requestReview()
                } label: {
                    Label("Rate PosturePilot AI", systemImage: "star")
                }
            }

            Section("Data") {
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete all data", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationDestination(for: AppRoute.self) { route in
            route.destination
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .alert("Delete all local data?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteAllData(in: modelContext)
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes local SwiftData records and restarts onboarding.")
        }
    }

    private var privacyPolicyText: String {
        "PosturePilot AI stores posture sessions, focus sessions, routines, achievements, desk scans, and subscription state locally with SwiftData. Remote AI is a placeholder and should be routed through your backend without storing API keys in the app."
    }

    private var termsText: String {
        "PosturePilot AI provides wellness and productivity information only. It does not diagnose, treat, cure, or prevent medical conditions. Seek professional care for pain, injuries, or medical concerns."
    }
}

private struct LegalTextView: View {
    var title: String
    var bodyText: String

    var body: some View {
        ScrollView {
            Text(bodyText)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
        .appBackground()
    }
}
