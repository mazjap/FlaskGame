//
//  Flask.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import Foundation
import UIKit.UIColor

struct Flask: Equatable, Identifiable {
    typealias Color = UIColor
    
    // MARK: - Variables
    
    // Private
    private(set) var colors: [Color]
    
    // Public
    var id: String {
        "Colors: \(colors) \n" +
        "Index: \(index)"
    }
    var index: Int
    
    // Computed
    var viewColors: [Color] {
        guard colors.count <= 4 else { return Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)]) }
        return [Color](repeating: .clear, count: 4 - colors.count).reversed() + colors
    }
    var topColor: Color {
        colors.first ?? .clear
    }
    var topColorCount: Int {
        guard topColor != .clear else { return 0 }
        
        var count = 0
        for color in colors {
            if color != topColor {
                break
            }
            
            count += 1
        }
        
        return count
    }
    
    var isPure: Bool {
        if let test = colors.first {
            for color in colors {
                guard color == test else { return false }
            }
        }
        
        return true
    }
    
    // MARK: - Init
    
    init(colors: [Color], index: Int = 0) {
        if colors.count > 4 {
            self.colors = Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)])
        } else {
            self.colors = colors
        }
        
        self.index = index
    }
    
    init(_ color: Color, index: Int = 0) {
        self.colors = [Color](repeating: color, count: 4)
        self.index = index
    }
    
    // MARK: - Functions
    
    // Mutating
    mutating func addColor(_ color: Color, count: Int = 1) -> Int {
        let avaibleSpace = max(0, 4 - colors.count)
        let amount = min(avaibleSpace, count)
        
        if color == topColor || topColor == .clear {
            colors = [Color](repeating: color, count: amount) + colors
            return count - amount
        } else {
            return count
        }
    }
    
    mutating func removeTop(_ count: Int = 0) {
        let to = min(count, topColorCount)
        
        for _ in 0..<to {
            colors.removeFirst()
        }
    }
    
    // MARK: - Static
    
    // Variables
    static let noFlask = Flask(colors: [])
    
    // Functions
    static func noFlask(index: Int) -> Self {
        var flask = noFlask
        flask.index = index
        
        return flask
    }
    
    static func == (lhs: Flask, rhs: Flask) -> Bool {
        return lhs.id == rhs.id
    }
}
