//
//  ViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var updater: CADisplayLink?
    var playPause: UIButton?
    

    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.white


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPlayer() {
        if appDelegate.player != nil {
            let screenSize: CGRect = UIScreen.main.bounds
            let myView = UIView(frame: CGRect(x: 0, y: screenSize.height - 99, width: screenSize.width, height: 50))
            playPause = UIButton(frame: CGRect(x: screenSize.width - 50, y: 0, width: 50, height: 50))
            playPause?.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            myView.backgroundColor = UIColor.black
            myView.addSubview(playPause!)
            self.view.addSubview(myView)
            updater = CADisplayLink(target: self, selector: #selector(listenPlayPause))
            updater?.preferredFramesPerSecond = 5
            updater?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        }
    }

    func togglePlayPause() {
        appDelegate.togglePlayPause()
    }
    
    func listenPlayPause() {
        if appDelegate.player?.rate == 0 {
            playPause?.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        } else {
            playPause?.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
        }
    }
}

