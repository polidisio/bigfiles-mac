import SwiftUI

struct FileListView: View {
    @ObservedObject var viewModel: ScanViewModel
    var onRevealInFinder: (ScannedFile) -> Void
    var onDelete: (ScannedFile) -> Void

    var body: some View {
        Group {
            if viewModel.allFiles.isEmpty && !viewModel.isScanning {
                emptyState(message: "Configure your search and click Scan", icon: "doc.text.magnifyingglass")
            } else if viewModel.files.isEmpty && !viewModel.allFiles.isEmpty {
                emptyState(message: "No files match your filter", icon: "line.3.horizontal.decrease.circle")
            } else {
                fileList
            }
        }
    }

    private func emptyState(message: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Files Found")
                .font(.title2)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fileList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.files) { file in
                    FileRowView(
                        file: file,
                        isSelected: viewModel.selectedFile?.id == file.id,
                        onSelect: { viewModel.selectedFile = file },
                        onRevealInFinder: { onRevealInFinder(file) },
                        onDelete: { onDelete(file) }
                    )
                    Divider()
                    .padding(.leading, 56)
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

struct FileRowView: View {
    let file: ScannedFile
    let isSelected: Bool
    let onSelect: () -> Void
    let onRevealInFinder: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: fileIcon(for: file.extension_))
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                Text(file.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Text(file.sizeDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
                .monospacedDigit()

            Text(file.modifiedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .contextMenu {
            Button("Reveal in Finder") { onRevealInFinder() }
            Divider()
            Button("Move to Trash", role: .destructive) { onDelete() }
        }
    }

    private func fileIcon(for ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic": return "photo.fill"
        case "mp4", "mov", "avi", "mkv": return "film.fill"
        case "mp3", "wav", "aac", "flac": return "music.note"
        case "zip", "tar", "gz", "rar": return "doc.zipper"
        case "dmg", "iso": return "externaldrive.fill"
        case "app": return "app.fill"
        case "swift", "py", "js", "ts", "java": return "chevron.left.forwardslash.chevron.right"
        default: return "doc.fill"
        }
    }
}
