//
//  TitlePageEntryModel.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//

import Foundation
import SwiftData


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
