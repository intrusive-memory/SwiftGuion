//
//  CharactersWindowView.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftData
import SwiftGuion

struct CharactersWindowView: View {
    let documentID: String?

    @Environment(\.modelContext) private var modelContext
    @Query private var documents: [GuionDocumentModel]

    @State private var searchText = ""
    @State private var sortOrder: CharacterSortOrder = .alphabetical

    var body: some View {
        VStack(spacing: 0) {
            if let document = documents.first {
                CharactersListView(
                    document: document,
                    searchText: searchText,
                    sortOrder: sortOrder
                )
            } else {
                EmptyCharactersView()
            }
        }
        .navigationTitle("Characters")
        #if os(macOS)
        .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
        #endif
        .searchable(text: $searchText, prompt: "Search characters")
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker("Sort By", selection: $sortOrder) {
                        Label("Alphabetical", systemImage: "textformat.abc")
                            .tag(CharacterSortOrder.alphabetical)
                        Label("Most Lines", systemImage: "text.line.first.and.arrowtriangle.forward")
                            .tag(CharacterSortOrder.mostLines)
                        Label("Most Words", systemImage: "text.word.spacing")
                            .tag(CharacterSortOrder.mostWords)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }
}

enum CharacterSortOrder {
    case alphabetical
    case mostLines
    case mostWords
}

struct CharactersListView: View {
    let document: GuionDocumentModel
    let searchText: String
    let sortOrder: CharacterSortOrder

    private var characters: [CharacterEntry] {
        var entries = extractCharacters()

        // Filter by search
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOrder {
        case .alphabetical:
            entries.sort { $0.name < $1.name }
        case .mostLines:
            entries.sort { $0.lineCount > $1.lineCount }
        case .mostWords:
            entries.sort { $0.wordCount > $1.wordCount }
        }

        return entries
    }

    var body: some View {
        List {
            if characters.isEmpty {
                ContentUnavailableView(
                    "No characters found",
                    systemImage: "person.slash",
                    description: Text(searchText.isEmpty ? "No dialogue in this screenplay" : "No characters match your search")
                )
            } else {
                ForEach(characters) { character in
                    CharacterRowView(character: character)
                }
            }
        }
    }

    private func extractCharacters() -> [CharacterEntry] {
        var characterMap: [String: CharacterEntry] = [:]
        var currentSceneIndex: Int = -1
        var lastCharacterName: String?

        for element in document.elements {
            // Track scene changes
            if element.elementType == "Scene Heading" {
                currentSceneIndex += 1
            }

            // Process character dialogue
            if element.elementType == "Character" {
                let characterName = cleanCharacterName(element.elementText)
                lastCharacterName = characterName

                // Initialize character if needed
                if characterMap[characterName] == nil {
                    characterMap[characterName] = CharacterEntry(
                        name: characterName,
                        lineCount: 0,
                        wordCount: 0,
                        scenes: [],
                        firstDialogue: nil
                    )
                }

                // Add scene if not already tracked
                if currentSceneIndex >= 0 && !characterMap[characterName]!.scenes.contains(currentSceneIndex) {
                    characterMap[characterName]!.scenes.append(currentSceneIndex)
                }

                // Increment line count
                characterMap[characterName]!.lineCount += 1
            }

            // Process dialogue content
            if element.elementType == "Dialogue" {
                if let characterName = lastCharacterName {
                    let wordCount = countWords(in: element.elementText)
                    characterMap[characterName]!.wordCount += wordCount

                    // Store first dialogue if not set
                    if characterMap[characterName]!.firstDialogue == nil {
                        characterMap[characterName]!.firstDialogue = element.elementText
                    }
                }
            }

            // Also count parenthetical words
            if element.elementType == "Parenthetical" {
                if let characterName = lastCharacterName {
                    let wordCount = countWords(in: element.elementText)
                    characterMap[characterName]!.wordCount += wordCount
                }
            }
        }

        return Array(characterMap.values)
    }

    private func cleanCharacterName(_ name: String) -> String {
        var cleaned = name.trimmingCharacters(in: .whitespaces)

        // Remove character extensions like (V.O.), (O.S.), (CONT'D)
        if let openParen = cleaned.firstIndex(of: "(") {
            cleaned = String(cleaned[..<openParen]).trimmingCharacters(in: .whitespaces)
        }

        // Remove dual dialogue marker
        cleaned = cleaned.replacingOccurrences(of: "^", with: "").trimmingCharacters(in: .whitespaces)

        return cleaned.uppercased()
    }

    private func countWords(in text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return words.count
    }
}

struct CharacterEntry: Identifiable {
    let id = UUID()
    let name: String
    var lineCount: Int
    var wordCount: Int
    var scenes: [Int]
    var firstDialogue: String?
}

struct CharacterRowView: View {
    let character: CharacterEntry

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                // Statistics
                VStack(alignment: .leading, spacing: 4) {
                    StatRow(label: "Lines of dialogue", value: "\(character.lineCount)")
                    StatRow(label: "Word count", value: "\(character.wordCount)")
                    StatRow(label: "Scenes", value: "\(character.scenes.count)")
                }

                // First dialogue
                if let firstDialogue = character.firstDialogue {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First line:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\"\(firstDialogue)\"")
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.primary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(.leading, 8)
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(character.name)
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label("\(character.lineCount)", systemImage: "text.line.first.and.arrowtriangle.forward")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Label("\(character.wordCount)", systemImage: "text.word.spacing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(character.scenes.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
                .fontWeight(.medium)
        }
    }
}

struct EmptyCharactersView: View {
    var body: some View {
        ContentUnavailableView(
            "No Document",
            systemImage: "doc.text",
            description: Text("Open a screenplay to view characters")
        )
    }
}

#Preview {
    CharactersWindowView(documentID: nil)
        .modelContainer(for: GuionDocumentModel.self, inMemory: true)
}
