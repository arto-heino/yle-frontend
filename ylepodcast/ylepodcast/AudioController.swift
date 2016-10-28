//
//  AudioController.swift
//  ylepodcast
//
//  Created by Milos Berka on 28.10.2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
var bombSoundEffect: AVAudioPlayer!

class AudioController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded.")
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.path(forResource: "Icarus_ZBII.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()
        } catch {
            // couldn't load file :(
            print("Not able to load file.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
