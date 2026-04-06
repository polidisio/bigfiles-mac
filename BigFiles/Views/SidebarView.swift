import SwiftUI

struct SidebarView: View {
    @Binding var profile: ScanProfile
    @Binding var showingHistory: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                searchSection
                directorySection
                sizeSection
                sortSection
                optionsSection
                Spacer(minLength: 20)
                historyButton
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .frame(minWidth: 220)
        .background(Color(red: 0.812, green: 0.812, blue: 0.812))
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Search")

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                TextField("Filter files...", text: $profile.searchText)
                    .textFieldStyle(.plain)
                    .font(.caption)
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var directorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Directory")

            DirectoryPickerButton(directory: $profile.directory)
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Size Filter")

            VStack(spacing: 6) {
                HStack {
                    Text("Min:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(profile.minSizeMB)) MB")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                }
                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .labelsHidden()
            }

            VStack(spacing: 6) {
                HStack {
                    Text("Max:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let maxMB = profile.maxSizeMB {
                        Text("\(Int(maxMB)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else {
                        Text("None")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if profile.maxSizeMB != nil {
                        Button(action: { profile.maxSizeMB = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                if profile.maxSizeMB != nil {
                    Slider(value: Binding(
                        get: { profile.maxSizeMB ?? 500 },
                        set: { profile.maxSizeMB = $0 }
                    ), in: 1...10000, step: 10)
                    .labelsHidden()
                } else {
                    Button("Set Max") {
                        profile.maxSizeMB = 500
                    }
                    .font(.caption2)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Sort By")

            HStack {
                Text("Primary:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                Picker("", selection: $profile.sortBy) {
                    ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                        Text(field.rawValue).tag(field)
                    }
                }
                .labelsHidden()
            }

            HStack {
                Text("Secondary:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                Picker("", selection: Binding(
                    get: { profile.secondarySortBy ?? .name },
                    set: { profile.secondarySortBy = $0 }
                )) {
                    Text("None").tag(ScanProfile.SortField.name)
                    ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                        Text(field.rawValue).tag(field)
                    }
                }
                .labelsHidden()
            }
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Options")

            VStack(spacing: 6) {
                HStack {
                    Text("Limit:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(profile.limit == 0 ? "None" : "\(profile.limit)")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                }
                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .labelsHidden()
            }

            Toggle("Exclude System Dirs", isOn: $profile.excludeSystemDirs)
                .font(.caption)
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var historyButton: some View {
        Button(action: { showingHistory = true }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text("Scan History")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
}

struct DirectoryPickerButton: View {
    @Binding var directory: String

    var body: some View {
        Button(action: pickDirectory) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.accentColor)
                    .font(.caption)
                Text(truncatedPath)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var truncatedPath: String {
        if directory.count > 35 {
            return "..." + String(directory.suffix(32))
        }
        return directory
    }

    private func pickDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: directory)

        if panel.runModal() == .OK {
            if let url = panel.url {
                directory = url.path
            }
        }
    }
}
