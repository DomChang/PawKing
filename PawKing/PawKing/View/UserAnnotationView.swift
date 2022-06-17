//
//  PKAnnotationView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import MapKit

class UserAnnotationView: MKAnnotationView {

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
  
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        guard let annotation = self.annotation as? UserAnnotation else {
            return
        }
    }
}
