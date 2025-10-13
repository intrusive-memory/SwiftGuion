//
//  SpeakableContent.swift
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

/// Protocol for screenplay elements that can be spoken aloud
/// Provides the speakable text content for different element types
public protocol SpeakableContent {
    /// Returns the speakable string content for this element
    /// - Returns: The text that should be spoken for this element
    func speakableText() -> String
}

// MARK: - GuionElementProtocol Extension

extension GuionElementProtocol {
    /// Returns the speakable string content based on element type
    /// - Scene Heading: Returns the entire slug line
    /// - Character: Returns the character name
    /// - Dialogue: Returns the character's line text
    /// - Parenthetical: Returns the parenthetical direction
    /// - Action: Returns the action description
    /// - Transition: Returns the transition text
    /// - Lyrics: Returns the lyrics text
    /// - Other types: Returns the element text as-is
    public func speakableText() -> String {
        switch elementType {
        case "Scene Heading":
            // For sluglines, speak the entire scene heading
            return elementText

        case "Character":
            // Speak the character name
            return elementText

        case "Dialogue":
            // For dialogue, speak the text of the character's line
            return elementText

        case "Parenthetical":
            // Speak the parenthetical direction
            return elementText

        case "Action":
            // For action, speak the text description
            return elementText

        case "Transition":
            // Speak the transition
            return elementText

        case "Lyrics":
            // Speak the lyrics
            return elementText

        case "Synopsis":
            // Speak the synopsis
            return elementText

        case "Section Heading":
            // Speak the section heading
            return elementText

        case "Comment", "Boneyard":
            // Comments and boneyard are not typically spoken
            return ""

        case "Page Break":
            // Page breaks are not spoken
            return ""

        default:
            // For any other element type, return the text
            return elementText
        }
    }
}

// MARK: - GuionElement Conformance

extension GuionElement: SpeakableContent {}
