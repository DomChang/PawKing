//
//  UIImageView+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/25.
//

import UIKit.UIImageView
import Kingfisher

extension UIImageView {
    
    func download(url: String?, rounded: Bool = true) {
        
        guard let url = url else {
            return
        }
        if rounded {
            let processor = RoundCornerImageProcessor(cornerRadius: self.frame.size.width / 2)
            self.kf.setImage(with: URL(string: url), placeholder: nil, options: [.processor(processor)])
        } else {
            self.kf.setImage(with: URL(string: url))
        }
    }
}
