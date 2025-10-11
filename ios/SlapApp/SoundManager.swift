//
//  SoundManager.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/11/25.
//

import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var horsePlayers: [AVAudioPlayer] = []
    private var whipPlayers: [AVAudioPlayer] = []
    private var horseDelegates: [HorsePlayerDelegate] = []
    private var whipDelegates: [WhipPlayerDelegate] = []
    private var isHorsePlaying = false

    private var horseSounds: [(name: String, ext: String)] = []
    private var whipSounds: [(name: String, ext: String)] = []

    private init() {
        setupAudioSession()
        discoverSounds()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func discoverSounds() {
        // Get all URLs from the main bundle
        guard let allURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) else {
            print("Could not access bundle resources")
            return
        }

        let supportedExtensions = ["mp3", "wav", "m4a", "aiff", "caf"]

        for url in allURLs {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension

            guard supportedExtensions.contains(fileExtension.lowercased()) else { continue }

            if fileName.lowercased().hasPrefix("horse") {
                horseSounds.append((name: fileName, ext: fileExtension))
            } else if fileName.lowercased().hasPrefix("whip") {
                whipSounds.append((name: fileName, ext: fileExtension))
            }
        }

        print("Discovered \(horseSounds.count) horse sounds: \(horseSounds)")
        print("Discovered \(whipSounds.count) whip sounds: \(whipSounds)")
    }

    func playRandomSound() {
        // Independently decide whether to play each type
        // 30% chance for horse (if not already playing)
        let shouldPlayHorse = Int.random(in: 0...100) < 5
        // 70% chance for whip
        let shouldPlayWhip = Int.random(in: 0...100) < 25

        if shouldPlayHorse && !isHorsePlaying {
            playRandomHorse()
        }

        if shouldPlayWhip {
            playRandomWhip()
        }
    }

    func playRandomHorse() {
        // Only play if no horse is currently playing
        guard !horseSounds.isEmpty else { return }

        guard let sound = horseSounds.randomElement(),
              let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("Failed to load horse sound")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            let delegate = HorsePlayerDelegate(manager: self)
            player.delegate = delegate
            horsePlayers.append(player)
            horseDelegates.append(delegate)
            isHorsePlaying = true
            player.play()
        } catch {
            print("Failed to play horse sound: \(error)")
        }
    }

    func playRandomWhip() {
        guard !whipSounds.isEmpty else { return }

        guard let sound = whipSounds.randomElement(),
              let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("Failed to load whip sound")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            let delegate = WhipPlayerDelegate(manager: self)
            player.delegate = delegate
            whipPlayers.append(player)
            whipDelegates.append(delegate)
            player.play()
        } catch {
            print("Failed to play whip sound: \(error)")
        }
    }

    fileprivate func horseDidFinish(_ player: AVAudioPlayer) {
        if let index = horsePlayers.firstIndex(of: player) {
            horsePlayers.remove(at: index)
            horseDelegates.remove(at: index)
        }
        isHorsePlaying = false
    }

    fileprivate func whipDidFinish(_ player: AVAudioPlayer) {
        if let index = whipPlayers.firstIndex(of: player) {
            whipPlayers.remove(at: index)
            whipDelegates.remove(at: index)
        }
    }
}

// Delegate classes to handle audio completion
private class HorsePlayerDelegate: NSObject, AVAudioPlayerDelegate {
    weak var manager: SoundManager?

    init(manager: SoundManager) {
        self.manager = manager
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        manager?.horseDidFinish(player)
    }
}

private class WhipPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    weak var manager: SoundManager?

    init(manager: SoundManager) {
        self.manager = manager
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        manager?.whipDidFinish(player)
    }
}
