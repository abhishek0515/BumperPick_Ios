//
//  Filter.swift
//  BumperPick
//
//  Created by tauseef hussain on 13/07/25.
//

import Foundation

enum FilterTab: String, CaseIterable {
    case distance = "Distance"
    case categories = "Categories"
    case bumperPick = "Bumperpick Choice"
}

struct FilterOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}
