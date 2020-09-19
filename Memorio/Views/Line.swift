//
//  Line.swift
//  Memorio
//
//  Created by Michal Dobes on 13/08/2020.
//

import SwiftUI

struct Line: Shape {
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        return p
    }
}
