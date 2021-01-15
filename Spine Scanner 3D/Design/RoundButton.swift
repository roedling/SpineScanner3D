//
//  RoundButton.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 12.01.21.
//

import UIKit

@IBDesignable

class RoundButton: UIButton {

    @IBInspectable var roundButton : Bool  = false {
        didSet {
            if roundButton == true {
                layer.cornerRadius = frame.height / 2
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        if roundButton == true {
            layer.cornerRadius = frame.height / 2
        }
    }

}
