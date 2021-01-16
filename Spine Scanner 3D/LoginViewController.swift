//
//  LoginViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 12.01.21.
//

import UIKit

class LoginViewController: UIViewController {

    //Erstellen der Variablen
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    var name: String = ""
    var age: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargetToTextField()
        
        startButton.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        startButton.setTitleColor(.gray, for: .normal)
        startButton.isEnabled = false
        
        //Navigation im ViewController unsichtbar machen
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
    }
    
    //Funktion die die Tastatur wieder einfahren lässt, sobald woandershin getippt wird
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //Funktion welche die Funktion textFieldChanged aufruft sobald in einem TextField etwas verändert wird
    func addTargetToTextField() {
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControl.Event.editingChanged)
        ageTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControl.Event.editingChanged)

    }
    
    //Überprüft  ob in den Textfeldern etwas steht und gibt den startButton frei wenn beide nicht leer sind
    @objc func textFieldChanged() {
        if !(nameTextField.text!.isEmpty)  && !(ageTextField.text!.isEmpty) {
            name = nameTextField.text!
            //age = ageTextField.text!
            startButton.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            startButton.setTitleColor(.black, for: .normal)
            startButton.isEnabled = true
        } else {
            startButton.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
            startButton.setTitleColor(.gray, for: .normal)
            startButton.isEnabled = false
        }
    }
    
    //übergabe von Variablen an nächsten ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if sender as! NSObject == UIBarButtonItem() { } else {
//        let cameraViewController: CameraViewController = segue.destination as! CameraViewController
//        cameraViewController.name = name
//        cameraViewController.age = age
//        }
    }
    @IBAction func startButtonPressed(_ sender: Any) {
//        guard let vc = storyboard?.instantiateViewController(identifier: "camera_VC") as? CameraViewController  else {
//            return
//        }
//        //let cameraViewController: CameraViewController = segue.destination as! CameraViewController
//
//        vc.name = name
//        vc.age = age
        }
    
}
