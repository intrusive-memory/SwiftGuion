//
//  ContentView.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftData
import SwiftGuion
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var configuration: GuionDocumentConfiguration

    @State private var isParsing = false
    @State private var parseError: Error?
    @State private var showCharacterInspector = false

    // Export state management
    @State private var showFountainExport = false
    @State private var showFDXExport = false
    @State private var exportError: Error?

    var body: some View {
        let _ = print("🔄 ContentView body rendered: \(configuration.document.elements.count) elements, isParsing: \(isParsing), rawContent: \(configuration.document.rawContent?.count ?? 0) chars")

        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Main content - Scene Browser
                VStack(spacing: 0) {
                    if let error = parseError {
                        ErrorView(error: error)
                    } else if configuration.document.elements.isEmpty && !isParsing {
                        EmptyScreenplayView()
                    } else if !configuration.document.elements.isEmpty {
                        // Scene Browser as main content
                        let script = GuionDocumentParserSwiftData.toFountainScript(from: configuration.document)
                        SceneBrowserWidget(script: script)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Character inspector (right side panel)
                if showCharacterInspector && !configuration.document.elements.isEmpty {
                    Divider()
                    CharacterInspectorView(characters: configuration.document.extractCharacters())
                        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300, maxHeight: .infinity)
                }
            }

            // Progress bar at bottom
            if isParsing {
                Divider()
                HStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Loading screenplay...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        #if os(macOS)
        .toolbar {
            ToolbarItemGroup {
                Button(action: openLocationsWindow) {
                    Label("Locations", systemImage: "location.circle")
                }
                .help("Show locations")
                .disabled(configuration.document.elements.isEmpty)

                Button(action: { showCharacterInspector.toggle() }) {
                    Label("Characters", systemImage: "person.2")
                }
                .help("Toggle character inspector")
                .disabled(configuration.document.elements.isEmpty)
                .keyboardShortcut("i", modifiers: [.command, .option])

                Menu {
                    Button("Fountain Format...") {
                        showFountainExport = true
                    }
                    Button("Final Draft Format...") {
                        showFDXExport = true
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(configuration.document.elements.isEmpty)
                .help("Export to other formats")
            }
        }
        #endif
        .fileExporter(
            isPresented: $showFountainExport,
            document: FountainExportDocument(sourceDocument: configuration.document),
            contentType: .fountainDocument,
            defaultFilename: defaultExportFilename(for: .fountain)
        ) { result in
            handleExportResult(result, format: .fountain)
        }
        .fileExporter(
            isPresented: $showFDXExport,
            document: FDXExportDocument(sourceDocument: configuration.document),
            contentType: .fdxDocument,
            defaultFilename: defaultExportFilename(for: .fdx)
        ) { result in
            handleExportResult(result, format: .fdx)
        }
        .alert("Export Error", isPresented: .constant(exportError != nil), presenting: exportError) { _ in
            Button("OK") { exportError = nil }
        } message: { error in
            Text(error.localizedDescription)
        }
        .task {
            await parseDocumentIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportAsFountain)) { _ in
            showFountainExport = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportAsFDX)) { _ in
            showFDXExport = true
        }
    }

    private func parseDocumentIfNeeded() async {
        // Only parse if we have raw content but no elements
        guard configuration.document.elements.isEmpty,
              let rawContent = configuration.document.rawContent,
              !rawContent.isEmpty else {
            print("⚠️ Skipping parse: elements.isEmpty=\(configuration.document.elements.isEmpty), rawContent exists=\(configuration.document.rawContent != nil)")
            return
        }

        print("📖 Starting parse for file: \(configuration.document.filename ?? "unknown")")
        isParsing = true
        defer { isParsing = false }

        do {
            // Determine content type from filename
            let contentType = contentTypeFromFilename(configuration.document.filename)
            print("📄 Content type: \(contentType)")

            // Parse and get new document - this triggers binding update
            let parsedDoc = try await GuionDocumentModel.parseContent(
                rawContent: rawContent,
                filename: configuration.document.filename,
                contentType: contentType,
                modelContext: modelContext
            )

            print("✅ Parse complete: \(parsedDoc.elements.count) elements")
            configuration.document = parsedDoc
            print("✅ Configuration updated, elements now: \(configuration.document.elements.count)")
        } catch {
            parseError = error
            print("❌ Error parsing screenplay: \(error)")
        }
    }

    private func contentTypeFromFilename(_ filename: String?) -> UTType {
        guard let filename = filename else { return .fountainDocument }

        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "fdx":
            return .fdxDocument
        case "highland":
            return .highlandDocument
        case "fountain":
            return .fountainDocument
        default:
            return .fountainDocument
        }
    }

    #if os(macOS)
    private func openLocationsWindow() {
        // Open locations window
        // This would need to be implemented with proper window management
    }
    #endif

    // MARK: - Export Helper Methods

    /// Generate default export filename based on format
    private func defaultExportFilename(for format: ExportFormat) -> String {
        guard let currentFilename = configuration.document.filename else {
            return "Untitled.\(format.fileExtension)"
        }

        // Strip .guion extension if present, add new extension
        let baseName = (currentFilename as NSString).deletingPathExtension
        return "\(baseName).\(format.fileExtension)"
    }

    /// Handle export result
    private func handleExportResult(_ result: Result<URL, Error>, format: ExportFormat) {
        switch result {
        case .success(let url):
            print("✅ Successfully exported to \(format.displayName): \(url.path)")
        case .failure(let error):
            print("❌ Export to \(format.displayName) failed: \(error.localizedDescription)")
            exportError = error
        }
    }
}

struct ErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundStyle(.red)
            Text("Error loading screenplay")
                .font(.title2)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ScreenplayView: View {
    let document: GuionDocumentModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Title Page
                if !document.titlePage.isEmpty {
                    TitlePageView(titlePage: document.titlePage)
                        .padding(.bottom, 32)
                }

                // Script Elements
                ForEach(document.elements, id: \.self) { element in
                    ElementView(element: element)
                }
            }
            .padding()
            .frame(maxWidth: 800)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TitlePageView: View {
    let titlePage: [TitlePageEntryModel]

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            ForEach(titlePage, id: \.key) { entry in
                VStack(alignment: .center, spacing: 2) {
                    Text(entry.key.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(entry.values, id: \.self) { value in
                        Text(value)
                            .font(.title3)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

struct ElementView: View {
    let element: GuionElementModel

    var body: some View {
        HStack {
            if element.isCentered {
                Spacer()
            } else {
                leadingSpacer
            }

            Text(element.elementText)
                .font(fontForElement)
                .fontWeight(element.elementType == "Scene Heading" ? .bold : .regular)
                .foregroundStyle(colorForElement)
                .textSelection(.enabled)
                .multilineTextAlignment(element.isCentered ? .center : .leading)

            if element.isCentered {
                Spacer()
            } else {
                Spacer()
            }
        }
        .padding(.vertical, verticalPaddingForElement)
    }

    @ViewBuilder
    private var leadingSpacer: some View {
        switch element.elementType {
        case "Character":
            Spacer().frame(width: 200)
        case "Parenthetical":
            Spacer().frame(width: 180)
        case "Dialogue":
            Spacer().frame(width: 120)
        case "Transition":
            EmptyView()
        default:
            EmptyView()
        }
    }

    private var fontForElement: Font {
        switch element.elementType {
        case "Scene Heading":
            return .system(.body, design: .monospaced)
        case "Character":
            return .system(.body, design: .monospaced)
        default:
            return .system(.body, design: .monospaced)
        }
    }

    private var colorForElement: Color {
        switch element.elementType {
        case "Scene Heading":
            return .primary
        case "Character":
            return .primary
        case "Parenthetical":
            return .secondary
        case "Transition":
            return .secondary
        default:
            return .primary
        }
    }

    private var verticalPaddingForElement: CGFloat {
        switch element.elementType {
        case "Scene Heading":
            return 8
        case "Character":
            return 4
        case "Action":
            return 2
        default:
            return 1
        }
    }
}

struct EmptyScreenplayView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No screenplay loaded")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Import a .fountain, .fdx, or .highland file")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var config = GuionDocumentConfiguration()
    ContentView(configuration: $config)
        .modelContainer(for: GuionDocumentModel.self, inMemory: true)
}
