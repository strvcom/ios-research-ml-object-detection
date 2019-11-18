//
//  TrackItemType.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 01/05/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation

enum TrackItemType {
    case apple, banana, dragonFruit, mango, pineapple
}

extension TrackItemType {
    var supportedValues: [String] {
        switch self {
        case .apple:
            return ["apple"]
        case .banana:
            return ["banana"]
        case .dragonFruit:
            return ["dragon fruit"]
        case .mango:
            return ["mango"]
        case .pineapple:
            return ["pineapple"]
        }
    }

    static func shouldTrack(items: [TrackItemType], for classifier: String) -> Bool {
        return items.first(where: { $0.supportedValues.contains(classifier)} ) != nil
    }
}
