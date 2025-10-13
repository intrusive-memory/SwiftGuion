//
//  FDXParser.swift
//  SwiftGuion
//

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct FDXParsedElement: GuionElementProtocol {
    public var elementText: String
    public var elementType: String
    public var isCentered: Bool
    public var isDualDialogue: Bool
    public var sceneNumber: String?
    public var sectionDepth: Int
    public var sceneId: String?

    public init(elementText: String, elementType: String, isCentered: Bool, isDualDialogue: Bool, sceneNumber: String?, sectionDepth: Int, sceneId: String? = nil) {
        self.elementText = elementText
        self.elementType = elementType
        self.isCentered = isCentered
        self.isDualDialogue = isDualDialogue
        self.sceneNumber = sceneNumber
        self.sectionDepth = sectionDepth
        self.sceneId = sceneId
    }
}

public struct FDXParsedTitlePageEntry {
    public let key: String
    public let values: [String]

    public init(key: String, values: [String]) {
        self.key = key
        self.values = values
    }
}

public struct FDXParsedDocument {
    public let filename: String?
    public let rawXML: String
    public let suppressSceneNumbers: Bool
    public let elements: [FDXParsedElement]
    public let titlePageEntries: [FDXParsedTitlePageEntry]

    public init(filename: String?, rawXML: String, suppressSceneNumbers: Bool, elements: [FDXParsedElement], titlePageEntries: [FDXParsedTitlePageEntry]) {
        self.filename = filename
        self.rawXML = rawXML
        self.suppressSceneNumbers = suppressSceneNumbers
        self.elements = elements
        self.titlePageEntries = titlePageEntries
    }
}

public enum FDXParserError: Error {
    case unableToParse
}

#if canImport(FoundationXML) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
/// Parses Final Draft FDX format files into GuionElements
public final class FDXParser: NSObject {
    private enum Section {
        case none
        case scriptContent
        case titlePage
    }

    private var section: Section = .none
    private var elementStack: [String] = []

    private var isProcessingScriptParagraph = false
    private var isProcessingTitlePageParagraph = false
    private var currentParagraphType: String?
    private var currentParagraphText = ""
    private var currentTitleParagraphText = ""
    private var currentSceneNumber: String?
    private var currentSectionDepth = 0
    private var currentIsCentered = false
    private var currentIsDualDialogue = false
    private var textBuffer = ""
    private var capturingText = false

    private var elements: [FDXParsedElement] = []
    private var titlePageLines: [String] = []

    private var parsedFilename: String?
    private var rawXML: String = ""

    public func parse(data: Data, filename: String?) throws -> FDXParsedDocument {
        reset()

        parsedFilename = filename
        rawXML = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw FDXParserError.unableToParse
        }

        let titleEntries: [FDXParsedTitlePageEntry]
        if titlePageLines.isEmpty {
            titleEntries = []
        } else {
            titleEntries = [FDXParsedTitlePageEntry(key: "Title Page", values: titlePageLines)]
        }

        return FDXParsedDocument(
            filename: parsedFilename,
            rawXML: rawXML,
            suppressSceneNumbers: false,
            elements: elements,
            titlePageEntries: titleEntries
        )
    }

    private func reset() {
        section = .none
        elementStack = []
        isProcessingScriptParagraph = false
        isProcessingTitlePageParagraph = false
        currentParagraphType = nil
        currentParagraphText = ""
        currentTitleParagraphText = ""
        currentSceneNumber = nil
        currentSectionDepth = 0
        currentIsCentered = false
        currentIsDualDialogue = false
        textBuffer = ""
        capturingText = false
        elements = []
        titlePageLines = []
        parsedFilename = nil
        rawXML = ""
    }

    private func normalizedElementType(_ type: String) -> String {
        switch type {
        case "New Act":
            return "Section Heading"
        default:
            return type
        }
    }
}

extension FDXParser: XMLParserDelegate {
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        elementStack.append(elementName)

        switch elementName {
        case "Content":
            if elementStack.count >= 2 && elementStack[elementStack.count - 2] == "FinalDraft" {
                section = .scriptContent
            } else if elementStack.contains("TitlePage") {
                section = .titlePage
            }
        case "Paragraph":
            let parent = elementStack.dropLast().last
            if section == .scriptContent && parent == "Content" {
                isProcessingScriptParagraph = true
                currentParagraphType = attributeDict["Type"] ?? "Action"
                currentParagraphText = ""
                currentSceneNumber = nil
                currentSectionDepth = Int(attributeDict["Level"] ?? "0") ?? 0
                currentIsCentered = (attributeDict["Type"] == "Centered")
                currentIsDualDialogue = (attributeDict["DualDialogue"]?.lowercased() == "yes")
            } else if section == .titlePage && parent == "Content" {
                isProcessingTitlePageParagraph = true
                currentTitleParagraphText = ""
            }
        case "SceneProperties" where isProcessingScriptParagraph:
            currentSceneNumber = attributeDict["Number"]
        case "Text":
            if isProcessingScriptParagraph || isProcessingTitlePageParagraph {
                textBuffer = ""
                capturingText = true
            }
        default:
            break
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard capturingText else { return }
        textBuffer.append(string)
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "Text":
            if capturingText {
                if isProcessingScriptParagraph {
                    currentParagraphText.append(textBuffer)
                } else if isProcessingTitlePageParagraph {
                    currentTitleParagraphText.append(textBuffer)
                }
            }
            textBuffer = ""
            capturingText = false
        case "Paragraph":
            let parent = elementStack.dropLast().last
            if isProcessingScriptParagraph && parent == "Content" {
                let trimmedText = currentParagraphText.replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                let elementType = normalizedElementType(currentParagraphType ?? "Action")
                if !trimmedText.isEmpty || elementType == "Page Break" {
                    let isCentered = currentIsCentered || elementType == "Centered"

                    // Generate UUID for Scene Heading elements
                    var sceneId: String? = nil
                    if elementType == "Scene Heading" {
                        sceneId = UUID().uuidString
                    }

                    let parsedElement = FDXParsedElement(
                        elementText: trimmedText,
                        elementType: elementType,
                        isCentered: isCentered,
                        isDualDialogue: currentIsDualDialogue,
                        sceneNumber: currentSceneNumber,
                        sectionDepth: currentSectionDepth,
                        sceneId: sceneId
                    )
                    elements.append(parsedElement)
                }
                isProcessingScriptParagraph = false
                currentParagraphType = nil
                currentParagraphText = ""
                currentSceneNumber = nil
                currentSectionDepth = 0
                currentIsCentered = false
                currentIsDualDialogue = false
            } else if isProcessingTitlePageParagraph && parent == "Content" {
                let trimmed = currentTitleParagraphText.replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    titlePageLines.append(trimmed)
                }
                isProcessingTitlePageParagraph = false
                currentTitleParagraphText = ""
            }
        case "Content":
            section = .none
        default:
            break
        }

        if !elementStack.isEmpty {
            elementStack.removeLast()
        }
    }
}
#else
public final class FDXParser {
    public func parse(data: Data, filename: String?) throws -> FDXParsedDocument {
        throw FDXParserError.unableToParse
    }
}
#endif
