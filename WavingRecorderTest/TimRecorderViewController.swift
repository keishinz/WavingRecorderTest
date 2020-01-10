//
//  TimRecorderViewController.swift
//  WavingRecorderTest
//
//  Created by Keishin CHOU on 2020/01/10.
//  Copyright © 2020 Keishin CHOU. All rights reserved.
//


import UIKit
import AVFoundation

class TimRecorderViewController: UIViewController {
    var waveformView:SCSiriWaveformView!
    var recorder:AVAudioRecorder!

    override func viewDidLoad() {
        super.viewDidLoad()

        waveformView = SCSiriWaveformView()
        waveformView.waveColor = UIColor.white
        waveformView.primaryWaveLineWidth = 3.0
        waveformView.secondaryWaveLineWidth = 1.0
        self.view.addSubview(waveformView)
        waveformView.frame = view.frame

        let url:NSURL = NSURL(fileURLWithPath: "/dev/null")
        let settings:NSDictionary = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]

        do {
            try recorder = AVAudioRecorder(url: url as URL, settings: settings as! [String : Any])
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch {

        }

        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()

        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }

    @objc func updateMeters() {
        recorder.updateMeters()
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePower(forChannel: 0))/20)
        waveformView.update(withLevel: normalizedValue)
    }
}

