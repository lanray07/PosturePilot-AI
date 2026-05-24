import Foundation
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var reminderSensitivity: ReminderSensitivity = .balanced
    @Published var notificationsEnabled = true
    @Published var showDeleteConfirmation = false
    @Published var errorMessage: String?

    func deleteAllData(in context: ModelContext) {
        do {
            try context.fetch(FetchDescriptor<UserProfile>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<PostureSession>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<FocusSession>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<StretchRoutine>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<DeskSetupScan>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<Achievement>()).forEach { context.delete($0) }
            try context.fetch(FetchDescriptor<SubscriptionState>()).forEach { context.delete($0) }
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
