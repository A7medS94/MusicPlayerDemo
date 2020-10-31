//
//  Song.swift
//  MusicPlayer
//
//  Created by Ahmed Samir on 10/31/20.
//

import Foundation

class Song: NSObject{
    
    var songName: String!
    var songURL: String!
    
    init(songName: String, songURL: String) {
        super.init()
        self.songName = songName
        self.songURL = songURL
    }
}
