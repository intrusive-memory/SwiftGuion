//
//  LocationsWindowView.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftData
import SwiftGuion

struct LocationsWindowView: View {
    let documentID: String?

    @Environment(\.modelContext) private var modelContext
    @Query private var documents: [GuionDocumentModel]

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            if let document = documents.first {
                LocationsListView(document: document, searchText: searchText)
            } else {
                EmptyLocationsView()
            }
        }
        .navigationTitle("Locations")
        #if os(macOS)
        .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
        #endif
        .searchable(text: $searchText, prompt: "Search locations")
    }
}

struct LocationsListView: View {
    let document: GuionDocumentModel
    let searchText: String

    private var locations: [LocationGroup] {
        // Get all scene locations
        let sceneLocations = document.sceneLocations

        // Group by location key
        var grouped: [String: LocationGroup] = [:]

        for (element, location) in sceneLocations {
            let key = location.locationKey
            if grouped[key] == nil {
                grouped[key] = LocationGroup(
                    location: location,
                    scenes: []
                )
            }
            grouped[key]?.scenes.append(element)
        }

        // Convert to array and sort
        var result = Array(grouped.values)
        result.sort { $0.location.fullLocation < $1.location.fullLocation }

        // Filter by search text if needed
        if !searchText.isEmpty {
            result = result.filter {
                $0.location.fullLocation.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        List {
            if locations.isEmpty {
                ContentUnavailableView(
                    "No locations found",
                    systemImage: "location.slash",
                    description: Text(searchText.isEmpty ? "No scene headings in this screenplay" : "No locations match your search")
                )
            } else {
                ForEach(locations) { locationGroup in
                    LocationRowView(locationGroup: locationGroup)
                }
            }
        }
    }
}

struct LocationGroup: Identifiable {
    let id = UUID()
    let location: SceneLocation
    var scenes: [GuionElementModel]
}

struct LocationRowView: View {
    let locationGroup: LocationGroup

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(locationGroup.scenes, id: \.self) { scene in
                    HStack {
                        if let sceneNumber = scene.sceneNumber {
                            Text("#\(sceneNumber)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, alignment: .trailing)
                        }
                        Text(scene.elementText)
                            .font(.caption)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.leading, 8)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: locationIcon)
                        .foregroundStyle(locationColor)
                        .frame(width: 20)

                    Text(locationGroup.location.fullLocation)
                        .font(.headline)

                    Spacer()

                    Text("\(locationGroup.scenes.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }

                if let timeOfDay = locationGroup.location.timeOfDay {
                    HStack(spacing: 4) {
                        Text(locationGroup.location.lighting.standardAbbreviation)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(timeOfDay)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var locationIcon: String {
        switch locationGroup.location.lighting {
        case .interior:
            return "house.fill"
        case .exterior:
            return "tree.fill"
        case .interiorExterior, .interiorExteriorAlt, .interiorExteriorShort:
            return "door.left.hand.open"
        case .unknown:
            return "location.fill"
        }
    }

    private var locationColor: Color {
        switch locationGroup.location.lighting {
        case .interior:
            return .blue
        case .exterior:
            return .green
        case .interiorExterior, .interiorExteriorAlt, .interiorExteriorShort:
            return .orange
        case .unknown:
            return .gray
        }
    }
}

struct EmptyLocationsView: View {
    var body: some View {
        ContentUnavailableView(
            "No Document",
            systemImage: "doc.text",
            description: Text("Open a screenplay to view locations")
        )
    }
}

#Preview {
    LocationsWindowView(documentID: nil)
        .modelContainer(for: GuionDocumentModel.self, inMemory: true)
}
