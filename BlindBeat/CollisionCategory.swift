//
//  CollisionCategory.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 17/05/24.
//

import Foundation
import SpriteKit

// angka dalam case harus keliatan 2 pangkat
enum CollisionCategory: UInt32{
    case none = 0
    case player = 1
    case attack = 2
}
