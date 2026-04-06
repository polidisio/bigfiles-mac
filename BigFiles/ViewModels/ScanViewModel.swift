import Foundation
import AppKit

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var profile = ScanProfile()
    @Published var allFiles: [ScannedFile] = []
    @Published var isScanning = false
    @Published var progress: FileScanner.Progress?
    @Published var errorMessage: String?
    @Published var selectedFile: ScannedFile?

    private let scanner = FileScanner()
    private let historyStore = ScanHistoryStore.shared

    var files: [ScannedFile] {
        var result = allFiles

        if !profile.searchText.isEmpty {
            let query = profile.searchText.lowercased()
            result = result.filter { file in
                file.name.lowercased().contains(query) ||
                file.path.lowercased().contains(query)
            }
        }

        return sortFiles(result, by: profile.sortBy, secondary: profile.secondarySortBy)
    }

    var currentResult: ScanResult? {
        guard !files.isEmpty else { return nil }
        return ScanResult(profile: profile, files: files)
    }

    func startScan() async {
        guard !isScanning else { return }

        isScanning = true
        errorMessage = nil
        allFiles = []
        progress = nil
        selectedFile = nil

        do {
            let scannedFiles = try await scanner.scan(profile: profile) { [weak self] prog in
                Task { @MainActor in
                    self?.progress = prog
                }
            }

            allFiles = scannedFiles

            if !allFiles.isEmpty {
                let result = ScanResult(profile: profile, files: files)
                historyStore.save(result: result)
            }
        } catch let error as FileScanner.ScanError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isScanning = false
        progress = nil
    }

    func cancelScan() {
        Task {
            await scanner.cancel()
        }
    }

    func moveToTrash(_ file: ScannedFile) throws {
        let url = URL(fileURLWithPath: file.path)
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        allFiles.removeAll { $0.id == file.id }
    }

    func revealInFinder(_ file: ScannedFile) {
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
    }

    func exportToCSV() -> URL? {
        var csv = "Name,Path,Size,Modified,Extension\n"
        for file in files {
            let row = "\"\(file.name)\",\"\(file.path)\",\(file.size),\"\(file.modifiedDescription)\",\"\(file.extension_)\"\n"
            csv += row
        }

        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileURL = downloadsURL.appendingPathComponent("bigfiles_export_\(timestamp).csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
            return fileURL
        } catch {
            return nil
        }
    }

    func exportToJSON() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(files)
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let timestamp = Int(Date().timeIntervalSince1970)
            let fileURL = downloadsURL.appendingPathComponent("bigfiles_export_\(timestamp).json")
            try data.write(to: fileURL)
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
            return fileURL
        } catch {
            return nil
        }
    }

    private func sortFiles(_ files: [ScannedFile], by primary: ScanProfile.SortField, secondary: ScanProfile.SortField?) -> [ScannedFile] {
        let sorted = files.sorted { f1, f2 in
            let cmp = compareFiles(f1, f2, by: primary)
            if cmp != .orderedSame {
                return cmp == .orderedAscending
            }
            if let secondary = secondary {
                return compareFiles(f1, f2, by: secondary) == .orderedAscending
            }
            return false
        }
        return sorted
    }

    private func compareFiles(_ f1: ScannedFile, _ f2: ScannedFile, by field: ScanProfile.SortField) -> ComparisonResult {
        switch field {
        case .size:
            return f1.size > f2.size ? .orderedAscending : (f1.size < f2.size ? .orderedDescending : .orderedSame)
        case .name:
            return f1.name.localizedCaseInsensitiveCompare(f2.name)
        case .path:
            return f1.path.localizedCaseInsensitiveCompare(f2.path)
        case .modified:
            return f1.modifiedDate > f2.modifiedDate ? .orderedAscending : (f1.modifiedDate < f2.modifiedDate ? .orderedDescending : .orderedSame)
        }
    }
}
