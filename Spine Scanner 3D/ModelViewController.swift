//
//  ModelViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//
import UIKit
import SceneKit

class ModelViewController: UIViewController {


    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sceneView: SCNView!
    //var aRDaten: Data?
    var modelData: ModelData?
    var mesh: SCNGeometry? = nil
    //var model: ModelData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneSetup()
    }
    
    //Speichern der Daten in einem JSON
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let appData = frameInfoToJSON(modelData?.frameCopy)
        else {
            print("Failed to get FrameInfo as JSON")
            return
        }
        print(modelData!.name)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let date = Date()
        let calender = Calendar.current
        let fileURL = documentsPath.appendingPathComponent("\(modelData!.name)_\(modelData!.age)_\(calender.component(.day, from: date))_\(calender.component(.month, from: date))_\(calender.component(.year, from: date))_\(calender.component(.hour, from: date))_\(calender.component(.minute, from: date)).json")
        do {
            try appData.write(to: fileURL)
    
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            //activityViewController.popoverPresentationController?.sourceView = sender
            present(activityViewController, animated: true, completion: nil)
        } catch {
            fatalError("Can't export JSON")
        }

       print("Save successful!")
   }

    
    @IBAction func chooseMaterialPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = modelData?.colorImage
        case 1:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = UIColor(red: 255/255, green: 000/255, blue: 000/255, alpha: 0.8)
        case 2:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = UIColor(red: 000/255, green: 255/255, blue: 000/255, alpha: 0.8)
        case 3:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = UIColor(red: 000/255, green: 000/255, blue: 255/255, alpha: 0.8)
        default:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = UIColor(red: 254/255, green: 177/255, blue: 154/255, alpha: 0.8)
        }
    }
    //Erstellen des 3D-Model
    func sceneSetup() {

            let scene = SCNScene()
            scene.background.contents = UIColor.darkGray
            sceneView.autoenablesDefaultLighting = true
            
            /*
            // Ambientes Licht
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = SCNLight.LightType.ambient
            ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
            scene.rootNode.addChildNode(ambientLightNode)
            
            // Lichtquelle (gleichmässig aus einer Richtung?)
            let omniLightNode = SCNNode()
            omniLightNode.light = SCNLight()
            omniLightNode.light!.type = SCNLight.LightType.omni
            omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
            omniLightNode.position = SCNVector3Make(0, 50, -50)
            scene.rootNode.addChildNode(omniLightNode)
            */
            
            // Kamera
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: -1)
            cameraNode.eulerAngles = SCNVector3(x: 0, y: Float.pi, z: 0)
            cameraNode.camera?.zNear = 0
            //cameraNode.camera?.zFar = 2.0
            scene.rootNode.addChildNode(cameraNode)

            //Oberfläche des Models bestimmen
            //model = ModelData()
            mesh = modelData!.generateMesh()
            mesh!.firstMaterial!.diffuse.contents = modelData?.colorImage // UIColor(red: 254/255, green: 177/255, blue: 154/255, alpha: 0.8)
        
            // Weitere  Einstellungen
            // rotate texture 90º for portrait mode
            //let translation = SCNMatrix4MakeTranslation(0, -1, 0)
            //let rotation = SCNMatrix4MakeRotation(Float(90.0).inRadians(), 0, 0, 1)
            //let transform = SCNMatrix4Mult(translation, rotation)
            //mesh.firstMaterial?.diffuse.contentsTransform = transform
            //mesh.firstMaterial!.diffuse.contents = UIColor(red: 254/255, green: 177/255, blue: 154/255, alpha: 0.8)
            
            //Farbe der Spiegelung
            mesh!.firstMaterial!.specular.contents = UIColor.gray
            let meshNode = SCNNode(geometry: mesh)
            scene.rootNode.addChildNode(meshNode)
            
            // x/y/z Nullpunkt anzeigen
            //scene.rootNode.addChildNode(Origin())

            sceneView.scene = scene
            
            sceneView.allowsCameraControl = true
        }
}
