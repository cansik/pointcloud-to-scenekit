//
//  GameViewController.swift
//  PLYToSceneKit
//
//  Created by Florian Bruggisser on 2019-02-23.
//  Copyright © 2019 bildspur. All rights reserved.
//

import SpriteKit
import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    var convertedScene = SCNScene()

    let infoLabel = SKLabelNode()

    var message : String = "" {
        didSet {
            infoLabel.text = "Status: \(message)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let scnView = self.view as! SCNView

        let hud = SKScene(size: self.view.frame.size)
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.text = "Status"
        infoLabel.fontName = "Avenir-Black"
        infoLabel.fontSize = 20.0;
        infoLabel.fontColor = NSColor.green
        infoLabel.position = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        hud.addChild(infoLabel)

        let scene = SCNScene()

        scnView.overlaySKScene = hud
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        scnView.backgroundColor = NSColor.black

        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }

    func showFileLoader()
    {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .ply file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["ply"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path = result!.path
                convertCloud(path: path)
            }
        } else {
            return
        }
    }

    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        showFileLoader()
    }

    func showFileSaver()
    {
        let dialog = NSSavePanel();

        dialog.title                   = "Choose a location to save the converted scene";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
        dialog.allowedFileTypes        = ["scn"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path = result!.path
                saveConvertedScene(path: path)
            }
        } else {
            return
        }
    }

    func saveConvertedScene(path: String){
        print("storing scene...")
        // save model
        let success = convertedScene.write(to: URL.init(fileURLWithPath:path), options: nil, delegate: nil) { (totalProgress, error, stop) in
            print("Progress \(totalProgress) Error: \(String(describing: error))")
            self.message = "saving... \(Int(totalProgress * 100))%"
        }
        print("Success: \(success)")
    }

    func convertCloud(path: String) {
        convertedScene = SCNScene()

        print("loading cloud...")

        DispatchQueue.global(qos: .background).async {
            let pointcloud = PointCloud()

            pointcloud.progressEvent.addHandler { progress in
                DispatchQueue.main.async {
                    self.message = "converting... \(Int(progress * 100))%"
                }
            }

            pointcloud.load(file: path)
            let cloud = pointcloud.getNode(useColor: true)
            cloud.name = "cloud"
            self.convertedScene.rootNode.addChildNode(cloud)

            print("loaded!")

            DispatchQueue.main.async {
                let url = URL(fileURLWithPath: path)
                let output = url.deletingPathExtension().appendingPathExtension("scn")
                let usdzOutput = url.deletingPathExtension().appendingPathExtension("usdz")
                
                print("storing scn...")
                self.saveConvertedScene(path: output.path)
            
                /*
                print("storing usdz...")
                let scnView = self.view as! SCNView
                scnView.scene?.write(to: usdzOutput, options: nil, delegate: nil, progressHandler: nil)
                //self.showFileSaver()
                 */
                
                print("done!")
            }
        }
    }
}
