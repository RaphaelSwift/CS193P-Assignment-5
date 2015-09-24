//
//  AudioPlayer.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 23.09.15.
//  Copyright © 2015 Raphael Neuenschwander. All rights reserved.
//

import Foundation
import AVFoundation


class AudioPlayer: NSObject, AVAudioPlayerDelegate
{
    
    private var backgroundMusicPlaying: Bool = false
    private var backgroundMusicInterrupted: Bool = false
    private var hitBrickSound: SystemSoundID = 0
    
    private lazy var audioSession: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        if session.otherAudioPlaying { //Mix sound effects with audio already playing
            do {
                try session.setCategory(AVAudioSessionCategorySoloAmbient)
                self.backgroundMusicPlaying = false
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        } else {
            do {
                try session.setCategory(AVAudioSessionCategoryAmbient)
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        }
        return session
        }()
    
    private lazy var backgroundMusicPlayer: AVAudioPlayer? = {
        // Create audio player with background music
        if let backgroundMusicPath = NSBundle.mainBundle().pathForResource(SoundPath.AmbientMusic, ofType: SoundPath.AmbientMusicType) {
            let backbroundMusicURL = NSURL(fileURLWithPath: backgroundMusicPath)
            do {
                let player = try AVAudioPlayer(contentsOfURL: backbroundMusicURL)
                player.delegate = self // We need this so we can restart after interruptions
                player.numberOfLoops = -1 // Negative number means loop forever
                return player
                
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        }
        return nil
        }()
    
    override init() {
        super.init()
        configureSystemSound()
    }
    
    func tryToPlayMusic() {
        if backgroundMusicPlaying || audioSession.otherAudioPlaying {
            return
        }
        // Play background music if no other music is playing and we aren't playing already
        if let backgroundMusicPlayer = backgroundMusicPlayer {
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
            backgroundMusicPlaying = true
        }
    }
    
    func stopPlayingMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func playHitBrickSystemSound() {
        AudioServicesPlaySystemSound(hitBrickSound)
    }
    
    //MARK: - Private Implementation
    
    private func configureSystemSound() {
        if let hitSoundPath = NSBundle.mainBundle().pathForResource(SoundPath.HitBrickSound, ofType: SoundPath.HitBrickSoundType) {
            let hitSoundURL = NSURL(fileURLWithPath: hitSoundPath)
            AudioServicesCreateSystemSoundID(hitSoundURL, &hitBrickSound)
        }
    }
    
    //MARK: - AVAudioPlayerDelegate
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        backgroundMusicInterrupted = true
        backgroundMusicPlaying = true
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
        //Since this method is only called if music was previously interrupted
        //we know that the music has stopped playing and can now be resumed.
        tryToPlayMusic()
        backgroundMusicInterrupted = false
    }
    
    //MARK: - SoundPath Constants
    
    private struct SoundPath {
        static let AmbientMusic = "ambientMusic"
        static let AmbientMusicType = "mp3"
        static let HitBrickSound = "hit"
        static let HitBrickSoundType = "wav"
    }

}
