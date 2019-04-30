//
//  DeezerPlayerViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import LNPopupController

class DeezerPlayerViewController: UIViewController {

    @IBOutlet weak var imageTrack: UIImageView!
    @IBOutlet weak var titleTrack: UILabel!
    @IBOutlet weak var artistTrack: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var bufferSlider: UISlider!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    @IBOutlet private weak var shuffleButton: UIButton!
    @IBOutlet private weak var repeatButton: UIButton!

    private lazy var player: DZRPlayer? = {
        guard let deezerConnect = DeezerManager.sharedInstance.deezerConnect,
            var _player = DZRPlayer(connection: deezerConnect) else {
                return nil
        }
        _player.networkType = .wifiAnd3G
        _player.repeatMode = .none
        _player.shouldUpdateNowPlayingInfo = true
        _player.delegate = self
        return _player
    }()

    private var playable: DZRPlayable?
    private var currentIndex: Int = 0
    private var voteController: VoteController?

    private var isPlayerSliderEditing = false
    private var isConformToRandomAcces: Bool {
        guard let playable = playable, let iterator = playable.iterator() as? NSObject else {
            return false
        }
        return iterator.conforms(to: DZRPlayableRandomAccessIterator.self)
    }

    private var popupPauseButton = UIBarButtonItem()
    private var popupVoteButton = UIBarButtonItem()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        popupPauseButton = UIBarButtonItem(image: UIImage(named: "pause-iconset"), style: .plain, target: self, action: #selector(self.playPause))
        popupVoteButton = UIBarButtonItem(image: UIImage(named: "heart-outline"), style: .plain, target: self, action: #selector(self.vote))
        popupItem.rightBarButtonItems = [popupPauseButton]
    }

    func configure(playable: DZRPlayable, currentIndex: Int = 0, voteController: VoteController?) {
        self.playable = playable
        self.currentIndex = currentIndex
        self.voteController = voteController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        guard let playable = playable, let player = player else {
            return
        }

        player.play(playable, at: currentIndex)
    }

    // MARK: - Setup UI

    private func setupUI() {
        playPauseButton.imageView?.contentMode = .scaleToFill
        shuffleButton.setImage(#imageLiteral(resourceName: "shuffle-icon"), for: .normal)
        shuffleButton.isHidden = !isConformToRandomAcces
        repeatButton.isHidden = !isConformToRandomAcces
        setupSliders()
    }

    private func updatePlayPauseButton() {
        guard let player = player else {
            return
        }

        nextButton.isEnabled = player.isReady()
        previousButton.isEnabled = player.isReady()
        playPauseButton.setImage(player.isPlaying() ? #imageLiteral(resourceName: "pause-icon") : #imageLiteral(resourceName: "play-icon") , for: .normal)
    }

    private func clearUI() {
        artistTrack.text = ""
        titleTrack.text = ""
        imageTrack.image = nil
        clearElapseView()
    }

    private func setup(track: DZRTrack) {
        clearUI()

        if let voteController = voteController {
            let isVoted = voteController.trackIsVoted(track: track)
            popupVoteButton.image = UIImage(named: isVoted ? "heart-filled" : "heart-outline")
            popupItem.leftBarButtonItems = [popupVoteButton]
        } else {
            popupItem.leftBarButtonItems = []
        }

        DeezerManager.sharedInstance.getData(track: track) {[weak self] (data, error) in
            guard let data = data, let strongSelf = self else {
                if let error = error {
                    UIViewController.present(title: "Failed to get deezer data", error: error)
                }
                return
            }
            if let artist = data[DZRPlayableObjectInfoCreator] as? String {
                strongSelf.artistTrack.text = artist
                strongSelf.popupItem.subtitle = artist
            }

            if let title = data[DZRPlayableObjectInfoName] as? String {
                strongSelf.titleTrack.text = title
                strongSelf.popupItem.title = title
            }
        }

        DeezerManager.sharedInstance.getIllustration(track: track) {[weak self] (image, error) in
            guard let image = image, let strongSelf = self else {
                if let error = error {
                    UIViewController.present(title: "Failed to get deezer illustration", error: error)
                }
                return
            }

            strongSelf.imageTrack.image = image
            strongSelf.popupItem.image = image
        }
    }

    private func setupDuration(progress: Float) {
        guard let player = player, progress != -1 else {
            durationLabel.text = "--:--"
            elapsedTimeLabel.text = "--:--"
            return
        }

        let currentDuration = Float(player.currentTrackDuration)
        let currentDurationString = getTimeStringFromSeconds(seconds: UInt32(currentDuration * progress))
        let trackDurationString = getTimeStringFromSeconds(seconds: UInt32(player.currentTrackDuration))
        durationLabel.text = currentDurationString
        elapsedTimeLabel.text = trackDurationString
    }

    private func setupSliderValue(progress: Float) {
        playerSlider.value = progress
        popupItem.progress = progress
    }

    // MARK: - Utils

    private func getTimeStringFromSeconds(seconds : UInt32) -> String {
        let minutes = seconds / 60;
        let currentSeconds = seconds - (minutes * 60)
        if currentSeconds < 10 {
            return "\(minutes):0\(currentSeconds)"
        }
        return "\(minutes):\(currentSeconds)"
    }

    // MARK: - Actions

    @objc private func vote() {
        guard let voteController = voteController,
            let track = player?.currentTrack else { return }
        voteController.voteTrack(track: track, onSuccess: { isVoted in
            self.popupVoteButton.image = UIImage(named: isVoted ? "heart-filled" : "heart-outline")
        })
    }

    @IBAction private func playPause() {
        guard let player = player else {
            return
        }

        if player.isPlaying() {
            player.pause()
            popupPauseButton.image = UIImage(named: "play-iconset")
        } else {
            player.play()
            popupPauseButton.image = UIImage(named: "pause-iconset")
        }
    }

    @IBAction private func next() {
        player?.next()
    }

    @IBAction private func previous() {
        player?.previous()
    }

    @IBAction private func shuffleMode() {
        guard let player = player else {
            return
        }

        player.toggleShuffleMode()
        shuffleButton.tintColor = player.shuffleMode ? .init(red: 28.0 / 255.0, green: 176.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0) : .black
    }

    @IBAction private func repeatMode() {
        guard let player = player else {
            return
        }

        player.updateRepeatMode(DZRPlaybackRepeatMode(rawValue: (player.repeatMode.rawValue + 1) % 3)!)
        let image: UIImage
        switch player.repeatMode {
        case .allTracks:
            image = #imageLiteral(resourceName: "repeat-icon")
            repeatButton.tintColor = .init(red: 28.0 / 255.0, green: 176.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        case .currentTrack:
            image = #imageLiteral(resourceName: "repeat-one-icon")
            repeatButton.tintColor = .init(red: 28.0 / 255.0, green: 176.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        default:
            image = #imageLiteral(resourceName: "repeat-icon")
            repeatButton.tintColor = .black
        }
        repeatButton.setImage(image, for: .normal)
    }

    // MARK: - Remote Control

    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            switch event.subtype {
            case .remoteControlPlay:
                player?.play()

            case .remoteControlPause:
                player?.pause()

            case .remoteControlNextTrack:
                player?.next()

            case .remoteControlPreviousTrack:
                player?.previous()

            default: ()
            }
        }
    }
}

// MARK: - DZRPlayerDelegate

extension DeezerPlayerViewController: DZRPlayerDelegate {

    func playerDidPause(_ player: DZRPlayer!) {
        updatePlayPauseButton()
    }

    func player(_ player: DZRPlayer!, didEncounterError error: Error!) {
        UIViewController.present(title: "Player error", error: error)
        clearUI()
        updatePlayPauseButton()
    }

    func player(_ player: DZRPlayer!, didStartPlaying track: DZRTrack!) {
        guard let track = track else { return }

        setup(track: track)
        updatePlayPauseButton()
    }

    func player(_ player: DZRPlayer!, didPlay playedBytes: Int64, outOf totalBytes: Int64) {
        if playedBytes == totalBytes {
            player?.next()
            return
        }

        if !isPlayerSliderEditing {
            var progress: Float = -1
            if totalBytes != 0 {
                progress = Float(playedBytes) / Float(totalBytes)
            }
            setupDuration(progress: progress)
            setupSliderValue(progress: progress)
        }
        updatePlayPauseButton()
    }

    func player(_ player: DZRPlayer!, didBuffer bufferedBytes: Int64, outOf totalBytes: Int64) {
        let progress = Float(bufferedBytes) / Float(totalBytes)
        bufferSlider.value = progress
    }
}

// MARK: - Slider & Duration

extension DeezerPlayerViewController {

    private func setupSliders() {
        let transparentImage = #imageLiteral(resourceName: "transparentImage")

        let bufferMinimumTrackImage = #imageLiteral(resourceName: "Player_ProgressSlider_DownloadProgress").stretchableImage(withLeftCapWidth: 3, topCapHeight: 0)
        bufferSlider.setMinimumTrackImage(bufferMinimumTrackImage, for: .normal)
        let bufferMaximumTrackImage = #imageLiteral(resourceName: "Player_ProgressSlider_Background").stretchableImage(withLeftCapWidth: 3, topCapHeight: 0)
        bufferSlider.setMaximumTrackImage(bufferMaximumTrackImage, for: .normal)
        bufferSlider.setThumbImage(transparentImage, for: .normal)
        bufferSlider.isContinuous = false

        let playerMinimumTrackImage = #imageLiteral(resourceName: "Player_ProgressSlider_PlayProgress").stretchableImage(withLeftCapWidth: 3, topCapHeight: 0)
        playerSlider.setMinimumTrackImage(playerMinimumTrackImage, for: .normal)
        playerSlider.setMaximumTrackImage(transparentImage, for: .normal)
        playerSlider.isContinuous = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(gestureRecognizer:)))
        playerSlider.addGestureRecognizer(tapGestureRecognizer)
        playerSlider.addTarget(self, action: #selector(onSliderValueChanged(slider:event:)), for: .valueChanged)
    }

    @objc private func onSliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isPlayerSliderEditing = true
            case .moved:
                setupDuration(progress: slider.value)
            case .ended:
                isPlayerSliderEditing = false
                guard let player = player else {
                    return
                }
                player.progress = Double(slider.value)
                player.play()
            default:
                break
            }
        }
    }

    @objc private func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        guard let player = player else {
            return
        }

        let pointTapped: CGPoint = gestureRecognizer.location(in: view)

        let positionOfSlider: CGPoint = playerSlider.frame.origin
        let widthOfSlider: CGFloat = playerSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(playerSlider.maximumValue) / widthOfSlider)

        playerSlider.setValue(Float(newValue), animated: true)

        player.progress = Double(playerSlider.value)
        player.play()
    }

    private func clearElapseView() {
        durationLabel.text = "--:--"
        elapsedTimeLabel.text = "--:--"
        bufferSlider.value = 0
        playerSlider.value = 0
        popupItem.progress = 0
    }

}
