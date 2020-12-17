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
    
    var topColorAndCount: (color: Color, count: Int)? {
        guard let topColor = colors.last else { return nil }
        
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
    
    mutating func removeTop() -> (color: Color, count: Int)? {
        if let topColor = colors.last {
            var count = 0
            
            for i in (0..<colors.count).reversed() {
                if colors[i] != topColor {
                    break
                }
                
                colors.remove(at: i)
                count += 1
            }
            
            return (topColor, count)
        }
        
        return nil
    }
}

extension Flask {
    enum Errors: Error {
        case noColors
    }
}
