import SwiftUI

struct SidebarView: View {
    @Binding var profile: ScanProfile
    @Binding var showingHistory: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Search")

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Filter by name or path...", text: $profile.searchText)
                        .textFieldStyle(.plain)
                        .font(.body)
                }
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 12)

            sectionHeader("Directory")

            DirectoryPickerButton(directory: $profile.directory)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 12)

            sectionHeader("Size Filter")

            VStack(alignment: .leading, spacing: 8) {
                Text("Min: \(Int(profile.minSizeMB)) MB")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .labelsHidden()

                if let maxMB = profile.maxSizeMB {
                    HStack {
                        Text("Max: \(Int(maxMB)) MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: Binding(
                            get: { maxMB },
                            set: { profile.maxSizeMB = $0 }
                        ), in: 1...10000, step: 1)
                        .labelsHidden()
                        Button(action: { profile.maxSizeMB = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button("Set Max Size") {
                        profile.maxSizeMB = 500
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 12)

            sectionHeader("Sort By")

            VStack(alignment: .leading, spacing: 8) {
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
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 12)

            sectionHeader("Options")

            VStack(alignment: .leading, spacing: 8) {
                Text("Limit: \(profile.limit == 0 ? "None" : "\(profile.limit)")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .labelsHidden()

                Toggle("Exclude System Dirs", isOn: $profile.excludeSystemDirs)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            Spacer()

            Divider()
                .padding(.horizontal, 12)

            Button(action: { showingHistory = true }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Scan History")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .frame(minWidth: 220)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 6)
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
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var truncatedPath: String {
        if directory.count > 30 {
            return "..." + String(directory.suffix(27))
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
