import Foundation

struct ScanProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var directory: String
    var minSizeMB: Double
    var maxSizeMB: Double?
    var extensions: [String]
    var excludePatterns: [String]
    var excludeSystemDirs: Bool
    var sortBy: SortField
    var secondarySortBy: SortField?
    var limit: Int
    var searchText: String

    enum SortField: String, Codable, CaseIterable {
        case size = "Size"
        case name = "Name"
        case path = "Path"
        case modified = "Modified"

        var keyPath: String {
            switch self {
            case .size: return "size"
            case .name: return "name"
            case .path: return "path"
            case .modified: return "modifiedDate"
            }
        }
    }

    init(
        directory: String = FileManager.default.homeDirectoryForCurrentUser.path,
        minSizeMB: Double = 100,
        maxSizeMB: Double? = nil,
        extensions: [String] = [],
        excludePatterns: [String] = [],
        excludeSystemDirs: Bool = true,
        sortBy: SortField = .size,
        secondarySortBy: SortField? = nil,
        limit: Int = 50,
        searchText: String = ""
    ) {
        self.id = UUID()
        self.directory = directory
        self.minSizeMB = minSizeMB
        self.maxSizeMB = maxSizeMB
        self.extensions = extensions
        self.excludePatterns = excludePatterns
        self.excludeSystemDirs = excludeSystemDirs
        self.sortBy = sortBy
        self.secondarySortBy = secondarySortBy
        self.limit = limit
        self.searchText = searchText
    }
}
