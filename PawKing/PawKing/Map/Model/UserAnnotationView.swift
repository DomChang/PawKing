//
//  UserAnnotationView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/25.
//

import MapKit

class UserAnnotationView: MKAnnotationView {
    
    private let annotationFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
    
    private let label: UILabel

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        self.label = UILabel(frame: annotationFrame.offsetBy(dx: 0, dy: 25))
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = annotationFrame
        
        self.label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        self.label.textColor = .black
        
        self.label.textAlignment = .center
        
        self.label.text = annotation?.title ?? ""
        
        self.backgroundColor = .clear
        
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
}
