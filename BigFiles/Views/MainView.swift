import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ScanViewModel()
    @State private var showingHistory = false
    @State private var showingExport = false
    @State private var showingDeleteAlert = false
    @State private var fileToDelete: ScannedFile?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(profile: $viewModel.profile, showingHistory: $showingHistory)
        } detail: {
            ZStack {
                VStack(spacing: 0) {
                    headerBar

                    Divider()

                    if viewModel.isScanning, let progress = viewModel.progress {
                        ScanProgressView(
                            progress: progress,
                            isScanning: viewModel.isScanning,
                            onCancel: { viewModel.cancelScan() }
                        )
                    } else {
                        FileListView(
                            viewModel: viewModel,
                            onRevealInFinder: { file in
                                viewModel.revealInFinder(file)
                            },
                            onDelete: { file in
                                fileToDelete = file
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                .background(Color(nsColor: .textBackgroundColor))
            }
            .overlay(alignment: .bottom) {
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.startScan() }
                }) {
                    Label("Scan", systemImage: "magnifyingglass")
                }
                .disabled(viewModel.isScanning)

                Button(action: { showingExport = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.files.isEmpty)
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView { profile in
                viewModel.profile = profile
            }
        }
        .sheet(isPresented: $showingExport) {
            ExportView(
                onExportCSV: { viewModel.exportToCSV() },
                onExportJSON: { viewModel.exportToJSON() }
            )
        }
        .alert("Move to Trash?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Move to Trash", role: .destructive) {
                if let file = fileToDelete {
                    try? viewModel.moveToTrash(file)
                }
            }
        } message: {
            if let file = fileToDelete {
                Text("Are you sure you want to move \"\(file.name)\" to Trash?")
            }
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if viewModel.allFiles.isEmpty && !viewModel.isScanning {
                    Text("Ready to scan")
                        .font(.headline)
                    Text("Configure filters and click Scan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if viewModel.isScanning {
                    Text("Scanning...")
                        .font(.headline)
                    Text(viewModel.profile.directory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    let count = viewModel.files.count
                    let total = viewModel.allFiles.count
                    if count == total {
                        Text("\(count) files found")
                            .font(.headline)
                    } else {
                        Text("\(count) of \(total) files")
                            .font(.headline)
                    }
                    Text(viewModel.profile.directory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
            Spacer()
            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
