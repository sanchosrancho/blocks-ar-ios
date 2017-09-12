//
//  Extensions.swift
//  Modify
//
//  Created by Олег Адамов on 11.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import SceneKit


extension SCNVector3: Equatable {
    
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}


extension UIColor {
    
    class func fromRGB(r: Int, g: Int, b: Int, a: CGFloat? = nil) -> UIColor {
        let alpha = a ?? 1
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }
    
    
    class func fromHex(_ hexString: String?) -> UIColor {
        let defaultColor = UIColor.white
        guard let hex = hexString, hex.characters.count == 8 else { return defaultColor }
        
        let r, g, b, a: CGFloat
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { return defaultColor }
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    func hexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "%02X%02X%02X%02X", Int(r * 0xff), Int(g * 0xff), Int(b * 0xff), Int(a * 0xff)).lowercased()
    }
}


extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
