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
    var inRunLoop: Bool = false
    var myView: UIView?
    

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
            myView = UIView(frame: CGRect(x: 0, y: screenSize.height - 99, width: screenSize.width, height: 50))
            let labelFrame = CGRect(x: 0, y: 0, width: screenSize.width - 50, height: 50)
            let PodcastNameLabel = MarqueeLabel.init(frame: labelFrame)
            PodcastNameLabel.text = appDelegate.podcastName
            PodcastNameLabel.textColor = UIColor.white
            PodcastNameLabel.type = .continuous
            PodcastNameLabel.speed = .rate(40)
            PodcastNameLabel.animationCurve = .easeInOut
            PodcastNameLabel.fadeLength = 10.0
            PodcastNameLabel.leadingBuffer = 15.0
            PodcastNameLabel.trailingBuffer = 15.0
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(hidePlayer))
            PodcastNameLabel.isUserInteractionEnabled = true
            PodcastNameLabel.addGestureRecognizer(tap)
            
            playPause = UIButton(frame: CGRect(x: screenSize.width - 50, y: 0, width: 50, height: 50))
            playPause?.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            myView?.backgroundColor = UIColor.init(white: 0.1, alpha: 0.98)
            myView?.addSubview(PodcastNameLabel)
            myView?.addSubview(playPause!)
            self.view.addSubview(myView!)
            if !inRunLoop {
                updater = CADisplayLink(target: self, selector: #selector(listenPlayPause))
                updater?.preferredFramesPerSecond = 5
                updater?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    func hidePlayer() {
        if inRunLoop {
            updater?.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        }
        myView?.removeFromSuperview()
    }

    func togglePlayPause() {
        appDelegate.togglePlayPause()
    }
    
    func listenPlayPause() {
        if appDelegate.player?.rate == 0 {
            playPause?.setImage(UIImage(named: "play_bar"), for: UIControlState.normal)
        } else {
            playPause?.setImage(UIImage(named: "pause_bar"), for: UIControlState.normal)
        }
    }
}

