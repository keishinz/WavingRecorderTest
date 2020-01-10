//
//  ViewController.swift
//  WavingRecorderTest
//
//  Created by Keishin CHOU on 2020/01/10.
//  Copyright © 2020 Keishin CHOU. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {

    var waveformView: SCSiriWaveformView = {
        let view = SCSiriWaveformView()
        view.waveColor = .red
        view.primaryWaveLineWidth = 3.0
        view.secondaryWaveLineWidth = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()


    var recordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Tap to Record", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?


    override func loadView() {
        super.loadView()

        view.addSubview(waveformView)
        waveformView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        waveformView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.addSubview(recordButton)
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.topAnchor.constraint(equalTo: view!.centerYAnchor).isActive = true
        recordButton.sizeToFit()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("Failed to record!")
                    }
                }
            }
        } catch {
            print("Failed to record!")
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tim", style: .plain, target: self, action: #selector(TimRecorder))
        
    }

    func loadRecordingUI() {
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        let displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }

    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func updateMeters() {
        if let recorder = audioRecorder {
            recorder.updateMeters()
            let normalizedValue: CGFloat = pow(10, CGFloat((recorder.averagePower(forChannel: 0))) / 50)
            waveformView.update(withLevel: normalizedValue)
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            recordButton.setTitle("Tap to Stop", for: .normal)

        } catch {
            finishRecording(success: false)
        }
    }


    func finishRecording(success: Bool) {
        audioRecorder!.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }


    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }
    
    @objc func TimRecorder() {
        let viewController = TimRecorderViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
