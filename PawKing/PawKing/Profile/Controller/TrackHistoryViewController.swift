//
//  TrackHistoryViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/21.
//

import UIKit
import MapKit
import SwiftUI

class TrackHistoryViewController: UIViewController {
    
    private let mapManager = MapManager.shared
    
    private let pet: Pet
    
    private let trackInfo: TrackInfo
    
    private var shouldEdit: Bool
    
    private let petNameLabel = UILabel()
    
    private let petImageView = UIImageView()
    
    private let settingButton = UIButton()
    
    private let mapView = MKMapView()
    
    private let timeTitleLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let distanceTitleLabel = UILabel()
    
    private let distanceLabel = UILabel()
    
    private let noteTitleLabel = UILabel()
    
    private let noteTextView = InputTextView()
    
    private let updateButton = UIButton()
    
    init(pet: Pet, trackInfo: TrackInfo, shouldEdit: Bool) {
        
//        self.petName = petName
//        
//        self.petImageURL = petImageURL
        
        self.pet = pet
        
        self.trackInfo = trackInfo
        
        self.shouldEdit = shouldEdit
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        navigationItem.title = "\(trackInfo.startTime.dateValue().displayTimeInNormalStyle())"
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        petNameLabel.text = pet.name
        
        noteTextView.delegate = self
        
        if shouldEdit {
            
            noteTextView.placeholder = "Write anything worthwhile..."
            
            updateButton.setTitle("Add Note", for: .normal)
            updateButton.isHidden = false
            settingButton.isHidden = true
            
        } else {
            
            if trackInfo.note == "" {
                
                noteTextView.placeholder = "None"
            } else {
                
                noteTextView.text = trackInfo.note
            }
            
            updateButton.isHidden = true
            updateButton.setTitle("Update Note", for: .normal)
        }
        updateButton.addTarget(self, action: #selector(didTapUpdateNote), for: .touchUpInside)
        
        timeTitleLabel.text = "Time"
        timeTitleLabel.textColor = .DarkBlue
        timeTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let startTime = trackInfo.startTime.dateValue()
        let endTime = trackInfo.endTime.dateValue()
        let durationString = endTime.displayTimeInCounterStyle(since: startTime)
        timeLabel.text = durationString
        timeLabel.textColor = .Orange1
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        distanceTitleLabel.text = "Distance"
        distanceTitleLabel.textColor = .DarkBlue
        distanceTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        distanceLabel.text = "\(String(format: "%.2f", trackInfo.distanceMeter / 1000)) km"
        distanceLabel.textColor = .Orange1
        distanceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        noteTitleLabel.text = "Note:"
        noteTitleLabel.textColor = .DarkBlue
        noteTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let location = trackInfo.track[0].transferToCoordinate2D()
        
        let region = MKCoordinateRegion(center: location,
                                        span: .init(latitudeDelta: 0.005,
                                                    longitudeDelta: 0.005))
        
        mapView.setRegion(region, animated: false)
        
        mapView.delegate = self
        
        drawTrack()
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        petImageView.contentMode = .scaleAspectFill
        
        petNameLabel.textColor = .DarkBlue
        petNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = .DarkBlue
        
        noteTextView.textColor = .DarkBlue
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.backgroundColor = .Orange1
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        updateButton.layer.cornerRadius = 4
    }
    
    func layout() {
        
        let hStack = UIStackView(arrangedSubviews: [petImageView, petNameLabel, settingButton])
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 15
        
        petImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        settingButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let timeVStack = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
        
        timeVStack.axis = .vertical
        timeVStack.distribution = .fill
        timeVStack.spacing = 3
        
        let distanceVStack = UIStackView(arrangedSubviews: [distanceTitleLabel, distanceLabel])
        
        distanceVStack.axis = .vertical
        distanceVStack.distribution = .fill
        distanceVStack.spacing = 3

        let infoHStack = UIStackView(arrangedSubviews: [timeVStack, distanceVStack])
        
        infoHStack.axis = .horizontal
        infoHStack.distribution = .equalCentering
        infoHStack.spacing = 10
        infoHStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30)
        infoHStack.isLayoutMarginsRelativeArrangement = true
        infoHStack.backgroundColor = .white
        
        infoHStack.layer.cornerRadius = 20
        infoHStack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        infoHStack.layer.shadowColor = UIColor.darkGray.cgColor
        infoHStack.layer.shadowOffset = CGSize(width: 0, height: -2)
        infoHStack.layer.shadowRadius = 1.5
        infoHStack.layer.shadowOpacity = 0.2
        infoHStack.layer.masksToBounds = false
        
        distanceVStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        view.addSubview(hStack)
        view.addSubview(mapView)
        view.addSubview(infoHStack)
        view.addSubview(noteTitleLabel)
        view.addSubview(noteTextView)
        view.addSubview(updateButton)
        
        petImageView.constrainWidth(constant: 40)
        petImageView.constrainHeight(constant: 40)
        
        hStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20))
        
        mapView.anchor(top: hStack.bottomAnchor,
                       leading: view.leadingAnchor,
                       trailing: view.trailingAnchor,
                       height: view.frame.width,
                            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        infoHStack.anchor(leading: mapView.leadingAnchor,
                          bottom: mapView.bottomAnchor,
                          trailing: mapView.trailingAnchor)
        
        noteTitleLabel.anchor(top: infoHStack.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        noteTextView.anchor(top: noteTitleLabel.bottomAnchor,
                         leading: mapView.leadingAnchor,
                         trailing: mapView.trailingAnchor,
                            padding: UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20))
        
        updateButton.anchor(top: noteTextView.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40))
        
        updateButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -50).isActive = true
        
        view.layoutIfNeeded()
        petImageView.makeRound()
        petImageView.clipsToBounds = true
    }
    
    @objc func didTapUpdateNote() {
        
        guard let trackNote = noteTextView.text else { return }
        
        updateButton.isEnabled = false
        updateButton.backgroundColor = .Gray1
        
        mapManager.updateTrackNote(userId: pet.ownerId, trackInfo: trackInfo, trackNote: trackNote) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func drawTrack() {
        
        let coordinates = trackInfo.track.map { $0.transferToCoordinate2D() }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        mapView.addOverlay(polyline, level: .aboveRoads)
    }
}

extension TrackHistoryViewController: MKMapViewDelegate, CLLocationManagerDelegate {

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//
//    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKPolyline {

            let polylineRenderer = MKPolylineRenderer(overlay: overlay)

            polylineRenderer.strokeColor = .Orange1

            polylineRenderer.lineWidth = 4

            return polylineRenderer

        } else {

            return MKPolylineRenderer()
        }
    }
}

extension TrackHistoryViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard textView == noteTextView,
              noteTextView.text != ""
        else {
            
            updateButton.isHidden = true
            return
        }
        
        updateButton.isHidden = false
    }
}
