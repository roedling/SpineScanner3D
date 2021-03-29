//
//  ParameterViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 07.03.21.
//

import UIKit

class ParameterViewController: UIViewController {
    
    
    @IBOutlet weak var pelvicTiltSVf: UILabel!
    @IBOutlet weak var pelvicTiltSV: UILabel!
    @IBOutlet weak var pelvicTilt: UILabel!
    @IBOutlet weak var trunkImbalanceSV: UILabel!
    @IBOutlet weak var trunkImbalance: UILabel!
    @IBOutlet weak var trunkInclination: UILabel!
    @IBOutlet weak var trunkInclinationSV: UILabel!

    var modelData: ModelData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Parameter ausgabe
        trunkInclinationSV.text = ("standard value: 2-3°")
        trunkInclination.text = String(format: "%.3f°", (modelData?.trunkInclination())!)
        
        trunkImbalanceSV.text = ("standard value: 7mm (±7mm)")
        trunkImbalance.text = String(format: "%.3fmm", (modelData?.trunkImbalance())!)
        
        pelvicTiltSVf.text = ("standard value: f: 3mm (±3mm)")
        pelvicTiltSV.text = ("m: 4mm (±3mm)")
        pelvicTilt.text = String(format: "%.3fmm", (modelData?.pelvicTilt())!)
    }
    
    
    
    


}
