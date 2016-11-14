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
import MediaPlayer

class AudioController: UIViewController {
    
    var myContext:Int? = nil
    @IBOutlet weak var PlayPause: UIButton!
    @IBOutlet weak var CurrentTime: UILabel!
    @IBOutlet weak var TimeLeft: UILabel!
    @IBOutlet weak var theProgressBar: UISlider!
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var path: String = ""
    var updater : CADisplayLink! = nil
    var newDuration: CMTime = kCMTimeZero
    var newDurationSeconds: Float64 = 0.0
    let preDurationString: String = "-"
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPlayer()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // MPRemoteCommandCenter commands init
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(AudioController.PlayPauseClick))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(AudioController.PlayPauseClick))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AudioController.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpPlayer() {
        let url = URL(string: "http://users.metropolia.fi/~milosb/Renegade_mixpreview.mp3")
        playerItem = AVPlayerItem(url: url!)
        
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player!)
        playerLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.view.layer.addSublayer(playerLayer)
        updater = CADisplayLink(target: self, selector: #selector(AudioController.trackAudio))
        addObserver(self, forKeyPath: #keyPath(AudioController.player.currentItem.duration), options: [.new, .initial], context: &myContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AudioController.player.currentItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            } else {
                newDuration = kCMTimeZero
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds((player?.currentTime())!)) : 0.0
            
            theProgressBar.maximumValue = Float(newDurationSeconds)
            theProgressBar.value = currentTime
            
            PlayPause.isEnabled = hasValidDuration
            theProgressBar.isEnabled = hasValidDuration
            
            CurrentTime.isEnabled = hasValidDuration
            CurrentTime.text = createTimeString(time: currentTime)
            
            TimeLeft.isEnabled = hasValidDuration
            TimeLeft.text = preDurationString + createTimeString(time: Float(newDurationSeconds))
        }
    }
    
    func trackAudio() {
        theProgressBar.value = Float(CMTimeGetSeconds((player?.currentTime())!))
        CurrentTime.text = createTimeString(time: theProgressBar.value)
        TimeLeft.text = preDurationString + createTimeString(time: Float(newDurationSeconds) - theProgressBar.value)
    }
    
    func finishedPlaying(myNotification:NSNotification) {
        PlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        
        let stoppedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: kCMTimeZero)
    }
    
    @IBAction func PlayPauseClick(_ sender: Any) {
        if player?.rate == 0 {
            player!.play()
            PlayPause.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            updater.preferredFramesPerSecond = 1
            updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        }
        else {
            player!.pause()
            PlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        }
    }
    @IBAction func SliderMoved(_ sender: Any) {
        let CMProgressValue = CMTimeMake(Int64(theProgressBar.value), 1)
        player?.seek(to: CMProgressValue)
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
