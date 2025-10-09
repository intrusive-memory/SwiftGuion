//
//  CharacterInspectorView.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftGuion

/// Inspector view showing character list and statistics
struct CharacterInspectorView: View {
    let characters: CharacterList
    @State private var searchText = ""
    @State private var sortBy: SortOption = .alphabetical

    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case lineCount = "Line Count"
        case wordCount = "Word Count"
        case sceneCount = "Scene Count"
    }

    var sortedCharacters: [(name: String, info: CharacterInfo)] {
        let filtered = characters.filter { name, _ in
            searchText.isEmpty || name.localizedCaseInsensitiveContains(searchText)
        }

        let sorted = filtered.sorted { lhs, rhs in
            switch sortBy {
            case .alphabetical:
                return lhs.key < rhs.key
            case .lineCount:
                return lhs.value.counts.lineCount > rhs.value.counts.lineCount
            case .wordCount:
                return lhs.value.counts.wordCount > rhs.value.counts.wordCount
            case .sceneCount:
                return lhs.value.scenes.count > rhs.value.scenes.count
            }
        }

        return sorted.map { (name: $0.key, info: $0.value) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Characters")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(characters.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search characters", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))

            // Sort picker
            Picker("Sort by", selection: $sortBy) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Divider()

            // Character list
            if sortedCharacters.isEmpty {
                EmptyCharacterListView(searchText: searchText)
            } else {
                List(sortedCharacters, id: \.name) { character in
                    CharacterInspectorRowView(name: character.name, info: character.info)
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 250, idealWidth: 300)
    }
}

/// Individual character row
struct CharacterInspectorRowView: View {
    let name: String
    let info: CharacterInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)

            HStack(spacing: 12) {
                StatBadge(icon: "text.bubble", value: "\(info.counts.lineCount)", label: "lines")
                StatBadge(icon: "text.word.spacing", value: "\(info.counts.wordCount)", label: "words")
                StatBadge(icon: "film", value: "\(info.scenes.count)", label: "scenes")
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

/// Small stat badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

/// Empty state view
struct EmptyCharacterListView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: searchText.isEmpty ? "person.2.slash" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "No characters found" : "No matches")
                .font(.headline)
                .foregroundStyle(.secondary)
            if !searchText.isEmpty {
                Text("Try a different search")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    let sampleCharacters: CharacterList = [
        "BERNARD": CharacterInfo(
            counts: CharacterCounts(lineCount: 45, wordCount: 320),
            gender: CharacterGender(),
            scenes: [1, 3, 5, 7, 9, 12, 15]
        ),
        "KILLIAN": CharacterInfo(
            counts: CharacterCounts(lineCount: 38, wordCount: 290),
            gender: CharacterGender(),
            scenes: [1, 5, 9, 12]
        ),
        "SARAH": CharacterInfo(
            counts: CharacterCounts(lineCount: 22, wordCount: 180),
            gender: CharacterGender(),
            scenes: [2, 4, 8, 11]
        ),
    ]

    CharacterInspectorView(characters: sampleCharacters)
        .frame(width: 300, height: 600)
}
