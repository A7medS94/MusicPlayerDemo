//
//  MusicPlayerVC.swift
//  MusicPlayer
//
//  Created by Ahmed Samir on 10/31/20.
//

import UIKit
import AVFoundation

class MusicPlayerVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var songsCollectionView: UICollectionView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var songCurrentTime: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    
    //MARK: - Vars
    var player: AVAudioPlayer?
    var songs: [Song]?
    var currentSong: Int = 0
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.songs = [Song(songName: "Dance Monkey", songURL: "DanceMonkey"),
                      Song(songName: "Ferrari", songURL: "Ferrari"),
                      Song(songName: "Hello", songURL: "Hello"),
                      Song(songName: "On My Way", songURL: "OnMyWay")]
        self.collectionViewConfig()
        
        let url = Bundle.main.path(forResource: self.songs?[0].songURL, ofType: "mp3")
        self.songName.text = self.songs?[0].songName
        self.musicHandler(with: URL(string: url!)!, startPlay: false)
    }
    
    
    //MARK: - Methods
    private func collectionViewConfig(){
        
        self.songsCollectionView.register(UINib(nibName: "SongCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SongCollectionViewCell")
        self.songsCollectionView.dataSource = self
        self.songsCollectionView.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 250, height: 250)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        self.songsCollectionView.collectionViewLayout = layout
        
        self.songsCollectionView.reloadData()
    }
    
    private func musicHandler(with url: URL, startPlay: Bool = false){
        
        do{
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.delegate = self
            self.player?.prepareToPlay()
            
            self.songDuration.text = self.timeFormat(interval: self.player!.duration) as String
            
            if startPlay{
                self.player?.play()
                self.playBtn.setImage(#imageLiteral(resourceName: "pauseSong"), for: .normal)
                self.updateMusicTime()
            }
            
            let session = AVAudioSession.sharedInstance()
            
            do{
                try session.setMode(.default)
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                try session.setCategory(.playback)
            }catch{
                print("error")
            }
        }catch{
            print("error")
        }
    }
    
    private func updateMusicTime(){
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(didUpdateTime), userInfo: nil, repeats: true)
        if let player = self.player{
            self.durationSlider.maximumValue = Float(player.duration)
            self.songDuration.text = self.timeFormat(interval: player.duration) as String
        }
    }
    
    @objc private func didUpdateTime(){
        
        if let player = self.player{
            self.durationSlider.value = Float(player.currentTime)
            self.songCurrentTime.text = self.timeFormat(interval: TimeInterval(self.durationSlider.value)) as String
        }
    }
    
    private func timeFormat(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        let second = ti % 60
        let minutes = (ti / 60) % 60
        return NSString(format: "%0.2d:%0.2d", minutes,second)
    }
    
    //MARK: - Actions
    @IBAction func playBtnDidTapped(_ sender: Any) {
        
        if let isPlaying = self.player?.isPlaying{
            if isPlaying == true{
                self.player?.pause()
                self.playBtn.setImage(#imageLiteral(resourceName: "playSong"), for: .normal)
                self.updateMusicTime()
            }else{
                self.player?.play()
                self.playBtn.setImage(#imageLiteral(resourceName: "pauseSong"), for: .normal)
                self.updateMusicTime()
            }
        }else{
            self.player?.stop()
        }
    }
    
    @IBAction func durationSliderDidChanged(_ sender: Any) {
        
        if let player = self.player{
            if player.isPlaying{
                player.stop()
                player.currentTime = TimeInterval(self.durationSlider.value)
                player.play()
            }else{
                player.currentTime = TimeInterval(self.durationSlider.value)
            }
        }
    }
    
    @IBAction func nextSongDidTaped(_ sender: Any) {
        
        if self.currentSong < (self.songs!.count - 1){
            self.currentSong = self.currentSong + 1
            self.songsCollectionView.scrollToItem(at: IndexPath(item: self.currentSong, section: 0), at: .right, animated: true)
            let url = Bundle.main.path(forResource: self.songs?[self.currentSong].songURL, ofType: "mp3")
            self.songName.text = self.songs?[self.currentSong].songName
            self.musicHandler(with: URL(string: url!)!, startPlay: true)
        }
    }
    
    @IBAction func preSongDidTapped(_ sender: Any) {
        
        if self.currentSong > 0{
            self.currentSong = self.currentSong - 1
            self.songsCollectionView.scrollToItem(at: IndexPath(item: self.currentSong, section: 0), at: .left, animated: true)
            let url = Bundle.main.path(forResource: self.songs?[self.currentSong].songURL, ofType: "mp3")
            self.songName.text = self.songs?[self.currentSong].songName
            self.musicHandler(with: URL(string: url!)!, startPlay: true)
        }
    }
}


//MARK: - CollectionView DataSource
extension MusicPlayerVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.songs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: SongCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCollectionViewCell", for: indexPath) as? SongCollectionViewCell else {return UICollectionViewCell()}
        
        cell.songImage.image = UIImage(named: (self.songs?[indexPath.row].songURL)!)
        
        return cell
    }
}


//MARK: - CollectionView Delegate
extension MusicPlayerVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round((scrollView.contentOffset.x) / scrollView.frame.size.width)
        self.currentSong = Int(pageNumber)
        let url = Bundle.main.path(forResource: self.songs?[self.currentSong].songURL, ofType: "mp3")
        self.songName.text = self.songs?[self.currentSong].songName
        self.musicHandler(with: URL(string: url!)!, startPlay: true)
    }
}

extension MusicPlayerVC: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playBtn.setImage(#imageLiteral(resourceName: "playSong"), for: .normal)
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        
    }
}
