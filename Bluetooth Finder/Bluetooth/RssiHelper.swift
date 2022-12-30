//
//  HeatColors.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/25/22.
//

import Foundation
import CoreGraphics

struct RssiColor {
    var min: Int
    var max: Int
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    
    func isRssiInRange(_ rssi: Int) -> Bool {
        return rssi <= max && rssi >= min
    }
}

struct RssiImage {
    var min: Int
    var max: Int
    var imageName: String
    
    func isRssiInRange(_ rssi: Int) -> Bool {
        return rssi <= max && rssi >= min
    }
}

struct RssiHelper {
    /*
     Colors: cold to hot
     #aad4e5,
     #abc5d2,
     #acb6bf,
     #ada7ad,
     #ae999a,
     #af8a87,
     #b07b74,
     #b16c61,
     #b25d4e,
     #b34e3b,
     #b44029,
     #b53116,
     #b62203,
     */
    
    var colors: [RssiColor] = [
        RssiColor(min: -90, max: -86, red: 0xaa, green: 0xd4, blue: 0xe5),
        RssiColor(min: -85, max: -81, red: 0xab, green: 0xc5, blue: 0xd2),
        RssiColor(min: -80, max: -76, red: 0xac, green: 0xb6, blue: 0xbf),
        RssiColor(min: -75, max: -71, red: 0xad, green: 0xa7, blue: 0xad),
        RssiColor(min: -70, max: -67, red: 0xae, green: 0x99, blue: 0x9a),
        RssiColor(min: -66, max: -63, red: 0xaf, green: 0x8a, blue: 0x87),
        RssiColor(min: -62, max: -59, red: 0xb0, green: 0x7b, blue: 0x74),
        RssiColor(min: -58, max: -55, red: 0xb1, green: 0x6c, blue: 0x61),
        RssiColor(min: -54, max: -51, red: 0xb2, green: 0x5d, blue: 0x4e),
        RssiColor(min: -50, max: -47, red: 0xb3, green: 0x4e, blue: 0x3b),
        RssiColor(min: -46, max: -43, red: 0xb4, green: 0x40, blue: 0x29),
        RssiColor(min: -42, max: -39, red: 0xb5, green: 0x31, blue: 0x16),
        RssiColor(min: -38, max: -35, red: 0xb6, green: 0x22, blue: 0x03),
    ]
    
    var images: [RssiImage] = [
        RssiImage(min: -90, max: -85, imageName: "red-signal-1"),
        RssiImage(min: -84, max: -80, imageName: "red-signal-2"),
        RssiImage(min: -79, max: -72, imageName: "orange-signal-1"),
        RssiImage(min: -71, max: -64, imageName: "orange-signal-2"),
        RssiImage(min: -63, max: -58, imageName: "yellow-signal-1"),
        RssiImage(min: -57, max: -52, imageName: "yellow-signal-2"),
        RssiImage(min: -52, max: -46, imageName: "green-signal-1"),
        RssiImage(min: -46, max: -30, imageName: "green-signal-2"),
    ]
    
    func getColorFor(_ rssi: Int) -> CGColor {
        for color in colors {
            if color.isRssiInRange(rssi) {
                return CGColor(red: color.red / 255, green: color.green / 255, blue: color.blue / 255, alpha: 1.0)
            }
        }
        
        return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func getImageNameFor(_ rssi: Int) -> String {
        for image in images {
            if image.isRssiInRange(rssi) {
                return image.imageName
            }
        }
        
        return "no-signal"
    }
    
    func translateRssi(_ rssi: Int) -> String {
        if rssi > -90 && rssi <= -81 {
            return "❄️🥶❄️🥶❄️🥶"
        }
        
        if rssi > -81 && rssi <= -67 {
            return "Getting warmer"
        }
        
        if rssi > -67 && rssi <= -55 {
            return "Warmer!"
        }
        
        if rssi > -55 && rssi <= -47 {
            return "Hot!!"
        }
        
        if rssi > -47 && rssi <= -39 {
            return "🔥🔥🔥"
        }
        
        if rssi > -39 && rssi <= -30 {
            return "🔥🥵🔥🥵🔥🥵"
        }
        
        return "❌❌❌"
    }
    
}
