//
//  Style.swift
//  Bézier Curve Editor
//
//  Created by Cory Knapp on 5/21/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Foundation
import AppKit

struct Style{
    static let backgroundColor = NSColor(calibratedRed: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
    static let curveColor = NSColor(calibratedRed: 0.0, green: 0.9, blue: 1.0, alpha: 1.0)
    static let controlPointColor = NSColor(calibratedRed: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    static let controlLineColor = NSColor(calibratedRed: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    static let selectedControlPointColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let hoverControlPointColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
    
    static let controlPointSize = 5.0
}
