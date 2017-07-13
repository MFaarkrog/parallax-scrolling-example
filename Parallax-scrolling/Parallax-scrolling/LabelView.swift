//
//  LabelView.swift
//  Parallax-scrolling
//
//  Created by Morten Faarkrog on 7/13/17.
//  Copyright © 2017 MFaarkrog. All rights reserved.
//

import UIKit

class DescriptionView: UIView {
  
  internal let label = UILabel()
    .apply(numberOfLines: 0)
    .apply(textAlignment: .center)
    .apply(textColor: .white)
    .apply(font: UIFont.systemFont(ofSize: 18))
  
  init(text: String, width: CGFloat) {
    super.init(frame: CGRect.zero)
    
    // Setup, add, and constrain
    label.text = text
    self.addSubview(label)
    
    label.snp.makeConstraints {
      $0.centerX.equalTo(self)
      $0.width.equalTo(width)
      $0.top.equalTo(self)
    }
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:)") }
  
}
