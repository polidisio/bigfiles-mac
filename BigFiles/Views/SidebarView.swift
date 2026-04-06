import SwiftUI

struct SidebarView: View {
    @Binding var profile: ScanProfile
    @Binding var showingHistory: Bool

    private let sidebarBlue = Color(red: 0.863, green: 0.910, blue: 0.957)

    var body: some View {
        List {
            Section {
                searchField
            }
            .listRowBackground(Color.clear)

            Section {
                directorySection
                sizeSection
                sortSection
                optionsSection
            }
            .listRowBackground(sidebarBlue)

            Section {
                historyButton
            }
            .listRowBackground(sidebarBlue)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(sidebarBlue)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.caption)
            TextField("Search...", text: $profile.searchText)
                .textFieldStyle(.plain)
                .font(.caption)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.6))
        .cornerRadius(6)
    }

    private var directorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DIRECTORY")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .tracking(0.5)

            DirectoryPickerButton(directory: $profile.directory)
        }
        .padding(.vertical, 4)
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SIZE")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(spacing: 8) {
                HStack {
                    Text("Min:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(profile.minSizeMB)) MB")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .labelsHidden()

                Divider()

                HStack {
                    Text("Max:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    if let maxMB = profile.maxSizeMB {
                        Text("\(Int(maxMB)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else {
                        Text("No limit")
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
                    Button("Set max") {
                        profile.maxSizeMB = 500
                    }
                    .font(.caption2)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SORT")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(spacing: 8) {
                HStack {
                    Text("Primary:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $profile.sortBy) {
                        ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                            Text(field.rawValue).tag(field)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 100)
                }

                HStack {
                    Text("Secondary:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
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
                    .frame(width: 100)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OPTIONS")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(spacing: 8) {
                HStack {
                    Text("Limit:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(profile.limit == 0 ? "No limit" : "\(profile.limit)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .labelsHidden()

                Toggle("Exclude system dirs", isOn: $profile.excludeSystemDirs)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
    }

    private var historyButton: some View {
        Button(action: { showingHistory = true }) {
            HStack {
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                Text("History")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DirectoryPickerButton: View {
    @Binding var directory: String

    var body: some View {
        Button(action: pickDirectory) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.accentColor)
                Text(truncatedPath)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color.white.opacity(0.5))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var truncatedPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if directory.hasPrefix(home) {
            let relative = String(directory.dropFirst(home.count))
            return "~" + relative
        }
        if directory.count > 40 {
            return "..." + String(directory.suffix(37))
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
