//
//  Checkmark.swift
//  Memorio
//
//  Created by Michal Dobes on 12/08/2020.
//

import SwiftUI

struct Checkmark: Shape {
    
    func path(in rect: CGRect) -> Path {
        let length = min(rect.width, rect.height)
        var p = Path()
        
        p.move(to: CGPoint(x: 0, y: length * 0.527))
        p.addLine(to: CGPoint(x: length * 0.35, y: length))
        p.addLine(to: CGPoint(x: length, y: 0))
        
        return p
    }
}
