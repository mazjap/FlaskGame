//
//  Flask.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import Foundation
import UIKit.UIColor

struct Flask {
    typealias Color = UIColor
    
    private var colors: [Color]
    
    var viewColors: [Color] {
        guard colors.count <= 4 else { return Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)]) }
        return colors + [Color](repeating: .clear, count: 4 - colors.count)
    }
    
    init(colors: [Color]) {
        if colors.count > 4 {
            self.colors = Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)])
        } else {
            self.colors = colors
        }
    }
    
    init(_ color: Color) {
        self.colors = [Color](repeating: color, count: 4)
    }
    
    var topColorAndCount: (color: Color, count: Int) {
        guard let topColor = colors.last else { return Self.noColorAndCount }
        
        var count = 0
        
        for i in (0..<colors.count).reversed() {
            if colors[i] != topColor {
                break
            }
            
            count += 1
        }
        
        return (topColor, count)
    }
    
    mutating func addColor(_ color: Color, count: Int = 1) -> Int {
        let avaibleSpace = max(0, 4 - colors.count)
        let amount = min(avaibleSpace, count)
        
        for _ in 0..<amount {
            colors.append(color)
        }
        
        return count - amount
    }
    
    mutating func removeTop(_ count: Int = 0) -> (color: Color, count: Int) {
        let color: UIColor, amount: Int; (color, amount) = topColorAndCount
        let from = (count != 0 && count <= amount) ? count : amount
        
        for i in (from..<colors.count).reversed() {
            colors.remove(at: i)
        }
        
        return from != 0 ? (color, from) : Self.noColorAndCount
    }
    
    static let noFlask = Flask(colors: [])
    static private let noColorAndCount: (Color, Int) = (.clear, 0)
}

extension Flask {
    enum Errors: Error {
        case noColors
    }
}
