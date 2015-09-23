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
    
    //TODO: Clean Code, add system sound to audioPlayer class
//    var audioSession: AVAudioSession {
////        return AVAudioSession.sharedInstance()
////    }
////    
////    var backgroundMusicPlayer: AVAudioPlayer?
////
////    override init() {
////        super.init()
////            if audioSession.otherAudioPlaying {
////                do {
////                    try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
////                    backgroundMusicPlaying = false
////                } catch let error as NSError {
////                    NSLog(error.localizedDescription)
////                }
////            } else {
////                do {
////                    try audioSession.setCategory(AVAudioSessionCategoryAmbient)
////                } catch let error as NSError {
////                    NSLog(error.localizedDescription)
////                }
////            }
////        
////        
////        if let backgroundMusicPath = NSBundle.mainBundle().pathForResource("ambientMusic", ofType: "mp3") {
////            let backbroundMusicURL = NSURL(fileURLWithPath: backgroundMusicPath)
////            do {
////                self.backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: backbroundMusicURL)
////                self.backgroundMusicPlayer?.delegate = self
////                self.backgroundMusicPlayer?.numberOfLoops = -1
////                
////            } catch let error as NSError {
////                NSLog(error.localizedDescription)
////            }
////            
////        }
////        
////    }
//    }

    
    private lazy var audioSession: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        if session.otherAudioPlaying {
            do {
                try session.setCategory(AVAudioSessionCategorySoloAmbient)
                //backgroundMusicPlaying = false
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
        
        if let backgroundMusicPath = NSBundle.mainBundle().pathForResource("ambientMusic", ofType: "mp3") {
            let backbroundMusicURL = NSURL(fileURLWithPath: backgroundMusicPath)
            do {
                let player = try AVAudioPlayer(contentsOfURL: backbroundMusicURL)
                player.delegate = self
                player.numberOfLoops = -1
                return player
                
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }

        }
        return nil
    }()
    
    var backgroundMusicPlaying: Bool = false
    var backgroundMusicInterrupted: Bool = false
    
    func tryToPlayMusic() {
        if backgroundMusicPlaying || backgroundMusicInterrupted {
            return
        }
        if let backgroundMusicPlayer = backgroundMusicPlayer {
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
            backgroundMusicPlaying = true
        }

    }
//    
//    private func configureAudioSession () {
//        
//        if audioSession.otherAudioPlaying {
//            do {
//                try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
//                backgroundMusicPlaying = false
//            } catch let error as NSError {
//                NSLog(error.localizedDescription)
//            }
//        } else {
//            do {
//                try audioSession.setCategory(AVAudioSessionCategoryAmbient)
//            } catch let error as NSError {
//                NSLog(error.localizedDescription)
//            }
//        }
//    }
    
    //MARK: AVAudioPlayerDelegate
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        backgroundMusicInterrupted = true
        backgroundMusicPlaying = true
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
        tryToPlayMusic()
        backgroundMusicInterrupted = false
    }

}
