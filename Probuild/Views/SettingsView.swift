import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultRegion") private var defaultRegion = "Alberta"
    @AppStorage("defaultLabourRate") private var defaultLabourRate = 85.0
    @AppStorage("defaultMarkupPercent") private var defaultMarkupPercent = 20.0

    @State private var showResetAlert = false

    let regions = ["Alberta", "BC", "Ontario", "USA"]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        Form {
            Section(header: Text("Defaults")) {
                Picker("Default Region", selection: $defaultRegion) {
                    ForEach(regions, id: \.self) { r in
                        Text(r).tag(r)
                    }
                }
                HStack {
                    Text("Default Labour Rate ($/hr)")
                    Spacer()
                    TextField("85", value: $defaultLabourRate, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Default Markup %")
                    Spacer()
                    TextField("20", value: $defaultMarkupPercent, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Section(header: Text("About")) {
                HStack {
                    Text("App")
                    Spacer()
                    Text("ProBuild")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Platform")
                    Spacer()
                    Text("iOS 16+  Swift 5.9")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Disclaimer")) {
                Text("All calculations are estimates for planning purposes only. Verify all results with a licensed engineer or certified trades professional before construction. Results do not constitute engineering advice.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Reset All Settings")
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                defaultRegion = "Alberta"
                defaultLabourRate = 85.0
                defaultMarkupPercent = 20.0
            }
        } message: {
            Text("This will reset all settings to defaults. Change orders and saved data will not be affected.")
        }
    }
}
