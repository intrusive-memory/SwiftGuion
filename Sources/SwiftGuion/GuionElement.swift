//
//  GuionElement.swift
//  SwiftGuion
//
//  Copyright (c) 2012-2013 Nima Yousefi & John August
//  Swift conversion (c) 2025
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation

/// Protocol defining the core properties of a screenplay element
public protocol GuionElementProtocol {
    var elementType: String { get set }
    var elementText: String { get set }
    var isCentered: Bool { get set }
    var isDualDialogue: Bool { get set }
    var sceneNumber: String? { get set }
    var sectionDepth: Int { get set }
    var sceneId: String? { get set }
}

/// Lightweight struct representing a screenplay element
/// Used by parsers and FountainScript for in-memory representation
public struct GuionElement: GuionElementProtocol {
    public var elementType: String
    public var elementText: String
    public var isCentered: Bool
    public var isDualDialogue: Bool
    public var sceneNumber: String?
    public var sectionDepth: Int
    public var sceneId: String?

    public init(elementType: String = "", elementText: String = "") {
        self.elementType = elementType
        self.elementText = elementText
        self.isCentered = false
        self.sceneNumber = nil
        self.isDualDialogue = false
        self.sectionDepth = 0
        self.sceneId = nil
    }

    public init(type: String, text: String) {
        self.init(elementType: type, elementText: text)
    }

    /// Initialize from any GuionElementProtocol conforming type
    public init<T: GuionElementProtocol>(from element: T) {
        self.elementType = element.elementType
        self.elementText = element.elementText
        self.isCentered = element.isCentered
        self.isDualDialogue = element.isDualDialogue
        self.sceneNumber = element.sceneNumber
        self.sectionDepth = element.sectionDepth
        self.sceneId = element.sceneId
    }
}

extension GuionElement: Sendable {}

extension GuionElement: CustomStringConvertible {
    public var description: String {
        var typeOutput = elementType

        if isCentered {
            typeOutput += " (centered)"
        } else if isDualDialogue {
            typeOutput += " (dual dialogue)"
        } else if sectionDepth > 0 {
            typeOutput += " (\(sectionDepth))"
        }

        return "\(typeOutput): \(elementText)"
    }
}

// MARK: - Protocol Extensions
extension GuionElementProtocol {
    public var description: String {
        var typeOutput = elementType

        if isCentered {
            typeOutput += " (centered)"
        } else if isDualDialogue {
            typeOutput += " (dual dialogue)"
        } else if sectionDepth > 0 {
            typeOutput += " (\(sectionDepth))"
        }

        return "\(typeOutput): \(elementText)"
    }
}
