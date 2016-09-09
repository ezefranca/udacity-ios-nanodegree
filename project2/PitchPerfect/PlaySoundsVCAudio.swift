//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright © 2016 Udacity. All rights reserved.
//
import UIKit
import AVFoundation

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // raw values correspond to sender tags
    enum PlayingState { case Playing, NotPlaying }
    
    
    // MARK: Audio Functions
    
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(error))
        }
    }
    
    func playSound(rate rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attachNode(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.MultiEcho1)
        audioEngine.attachNode(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attachNode(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer!, forMode: NSDefaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func stopAudio() {
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.NotPlaying)
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    
    // MARK: UI Functions
    
    func configureUI(playState: PlayingState) {
        switch(playState) {
        case .Playing:
            setPlayButtonsEnabled(false)
            stopButton.enabled = true
        case .NotPlaying:
            setPlayButtonsEnabled(true)
            stopButton.enabled = false
        }
    }
    
    func setPlayButtonsEnabled(enabled: Bool) {
        snailButton.enabled = enabled
        chipmunkButton.enabled = enabled
        rabbitButton.enabled = enabled
        vaderButton.enabled = enabled
        echoButton.enabled = enabled
        reverbButton.enabled = enabled
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}