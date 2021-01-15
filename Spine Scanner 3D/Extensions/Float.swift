//
//  Float.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//

//Umrechnung eines Floats von grad in radius oder andersherum
extension Float {
    func inDegree() -> Float {
        return self * 180 / .pi
    }
    
    func inRadians() -> Float {
        return self * .pi / 180
    }
}
