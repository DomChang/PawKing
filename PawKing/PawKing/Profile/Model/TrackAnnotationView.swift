//
//  TrackAnnotationView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/7.
//

import Foundation
import MapKit

class TrackAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            update(for: annotation)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        update(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func update(for annotation: MKAnnotation?) {
        guard let annotation = annotation as? TrackAnnotation else { return }
        
        if annotation.title == "Start" {
            
            markerTintColor = .systemGreen
        } else {
            
            markerTintColor = .Orange1
        }
    }
}
