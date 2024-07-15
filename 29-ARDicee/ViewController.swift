//
//  ViewController.swift
//  29-ARDicee
//
//  Created by administrator on 13/07/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice Redndering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                let results = sceneView.session.raycast(query)
                
                if let hitResults = results.first {
                   addDice(atlocation: hitResults)
                }
                
            }
        }
    }
    
    func addDice(atlocation intenalLocation: ARRaycastResult){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada copy.scn")!
        if let dicNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            dicNode.position = SCNVector3(x: intenalLocation.worldTransform.columns.3.x
                                     , y: intenalLocation.worldTransform.columns.3.y + dicNode.boundingSphere.radius
                                     , z: intenalLocation.worldTransform.columns.3.z)
            diceArray.append(dicNode)
            sceneView.scene.rootNode.addChildNode(dicNode)
            roll(dice: dicNode)
        }
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi / 2)
        let ramdomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi / 2)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5),
                             y: 0,
                             z: CGFloat(ramdomZ * 5),
                             duration: 0.5)
        )
    }
    
    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray{
                roll(dice: dice)
            }
        }
        
    }
    
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNOde = createPlane(withPlanceAnchor: planAnchor)
        node.addChildNode(planeNOde)
    }

    
    //MARK: - Plane Rendeing Methods
    func createPlane(withPlanceAnchor planAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planAnchor.extent.x), height: CGFloat(planAnchor.extent.z))
        let planeNOde = SCNNode()
        planeNOde.position = SCNVector3(x: planAnchor.center.x, y: 0, z: planAnchor.center.z)
        planeNOde.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        planeNOde.geometry = plane
        return planeNOde
        
    }
}


