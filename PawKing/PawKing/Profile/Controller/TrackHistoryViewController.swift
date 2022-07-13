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
    
    private let lottie = LottieWrapper.shared
    
    private let pet: Pet
    
    private var trackInfo: TrackInfo
    
    private let scrollView = UIScrollView()
    
    private var isNew: Bool
    
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
    
    private let abortButton = UIButton()
    
    private let deleteActionController = UIAlertController(title: nil,
                                                           message: nil,
                                                           preferredStyle: .actionSheet)
    
    private let abortActionController = UIAlertController(title: "Abort Track",
                                                          message: "Are you sure you want to abort track?",
                                                          preferredStyle: .alert)
    
    init(pet: Pet, trackInfo: TrackInfo, isNew: Bool) {
        
        self.pet = pet
        
        self.trackInfo = trackInfo
        
        self.isNew = isNew
        
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
    
    private func setup() {
        
        navigationItem.title = "\(trackInfo.startTime.dateValue().displayTimeInNormalStyle())"
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        petImageView.layer.borderWidth = 1
        petImageView.layer.borderColor = UIColor.white.cgColor
        
        petNameLabel.text = pet.name
        
        settingButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        noteTextView.delegate = self
        noteTextView.isScrollEnabled = false
        
        if isNew {
            
            navigationItem.setHidesBackButton(true, animated: true)
            
            noteTextView.placeholder = "Write anything worthwhile..."
            
            updateButton.setTitle("Save", for: .normal)
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
        
        abortButton.setTitle("Abort", for: .normal)
        
        updateButton.addTarget(self, action: #selector(didTapUpdateNote), for: .touchUpInside)
        abortButton.addTarget(self, action: #selector(didTapAbort), for: .touchUpInside)
        
        mapView.register(TrackAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        
        drawTrack()
        setAnnotation()
        
        setDeleteActionSheet()
        setAbortAlert()
    }
    
    private func style() {
        
        view.backgroundColor = .white
        
        petImageView.contentMode = .scaleAspectFill
        
        petNameLabel.textColor = .white
        petNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = .white
        
        noteTextView.textColor = .BattleGrey
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.backgroundColor = .Orange1
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        updateButton.layer.cornerRadius = 4
        
        abortButton.setTitleColor(.Orange1, for: .normal)
        abortButton.backgroundColor = .white
        abortButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        abortButton.layer.cornerRadius = 4
        abortButton.layer.borderColor = UIColor.Orange1?.cgColor
        abortButton.layer.borderWidth = 1
        
        timeTitleLabel.text = "Time"
        timeTitleLabel.textColor = .BattleGrey
        timeTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let startTime = trackInfo.startTime.dateValue()
        let endTime = trackInfo.endTime.dateValue()
        let durationString = endTime.displayTimeInCounterStyle(since: startTime)
        timeLabel.text = durationString
        timeLabel.textColor = .Orange1
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        distanceTitleLabel.text = "Distance"
        distanceTitleLabel.textColor = .BattleGrey
        distanceTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        distanceLabel.text = "\(String(format: "%.2f", trackInfo.distanceMeter / 1000)) km"
        distanceLabel.textColor = .Orange1
        distanceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        noteTitleLabel.text = "Note:"
        noteTitleLabel.textColor = .BattleGrey
        noteTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private func layout() {
        
        let hStack = UIStackView(arrangedSubviews: [petImageView, petNameLabel, settingButton])
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 15
        
        let hStackBackView = UIView()
        hStackBackView.backgroundColor = .BattleGrey
        
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
        
        distanceVStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view.addSubview(scrollView)
        scrollView.addSubview(hStackBackView)
        scrollView.addSubview(hStack)
        scrollView.addSubview(mapView)
        scrollView.addSubview(infoHStack)
        scrollView.addSubview(noteTitleLabel)
        scrollView.addSubview(noteTextView)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: view.bottomAnchor,
                          trailing: view.trailingAnchor)
        
        petImageView.constrainWidth(constant: 40)
        petImageView.constrainHeight(constant: 40)
        
        hStackBackView.anchor(top: scrollView.topAnchor,
                              leading: scrollView.leadingAnchor,
                              bottom: mapView.topAnchor,
                              trailing: scrollView.trailingAnchor)
        
        hStack.anchor(top: scrollView.topAnchor,
                            leading: scrollView.leadingAnchor,
                            trailing: scrollView.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20))
        
        mapView.anchor(top: hStack.bottomAnchor,
                       leading: scrollView.leadingAnchor,
                       trailing: scrollView.trailingAnchor,
                       height: view.frame.width,
                            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        mapView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor
        ).isActive = true
        
        infoHStack.anchor(leading: scrollView.leadingAnchor,
                          bottom: mapView.bottomAnchor,
                          trailing: scrollView.trailingAnchor)
        
        noteTitleLabel.anchor(top: infoHStack.bottomAnchor,
                              leading: scrollView.leadingAnchor,
                              trailing: scrollView.trailingAnchor,
                              padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        noteTextView.anchor(top: noteTitleLabel.bottomAnchor,
                         leading: scrollView.leadingAnchor,
                         trailing: scrollView.trailingAnchor,
                            padding: UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20))
        
        if isNew {
            
            let buttonHStack = UIStackView(arrangedSubviews: [abortButton, updateButton])
            buttonHStack.axis = .horizontal
            buttonHStack.distribution = .fillEqually
            buttonHStack.spacing = 40
            
            scrollView.addSubview(buttonHStack)
            
            buttonHStack.anchor(top: noteTextView.bottomAnchor,
                                leading: scrollView.leadingAnchor,
                                trailing: scrollView.trailingAnchor,
                                height: 40,
                                padding: UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40))
            
            buttonHStack.bottomAnchor.constraint(
                lessThanOrEqualTo: scrollView.bottomAnchor, constant: -50
            ).isActive = true
            
        } else {
            
            scrollView.addSubview(updateButton)
            
            updateButton.anchor(top: noteTextView.bottomAnchor,
                                leading: scrollView.leadingAnchor,
                                trailing: scrollView.trailingAnchor,
                                height: 40,
                                padding: UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40))
            
            updateButton.bottomAnchor.constraint(
                lessThanOrEqualTo: scrollView.bottomAnchor, constant: -50
            ).isActive = true
        }
        
        scrollView.layoutIfNeeded()
        petImageView.makeRound()
        petImageView.clipsToBounds = true
        
        let topView = UIView(frame: CGRect(x: 0, y: -scrollView.bounds.height,
                width: scrollView.bounds.width, height: scrollView.bounds.height))
        topView.backgroundColor = .BattleGrey
        scrollView.addSubview(topView)
    }
    
    @objc private func didTapUpdateNote() {
        
        lottie.startLoading()
        
        if isNew {
            
            addTrack()
            
        } else {
            
            updateNote()
        }
    }
    
    private func addTrack() {
        
        guard let user = UserManager.shared.currentUser else {
            
            lottie.stopLoading()
            return
        }
        
        mapManager.uploadTrack(userId: user.id, trackInfo: &trackInfo) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.lottie.stopLoading()
                
                NotificationCenter.default.post(name: .updateTrackHistory, object: .none)
                
                self?.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }
    }
    
    private func updateNote() {
        
        guard let trackNote = noteTextView.text else {
            
            lottie.stopLoading()
            return
        }
        
        updateButton.isEnabled = false
        updateButton.backgroundColor = .Gray1
        
        mapManager.updateTrackNote(userId: pet.ownerId,
                                   trackInfo: trackInfo,
                                   trackNote: trackNote) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.lottie.stopLoading()
                
                self?.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .updateUser, object: .none)
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }
    }
    
    @objc private func didTapAbort() {
        
        present(abortActionController, animated: true)
    }
    
    @objc private func didTapSetting() {
        
        present(deleteActionController, animated: true) {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            
            self.deleteActionController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func dismissAlertController() {
        
        deleteActionController.dismiss(animated: true)
    }
    
    private func setAbortAlert() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let abortAction  = UIAlertAction(title: "Abort", style: .destructive) { [weak self] _ in
            
            self?.navigationController?.popViewController(animated: true)
        }
        abortActionController.addAction(abortAction)
        abortActionController.addAction(cancelAction)
    }
    
    private func setDeleteActionSheet() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let deleteAlert  = UIAlertAction(title: "Delete Track", style: .destructive) { [weak self] _ in
            
            guard let self = self,
                  let userId = UserManager.shared.currentUser?.id
            else { return }
            
            self.lottie.startLoading()
            
            self.mapManager.deleteTrack(userId: userId,
                                        petId: self.trackInfo.petId,
                                        trackId: self.trackInfo.id) { result in
                switch result {
                    
                case .success:
                    
                    self.lottie.stopLoading()
                    
                    NotificationCenter.default.post(name: .updateUser, object: .none)
                    
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    
                    self.lottie.stopLoading()
                    
                    self.lottie.showError(error: error)
                }
            }
        }
        
        deleteActionController.addAction(deleteAlert)
        deleteActionController.addAction(cancelAction)
    }
    
    private func drawTrack() {
        
        let coordinates = trackInfo.track.map { $0.transferToCoordinate2D() }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        mapView.addOverlay(polyline, level: .aboveRoads)
        
        var regionRect = polyline.boundingMapRect

       let wPadding = regionRect.size.width * 0.8
       let hPadding = regionRect.size.height * 0.8

       // Add padding to the region
       regionRect.size.width += wPadding
       regionRect.size.height += hPadding

       // Center the region on the line
       regionRect.origin.x -= wPadding / 2
       regionRect.origin.y -= hPadding / 2

        mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
    }
    
    private func setAnnotation() {
        
        guard let startPoint = trackInfo.track.first,
                let endPoint = trackInfo.track.last else { return }
        
        let startAnnotation = TrackAnnotation(title: "Start", coordinate: startPoint.transferToCoordinate2D())
        
        let endAnnotation = TrackAnnotation(title: "End", coordinate: endPoint.transferToCoordinate2D())
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }
}

extension TrackHistoryViewController: MKMapViewDelegate, CLLocationManagerDelegate {

//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//         guard let view = mapView.dequeueReusableAnnotationView(
//            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
//            for: annotation
//         ) as? MKMarkerAnnotationView else {
//
//             return MKMarkerAnnotationView()
//         }
//
//        view.markerTintColor = .BattleGrey
//
//        return view
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
        
        guard textView == noteTextView
        else {
            return
        }
        
        updateButton.isHidden = false
    }
}
