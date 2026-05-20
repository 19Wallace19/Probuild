import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Advanced Calculators")) {
                    NavigationLink {
                        HipValleyView()
                    } label: {
                        MoreRowLabel(
                            icon: "arrow.up.left.and.arrow.down.right",
                            title: "Hip & Valley Rafter",
                            subtitle: "Hip length, cheek cuts, jack rafter diff"
                        )
                    }

                    NavigationLink {
                        PermitView()
                    } label: {
                        MoreRowLabel(
                            icon: "doc.badge.checkmark",
                            title: "Permit Fee Estimator",
                            subtitle: "Calgary, Edmonton, Vancouver, Toronto, Seattle"
                        )
                    }

                    NavigationLink {
                        ChangeOrderView()
                    } label: {
                        MoreRowLabel(
                            icon: "list.clipboard",
                            title: "Change Order Tracker",
                            subtitle: "Track approved, pending, rejected COs"
                        )
                    }
                }

                Section(header: Text("App")) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        MoreRowLabel(
                            icon: "gearshape",
                            title: "Settings",
                            subtitle: "Region, labour rate, markup defaults"
                        )
                    }
                }

                Section(header: Text("Info")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ProBuild")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("North American Construction Calculator.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("All results are estimates for planning purposes. Always consult a licensed engineer for structural and permit applications.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MoreRowLabel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1A1A1A"))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
