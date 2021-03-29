//
//  ModelViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//
import UIKit
import SceneKit

class ModelViewController: UIViewController, SCNSceneRendererDelegate {


    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sceneView: SCNView!

    
    @IBOutlet weak var clearButton: RoundButton!
    @IBOutlet weak var calculationButton: RoundButton!
    
    
    
    var modelData: ModelData?
    var mesh: SCNGeometry? = nil
    var colormapShader: String = ""
    var checkeredShader: String = ""
    var countMarker: Int = 0
    var marker = Array(repeating: SCNVector3(), count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        calculationButton.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        calculationButton.setTitleColor(.gray, for: .normal)
        calculationButton.isEnabled = false

        
        sceneSetup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        sceneView.delegate = self
    }
    
    //Speichern der Daten in einem JSON
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let appData = modelData?.exportAsJSON()
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

    //Auswahl des angewendeten Shaders
    @IBAction func chooseMaterialPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = modelData?.colorImage
        case 1:
            mesh!.shaderModifiers = [:]
            mesh!.firstMaterial!.diffuse.contents = UIColor(red: 254/255, green: 177/255, blue: 154/255, alpha: 0.8)
        case 2:
            mesh!.shaderModifiers = [.surface: checkeredShader]
            mesh!.firstMaterial!.diffuse.contents = modelData?.colorImage
        case 3:
            mesh!.shaderModifiers = [.surface: colormapShader]
            mesh!.firstMaterial!.diffuse.contents = modelData?.colorImage
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
            
            //Aktivierung der Shader
            var shaderURL = Bundle.main.url(forResource: "colormap", withExtension: "shader")

                do {
                    let shader = try String(contentsOf: shaderURL!)
                    colormapShader = shader
                } catch {
                    fatalError("Can't load colormap shader from bundle.")
                }
        
            shaderURL = Bundle.main.url(forResource: "checkered", withExtension: "shader")

                do {
                    let shader = try String(contentsOf: shaderURL!)
                    checkeredShader = shader
                } catch {
                    fatalError("Can't load checkered shader from bundle.")
                }
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

            
            //Farbe der Spiegelung
            mesh!.firstMaterial!.specular.contents = UIColor.gray
            let meshNode = SCNNode(geometry: mesh)
            meshNode.name = "Model"
            scene.rootNode.addChildNode(meshNode)
            
            // x/y/z Nullpunkt anzeigen
            //scene.rootNode.addChildNode(Origin())

            sceneView.scene = scene
            
            sceneView.allowsCameraControl = true
        }
    
    private func findHit( withName searchName: String, in array: [SCNHitTestResult])-> SCNHitTestResult?
    {
        for(_, hit) in array.enumerated()
        {
            if hit.node.name == searchName {
                return hit
            }
        }
        return nil
    }
    //Setzen der Marker
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        let sceneView = self.sceneView!
        
        print("Bildschirm berührt")
        if countMarker == 2 {
            calculationButton.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            calculationButton.setTitleColor(.black, for: .normal)
            calculationButton.isEnabled = true
        } else {
            calculationButton.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
            calculationButton.setTitleColor(.gray, for: .normal)
            calculationButton.isEnabled = false
        }
        
        let p = gestureRecognize.location(in: sceneView)
        let hits = sceneView.hitTest(p, options: [:])
        
        let hit = findHit(withName: "Model", in: hits)
        
        if(hit == nil) {
            return
        }
        
        if countMarker > 2 {
            sceneView.scene?.rootNode.enumerateChildNodes { (node , stop) in
                if node.name == "Marker" {
                    node.removeFromParentNode()
                    //marker.removeAll()
                }
            }
            countMarker = 0
        }
        
        let hitPos = hit?.worldCoordinates
        
        marker[countMarker] = hitPos!
        
        //print("-> \(hitPos!)")
        
        let sphere = SCNSphere(radius: 0.01)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode(geometry: sphere)
        node.position = hitPos!
        node.name = "Marker"
        sceneView.scene?.rootNode.addChildNode(node)
        
        countMarker += 1
        
    }
    
    //Aller markierungen löschen
    @IBAction func clearButtonPressed(_ sender: Any) {
        if countMarker > 0 {
        sceneView.scene?.rootNode.enumerateChildNodes { (node , stop) in
            if node.name == "Marker" {
                node.removeFromParentNode()
            }
        }
            //marker.removeAll()
        calculationButton.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        calculationButton.setTitleColor(.gray, for: .normal)
        calculationButton.isEnabled = false
        countMarker = 0
        }
    }
    
    //identifizieren der entsprechenden Marker zu VP,DL und DR.
    @IBAction func calculationButtonPressed(_ sender: Any) {
        
        var dl = SCNVector3()
        var dr = SCNVector3()
        
        if countMarker >= 3 {
            for m in marker {
                if(hasMaxY(m)) {
                    modelData?.markerVP = m
                }
                else if hasMinX(m) {
                    dl = m
                } else {
                    dr = m
                }
            }
        }
        
        //Berechnen von DM durch weiteren Strahl in die Scene und überprüfen an welcher stelle er das Objekt trifft
        let m = (dl+dr)*0.5
        
        var rayStart = m
        var rayEnd = m
        rayStart.z = 0
        rayEnd.z = 1
        
        let hits = (sceneView.scene?.rootNode.hitTestWithSegment(from: rayStart, to: rayEnd, options: [:]))!
        let hit = findHit(withName: "Model", in: hits)
        
        modelData?.markerDM = hit!.worldCoordinates
        modelData?.markerDR = dr
        modelData?.markerDL = dl
        
    }
    
    private func hasMinX(_ p: SCNVector3) -> Bool {
        for m in marker {
            if m.x < p.x {
                return false
            }
        }
        return true
    }
    
    private func hasMaxY(_ p: SCNVector3) -> Bool {
        for m in marker {
            if m.y > p.y {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let parameterViewController: ParameterViewController = segue.destination as! ParameterViewController
        parameterViewController.modelData = modelData
    }
}
