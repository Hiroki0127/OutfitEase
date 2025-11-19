import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var autoSaveEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("New Post Alerts", isOn: $notificationsEnabled)
                    Toggle("Outfit Reminders", isOn: $notificationsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    Toggle("Auto-save Drafts", isOn: $autoSaveEnabled)
                }
                
                Section("Account") {
                    NavigationLink("Edit Profile") {
                        Text("Edit Profile View")
                    }
                    
                    NavigationLink("Privacy Settings") {
                        Text("Privacy Settings View")
                    }
                    
                    NavigationLink("Connected Accounts") {
                        Text("Connected Accounts View")
                    }
                }
                
                Section("Data & Storage") {
                    NavigationLink("Download My Data") {
                        Text("Download Data View")
                    }
                    
                    NavigationLink("Clear Cache") {
                        Text("Clear Cache View")
                    }
                    
                    Button("Delete Account") {
                        // TODO: Implement account deletion
                    }
                    .foregroundColor(.red)
                }
                
                Section("Support") {
                    NavigationLink("Help Center") {
                        Text("Help Center View")
                    }
                    
                    NavigationLink("Contact Support") {
                        Text("Contact Support View")
                    }
                    
                    NavigationLink("About OutfitEase") {
                        Text("About View")
                    }
                }
                
                Section("Legal") {
                    NavigationLink("Terms of Service") {
                        Text("Terms of Service View")
                    }
                    
                    NavigationLink("Privacy Policy") {
                        Text("Privacy Policy View")
                    }
                }
            }
            .navigationTitleFont("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
