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
    
    // MARK: OUTLETS & VARIABLES
    
    var myContext:Int? = nil
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var PlayPause: UIButton!
    @IBOutlet weak var CurrentTime: UILabel!
    @IBOutlet weak var TimeLeft: UILabel!
    @IBOutlet weak var theProgressBar: UISlider!
    @IBOutlet weak var PodcastNameLabel: MarqueeLabel!
    @IBOutlet weak var PodcastImageView: UIImageView!
    @IBOutlet weak var PodcastDescription: UILabel!
    
    var podcast: Podcast?
    var podcastUrl: String?
    var podcastName: String?
    var path: String = ""
    var updater : CADisplayLink! = nil
    var newDuration: CMTime = kCMTimeZero
    var newDurationSeconds: Float64 = 0.0
    let preDurationString: String = "-"
    var inRunLoop: Bool = false
    var newPlayerInit: Bool = false
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    // MARK: INITIALIZERS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayerVisuals()
    
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView!.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView!.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
        setUpPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AudioController.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: appDelegate.playerItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpPlayer() {
        appDelegate.registerAudioController(aController: self)
        // (Re)initialize player, if it has not been initialized or the currently playing item is different from the one we want to play.
        if appDelegate.player == nil || appDelegate.podcastName != self.podcast?.podcastTitle {
            appDelegate.setupPlayer(pUrl: podcastUrl!, podcast: self.podcast!)
            newPlayerInit = true
        }
        let playerLayer = AVPlayerLayer(player: appDelegate.player!)
        playerLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.view.layer.addSublayer(playerLayer)
        updater = CADisplayLink(target: self, selector: #selector(AudioController.trackAudio))
        addObserver(self, forKeyPath: #keyPath(appDelegate.player.currentItem.duration), options: [.new, .initial], context: &myContext)
        if newPlayerInit == true {
            appDelegate.togglePlayPause()
        } else {
            if appDelegate.player?.rate == 0 {
                self.pause()
            } else {
                self.play()
            }
        }
    }
    
    func updatePlayerVisuals() {
        podcastName = podcast!.podcastTitle
        let podcastImageData = podcast?.podcastImage
        if podcastImageData != nil {
            let image = UIImage(data: podcastImageData as! Data)
            PodcastImageView.image = image
        }
        PodcastDescription.text = podcast?.podcastDescription
        
        
        PodcastNameLabel.text = podcastName
        PodcastNameLabel.type = .continuous
        PodcastNameLabel.speed = .rate(40)
        PodcastNameLabel.animationCurve = .easeInOut
        PodcastNameLabel.fadeLength = 10.0
        PodcastNameLabel.leadingBuffer = 15.0
        PodcastNameLabel.trailingBuffer = 15.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "GetSeries" {
            let destination = segue.destination as! PodcastSeriesController
            destination.seriesID = podcast?.podcastCollectionID
            destination.parentVC = self
            
        }
    }
    
    // MARK: HELPERS
    
    // Observe playerItem duration. Update player view and labels accordingly.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(appDelegate.player.currentItem.duration) {
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
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds((appDelegate.player?.currentTime())!)) : 0.0
            
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
        theProgressBar.value = Float(CMTimeGetSeconds((appDelegate.player?.currentTime())!))
        CurrentTime.text = createTimeString(time: theProgressBar.value)
        TimeLeft.text = preDurationString + createTimeString(time: Float(newDurationSeconds) - theProgressBar.value)
    }
    
    func finishedPlaying(myNotification:NSNotification) {
        PlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        
        let stoppedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: kCMTimeZero)
    }
    
    @IBAction func PlayPauseClick(_ sender: Any) {
        appDelegate.togglePlayPause()
    }
    
    func play() {
        PlayPause.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
        updater.preferredFramesPerSecond = 15
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        inRunLoop = true
    }
    
    func pause() {
        PlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
    }
    
    @IBAction func SliderMoved(_ sender: Any) {
        let CMProgressValue = CMTimeMake(Int64(theProgressBar.value), 1)
        appDelegate.player?.seek(to: CMProgressValue)
        appDelegate.updateInfoCenter()
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
