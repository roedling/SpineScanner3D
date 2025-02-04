//
//  ModelData.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//
import Foundation
import SceneKit
import ARKit


class ModelData {
    
    private var depthMap: [[Float32]] = [[]]    // 2d array (Tiefendaten lidar)
    private var vertices: [SCNVector3] = []     // 3d vertices
    private var normals: [SCNVector3] = []      // normale für jeden vertex
    private var texCoord: [simd_float2] = []    // Textur koordinaten
    private var idxMatrix: [[Int32?]] = [[]]    // 2d array mit zeigern in das vertices array
                                                
    private var triangleIndices: [Int32] = []   // 1d array der triangle indices als Zeiger auf das Index array (idxMatrix)
    
    var frameCopy: ARFrame? = nil
    // Kamera intrinsics
    private var fx: Float32 = 0
    private var fy: Float32 = 0
    private var cx: Float32 = 0
    private var cy: Float32 = 0
    
    // Kamera euler angles
    private var euler = simd_float3(0,0,0)
    
    // Kamera intrinsics
    private var intrinsics = simd_float3x3(0)
    
    // Kamera Aufloessung
     private var camWidth: Int = 0
     private var camHeight: Int = 0

     // LiDAR Aufloessung
     private var lidarWidth: Int = 0
     private var lidarHeight: Int = 0

    //Marker Positionen
    var markerDL: SCNVector3 = SCNVector3()
    var markerDR: SCNVector3 = SCNVector3()
    var markerVP: SCNVector3 = SCNVector3()
    var markerDM: SCNVector3 = SCNVector3()
    
    
    // Originales Farbbild
    var colorImage = UIImage()
    
    private var timestamp: TimeInterval = 0
    
    //Persönliche Daten
    var name: String = ""
    var age: String = ""
        
    // Konstruktor um die Daten aus dem JSON zu laden
//    init() {
//        let asset = NSDataAsset(name: "ExampleScan1", bundle: Bundle.main)
//        let json: NSDictionary = try! JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
//
//        if (json["depthMap"] == nil) {
//            print("No depth data found")
//            return
//        }
//
//        let depthMapAsDouble = json["depthMap"] as? [[Double]] ?? [[]]
//        depthMap = Array(repeating: Array(repeating: Float32(0), count: depthMapAsDouble[0].count), count: depthMapAsDouble.count)
//        for ix in 0..<depthMapAsDouble.count {
//            for iy in 0..<depthMapAsDouble[ix].count {
//                depthMap[ix][iy] = Float(depthMapAsDouble[ix][iy])
//            }
//        }
//
//        let cameraIntrinsics = json["cameraIntrinsics"] as? [[Float32]] ?? [[]]
//
//        // cam & lidar haben (scheinbar) immer querformat (landscape)
//        // bei aufnahme im hochformat (portrait) geht die x achse dann also nach oben (oder nach unten)
//        // das bild erscheint dann um 90 grad gedreht
//        //
//        // Quer (ausgangsformat):
//        // Euler: x = -2º, y = 0º, z = -1º  also Handy quer, kamera links oben = (0,0,0)
//        // Lidar: w = 256.0, h = 192.0, cx = 127.50073, cy = 91.79468
//        //
//        // Hochkant:
//        // Euler: x = -4º, y = 0º, z = -90º  Handy hochkannt => kamera rechts oben = querformat um -90º um die z-achse gedreht
//        // Lidar: w = 256.0, h = 192.0, cx = 123.33783, cy = 95.96991
//        //
//        // Euler positiv => drehung nach links, Euler negativ = drehung nach rechts
//
//
//        let camWidth = (json["camImageResolution"] as! NSDictionary)["width"] as! Float32
//        let camHeight = (json["camImageResolution"] as! NSDictionary)["height"] as! Float32
//
//        let lidarWidth = (json["depthMapResolution"] as! NSDictionary)["width"] as! Float32
//        let lidarHeight = (json["depthMapResolution"] as! NSDictionary)["height"] as! Float32
//
//        let xScale = 1.0/camWidth * lidarWidth
//        let yScale = 1.0/camHeight * lidarHeight
//
//        fx = cameraIntrinsics[0][0] * xScale
//        fy = cameraIntrinsics[1][1] * yScale
//        cx = cameraIntrinsics[0][2] * xScale
//        cy = cameraIntrinsics[1][2] * yScale
//
//        euler.x = Float32((json["cameraEulerAngle"] as! NSDictionary)["x"] as! Double)
//        euler.y = Float32((json["cameraEulerAngle"] as! NSDictionary)["y"] as! Double)
//        euler.z = Float32((json["cameraEulerAngle"] as! NSDictionary)["z"] as! Double)
//
//        if ((json["colorImage"]) != nil) {
//            let imgBase64 = (json["colorImage"] as? String)!
//            let imageDecoded = Data(base64Encoded: imgBase64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
//            colorImage = UIImage(data: imageDecoded)!
//        }
//
//        print("\(#function): Lidar: w = \(lidarWidth), h = \(lidarHeight), cx = \(cx), cy = \(cy)")
//        print("\(#function): Euler: x = \(Int(euler.x.inDegree().rounded()))º, y = \(Int(euler.y.inDegree().rounded()))º, z = \(Int(euler.z.inDegree().rounded()))º")
//
//    }
    
    // Konstruktor (während der Laufzeit)
    init(_ frame: ARFrame?) {
        guard let cvDepthMap = frame!.smoothedSceneDepth?.depthMap else {
            print("Error, no depth map")
            return
        }
        let p = CVPixelBufferGetPixelFormatType(cvDepthMap)
        if p != kCVPixelFormatType_DepthFloat32 {
            print("Error, wrong depth map type")
            return
        }
        
        depthMap = cvDepthMap.exportAsArray()
        

        euler = frame!.camera.eulerAngles
        intrinsics = frame!.camera.intrinsics
        
        camWidth = Int(frame!.camera.imageResolution.width)
        camHeight = Int(frame!.camera.imageResolution.height)
        
        lidarWidth = CVPixelBufferGetWidth(cvDepthMap)
        lidarHeight = CVPixelBufferGetHeight(cvDepthMap)
        
        // Skaliert die Kamera intrinsics auf die Größe des LiDAR Sensor
        let xScale = 1.0/Float(camWidth) * Float(lidarWidth)
        let yScale = 1.0/Float(camHeight) * Float(lidarHeight)
        
        fx = frame!.camera.intrinsics[0][0] * xScale
        fy = frame!.camera.intrinsics[1][1] * yScale
        cx = frame!.camera.intrinsics[2][0] * xScale
        cy = frame!.camera.intrinsics[2][1] * yScale

        
        colorImage = frame!.capturedImage.toUIImage()
        
        timestamp = frame!.timestamp
          
        print("\(#function): Euler: x = \(Int(euler.x.inDegree().rounded()))º, y = \(Int(euler.y.inDegree().rounded()))º, z = \(Int(euler.z.inDegree().rounded()))º")
        print("\(#function): Lidar: w = \(lidarWidth), h = \(lidarHeight), cx = \(cx), cy = \(cy)")
    }
    
    // generiert das Mesh
    func generateMesh(_ maxDepth: Float32 = 1.0) -> SCNGeometry {
        
        // reset array
        triangleIndices = []
        
        let w = depthMap.count
        let h = depthMap[0].count
        print("\(#function): w = \(w), h = \(h)")
        
        // kleinster z-wert aller vertices, um das Model später auf die richtige Entfernung zu setzen
        var minZ: Float32 = Float.greatestFiniteMagnitude
        
        // init 2d matrix von indices. Jeder Index zeigt auf einen 3D-vertex. Die x- und y-Koordinaten der 3d-vertices sind an der 2d-Matrix ausgerichtet.
        idxMatrix = Array(repeating: Array(repeating: nil, count: h), count: w)
        
        // Berechnen der Punkte im Raum (von Tiefenkart zu Punktwolke)
        var idx:Int32 = 0
        for ix in 0..<w {
            for iy in 0..<h {
                let z = depthMap[ix][iy] //
                
                if (z < maxDepth) {  // Maximaltiefe beachten um Hintergrundobjekte zu eliminieren
                    
                    let x = z * (Float32(ix) - cx) / fx
                    let y = z * (Float32(iy) - cy) / fy
                    
                    // coordinaten raum in sceneview ist: z zeigt zur kamera und die schaut nach -z, x nach rechts und y nach oben
                    // depth sensor schaut aber nach +z!
                    // aktuell wird die kamera einfach nach z=-1m verschoben und dann um 180º um die y achse gedreht
                    // danach zeigt die x achse allerdings nach links, daher:
                    
                    var point3d: SCNVector3 = SCNVector3(-1*x, -1*y, z) // spiegeln an der x und y Achse um das Model an das SceneView Koordinatensystem anzupassen
                    point3d.rotateZ(euler.z)  // Kompensieren von Yaw (um die z Achse)
                    point3d.rotateX(euler.x)  // Kompensieren von Pitch (um die x Achse)
                    
                    //Vorbereiten für das Generieren des Meshs
                    vertices.append(point3d) // Umgerechnete Punkte in die List der Vertices hinzufügen
                    normals.append(SCNVector3(x:0,y:0,z:0)) // Leere Normale anlegen
                    texCoord.append(simd_float2(Float(ix)/Float(w),Float(iy)/Float(h))) // hinzufügen der normalisierten Texturkoordinaten
                    idxMatrix[ix][iy] = idx  // Indexliste
                    idx+=1  // vorbereitung für den nächsten Index
                    
                    // kleinsten z Werte der Punktewolke speichern, um das Modell in die richtige Entfernung zu setzen
                    minZ = (point3d.z < minZ) ? point3d.z : minZ
                }
            }
        }
        
        // Das Modell wird mittig in den View des Betrachters gerückt
        // Ausserdem wird der kleinste z-Wert verwendet um die Entfernung des Modells zu setzen
        let idxCenter = idxMatrix[Int(w/2)][Int(h/2)] // Zentrum der Tiefenkarte
        var center = SCNVector3(0,0,0)
        if (idxCenter != nil) {
            center = vertices[Int(idxCenter!)]  //Vertex im Zentrum finden
        }
        for index in vertices.indices {
            vertices[index] += SCNVector3(-center.x,-center.y,-minZ)
        }
        
        print("\(#function): total points: \(w*h), valid points: \(idx)")
        
        // generiert für jedes "Viereck" 2 Dreiecke (Überspringen von letzter Zeile und Spalte)
        for ix in 0..<w-1 {
            for iy in 0..<h-1 {
                genTriangle(idxMatrix[ix][iy],idxMatrix[ix][iy+1],idxMatrix[ix+1][iy])
                genTriangle(idxMatrix[ix+1][iy],idxMatrix[ix][iy+1],idxMatrix[ix+1][iy+1])
            }
        }
        //print("Punkt 0:\(triangleIndices[0]) Punkt 1:\(triangleIndices[1])")
        
        
        // Generieren der Datenstruktur für SCNGeometry
    
        let vertexData = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
        
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        let normalData = NSData(bytes: normals, length: MemoryLayout<SCNVector3>.size * normals.count) as Data
        
        let normalSource = SCNGeometrySource(data: normalData,
                                             semantic: .normal,
                                             vectorCount: normals.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        let texCoordData = NSData(bytes: texCoord, length: MemoryLayout<simd_float2>.size * texCoord.count) as Data
        let texCoordSource = SCNGeometrySource(data: texCoordData,
                                             semantic: .texcoord,
                                             vectorCount: texCoord.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 2,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<simd_float2>.stride)
        
        let elementData = NSData(bytes: triangleIndices, length: MemoryLayout<Int32>.size * triangleIndices.count) as Data
        
        let element = SCNGeometryElement(data: elementData,
                                         primitiveType: .triangles,
                                         primitiveCount: triangleIndices.count/3,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource,normalSource,texCoordSource], elements: [element])
        
    }
    
    private func genTriangle(_ p1:Int32?, _ p2:Int32?, _ p3:Int32?) {
        if (p1 == nil || p2 == nil || p3 == nil) {
            // generiert kein dreieck wenn nicht alle Vertices vorhanden sind
            return
        }
        if(maxZ(p1!,p2!,p3!)>0.2) {
            return
        }
        triangleIndices.append(p1!)
        triangleIndices.append(p2!)
        triangleIndices.append(p3!)
        
        var n = calcNormal(p1!,p2!,p3!)  // berechnen der Normale
        
        //Falls Normale von Betrachter weg zeigt, werden diese einem gedreht
        n.z = (n.z > 0) ? -n.z : n.z
        
        // normalisierte Normale des Dreiecks zur Normalen aller 3 Vertices hinzufügen
        // Am Ende alle Normalen der benachbarten Dreiecke zu jedem Vertex hinzugefügen
        // Die resultierende Normalen repräsentiert den Mittelwert zwischen allen benachbarten Dreiecken
        // am Ende noch Normalisieren
        normals[Int(p1!)] += n
        normals[Int(p1!)].normalize()
        normals[Int(p2!)] += n
        normals[Int(p2!)].normalize()
        normals[Int(p3!)] += n
        normals[Int(p3!)].normalize()
    }
    
    // Kalkulierung der Normalen und normalisierung
    private func calcNormal(_ p1:Int32, _ p2:Int32, _ p3:Int32) -> SCNVector3
    {
        let v1 = vertices[Int(p1)]
        let v2 = vertices[Int(p2)]
        let v3 = vertices[Int(p3)]
        
        let n = (v2 - v1).cross(v3 - v1)
        
        return(n.normalized())
    }
    
    private func maxZ(_ p1:Int32, _ p2:Int32, _ p3:Int32) -> Float {
        let v1 = vertices[Int(p1)]
        let v2 = vertices[Int(p2)]
        let v3 = vertices[Int(p3)]
        return (max(max(v1.z, v2.z), max(v2.z, v3.z)))
    }
    
    
    // Exportieren der Daten als JSON
    func exportAsJSON() -> Data? {
        
        let capturedImageData = colorImage.pngData()
        let encodedImage = capturedImageData?.base64EncodedString(options: .lineLength64Characters)
        
        let jsonObject: [String: Any] = [
            "timeStamp": timestamp,
            "name": name,
            "age": age,
            "cameraEulerAngle": dictFromSimdFloat3(euler),
            "cameraIntrinsics": arrayFromSimdFloat3x3(intrinsics),
            "camImageResolution": [
                "width": camWidth,
                "height": camHeight
            ],
            "depthMapResolution" : [
                "width": lidarWidth,
                "height": lidarHeight
            ],
            "depthMap": depthMap,
            "colorImage": encodedImage!
        ]
        
        guard let json = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else { return nil }
        return json
    }
    
    private func dictFromSimdFloat3(_ vector: simd_float3) -> [String: Float] {
        return ["x": vector.x, "y": vector.y, "z": vector.z]
    }
    
    private func arrayFromSimdFloat3x3(_ matrix: matrix_float3x3) -> [[Float]] {
        var array: [[Float]] = Array(repeating: Array(repeating:Float(), count: 3), count: 3)
        array[0] = [matrix.columns.0.x, matrix.columns.1.x, matrix.columns.2.x]
        array[1] = [matrix.columns.0.y, matrix.columns.1.y, matrix.columns.2.y]
        array[2] = [matrix.columns.0.z, matrix.columns.1.z, matrix.columns.2.z]
        return array
    }
    
    //Berechnen der Parameter
    func trunkInclination() -> Float {
        let a = (markerDM.z - markerVP.z)
        let b = (markerDM.y - markerVP.z)
        let alpha = (atan(a/b)).inDegree()
        return alpha
    }
    func trunkImbalanceDegree() -> Float {
        let a = (markerDM.x - markerVP.x)
        let b = (markerDM.y - markerVP.y)
        let alpha = (atan(a/b)).inDegree()
        return alpha
    }
    func trunkImbalance() -> Float {
        let a = (markerDM.x - markerVP.x)
        return (a*1000)
    }
    
    func pelvicTilt() -> Float {
        let a = abs(markerDR.y - markerDL.y)
        return (a*1000)
    }
    
}
