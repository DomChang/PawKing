//
//  TrackHelper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TrackHelper {
    
    var trackTimer: Timer?

    var stopTimer: Timer?
    
    var trackStartTime = Timestamp()
    
    private var timerDuration: Int = 0
    
    func startTrack(user: User, mapVC: MapViewController, homeVC: HomeViewController) {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard !user.petsId.isEmpty else {

            homeVC.showNoPetAlert(message: "Cannot track without Pet. Going to add Pet.")
            return
        }
        
        guard mapVC.userCurrentPet != nil else {
            
            homeVC.showNoSelectPetAlert()
            return
        }
        
        guard mapVC.isLocationAuth() else {
            
            homeVC.showLocationAlert()
            return
        }
        
        homeVC.isTracking = true
        
        trackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            
            guard let self = self else { return }
            
            self.timerDuration += 1
            
            mapVC.trackDashboardView.timeLabel.text = TimeInterval(self.timerDuration).timeString()
        })
        
        homeVC.beTracking()
        
        mapVC.startUpdateLocation()

        trackStartTime = Timestamp(date: Date())
        
        mapVC.infoBottomAnchor.constant = homeVC.view.safeAreaInsets.top +
        mapVC.trackDashboardView.frame.height
        
        UIView.animate(withDuration: 1) {
            homeVC.view.layoutIfNeeded()
        }
    }
    
    func finishTrack(user: User, mapVC: MapViewController, homeVC: HomeViewController) {
        
        mapVC.focusUserLocation()

        let coordinate = mapVC.userStoredLocations.map { $0.coordinate }
        let track = coordinate.map { $0.transferToGeopoint() }
        
        guard let userCurrentPet = mapVC.userCurrentPet,
              !coordinate.isEmpty else {
            
            return
        }
        
        let distance = homeVC.locationHelper.computeDistance(from: track.map {
            $0.transferToCoordinate2D()
        })
        
        let trackInfo = TrackInfo(id: "",
                                  petId: userCurrentPet.id,
                                  distanceMeter: distance,
                                  startTime: trackStartTime,
                                  endTime: Timestamp(),
                                  track: track,
                                  note: "")
        
        let trackHistoryVC = TrackHistoryViewController(pet: userCurrentPet,
                                                        trackInfo: trackInfo,
                                                        isNew: true)
        
        resetTrack(user: user, mapVC: mapVC, homeVC: homeVC)
        
        stopTimer?.invalidate()
        stopTimer = nil
        
        homeVC.navigationController?.pushViewController(trackHistoryVC, animated: true)
    }
    
    func resetTrack(user: User, mapVC: MapViewController, homeVC: HomeViewController) {
        
        timerDuration = 0
        mapVC.trackDashboardView.timeLabel.text = "00:00:00"
        trackTimer?.invalidate()
        trackTimer = nil
        mapVC.distance = 0
        mapVC.trackDashboardView.distanceLabel.text = "0.00 km"
        homeVC.isTracking = false
        
        homeVC.notTracking()

        mapVC.stopUpdateLocation(user: user)
        mapVC.mapView.removeOverlays(mapVC.mapView.overlays)
        
        mapVC.infoBottomAnchor.constant = 0
    }
}
