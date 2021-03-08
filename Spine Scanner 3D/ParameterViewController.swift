//
//  ParameterViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 07.03.21.
//

import UIKit

class ParameterViewController: UIViewController {
    
    
    @IBOutlet weak var pelvicTilt: UILabel!
    @IBOutlet weak var trunkImbalance: UILabel!
    @IBOutlet weak var trunkInclination: UILabel!
    //@IBOutlet weak var trunkInclination: UITextField!
    var modelData: ModelData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //trunkInclination.layer.borderColor = UIColor.clear.cgColor
        
        trunkInclination.text = (String(format: "%.3f°, standard value: 2-3°", (modelData?.trunkInclination())!))
        
        trunkImbalance.text = /*String(format: "%.3f°, ", (modelData?.trunkImbalanceDegree())!) + */ String(format: "%.3fmm, standard value: 10mm/7+/-7mm^2", (modelData?.trunkImbalance())!)
        
        pelvicTilt.text = String(format: "%.3fmm, standard value: <10mm", (modelData?.pelvicTilt())!)

    }
    
    
    
    


}
