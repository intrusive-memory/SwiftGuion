//
//  GuionDocumentModel.swift
//  FountainDocumentApp
//
//  Copyright (c) 2025
//

import Foundation
#if canImport(SwiftData)
import SwiftData

@Model
public final class GuionDocumentModel {
    public var filename: String?
    public var rawContent: String?
    public var suppressSceneNumbers: Bool

    @Relationship(deleteRule: .cascade, inverse: \GuionElementModel.document)
    public var elements: [GuionElementModel]

    @Relationship(deleteRule: .cascade, inverse: \TitlePageEntryModel.document)
    public var titlePage: [TitlePageEntryModel]

    public init(filename: String? = nil, rawContent: String? = nil, suppressSceneNumbers: Bool = false) {
        self.filename = filename
        self.rawContent = rawContent
        self.suppressSceneNumbers = suppressSceneNumbers
        self.elements = []
        self.titlePage = []
    }
}

@Model
public final class GuionElementModel: GuionElementProtocol {
    public var elementText: String
    public var elementType: String
    public var isCentered: Bool
    public var isDualDialogue: Bool
    public var sceneNumber: String?
    public var sectionDepth: Int
    public var sceneId: String?

    // SwiftData-specific properties
    public var summary: String?
    public var document: GuionDocumentModel?

    public init(elementText: String, elementType: String, isCentered: Bool = false, isDualDialogue: Bool = false, sceneNumber: String? = nil, sectionDepth: Int = 0, summary: String? = nil, sceneId: String? = nil) {
        self.elementText = elementText
        self.elementType = elementType
        self.isCentered = isCentered
        self.isDualDialogue = isDualDialogue
        self.sceneNumber = sceneNumber
        self.sectionDepth = sectionDepth
        self.summary = summary
        self.sceneId = sceneId
    }

    /// Initialize from any GuionElementProtocol conforming type
    public convenience init<T: GuionElementProtocol>(from element: T, summary: String? = nil) {
        self.init(
            elementText: element.elementText,
            elementType: element.elementType,
            isCentered: element.isCentered,
            isDualDialogue: element.isDualDialogue,
            sceneNumber: element.sceneNumber,
            sectionDepth: element.sectionDepth,
            summary: summary,
            sceneId: element.sceneId
        )
    }
}

@Model
public final class TitlePageEntryModel {
    public var key: String
    public var values: [String]

    public var document: GuionDocumentModel?

    public init(key: String, values: [String]) {
        self.key = key
        self.values = values
    }
}
#endif
