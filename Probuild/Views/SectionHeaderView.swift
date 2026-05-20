import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))
                .padding(.vertical, 8)
            Divider()
        }
        .padding(.horizontal, 0)
    }
}

struct CalcButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "1A1A1A"))
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct InputRow: View {
    let label: String
    let binding: Binding<String>
    var keyboardType: UIKeyboardType = .decimalPad
    var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                TextField("0", text: binding)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
                    .textFieldStyle(.roundedBorder)
            }
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
