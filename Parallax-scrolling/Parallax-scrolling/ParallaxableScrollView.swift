//
//  ParallaxableScrollView.swift
//  Parallax-scrolling
//
//  Created by Morten Faarkrog on 7/13/17.
//  Copyright © 2017 MFaarkrog. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ParallaxableScrollView: UIScrollView {
  
  // MARK: - Views
  private lazy var contentStackView: UIStackView = {
    return UIStackView(arrangedSubviews: self.viewItems)
      .apply(distribution: .fillEqually)
      .apply(axis: .horizontal)
  }()
  
  private let viewItems: [UIView]
  
  // MARK: - Properties
  private let scrollFactor: CGFloat
  private let itemWidth: CGFloat
  private let itemHeight: CGFloat?
  private var disposeBag = DisposeBag()
  
  // MARK: - Init & Setup
  init(scrollFactor: CGFloat, itemWidth: CGFloat, itemHeight: CGFloat? = nil, views: [UIView], scrollObservable: Observable<CGPoint>) {
    self.scrollFactor = scrollFactor
    self.itemWidth = itemWidth
    self.itemHeight = itemHeight
    self.viewItems = views
    
    super.init(frame: CGRect.zero)
    setupView()
    configure(scrollObservable: scrollObservable)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    self.apply(isScrollEnabled: false)
    self.apply(showsScrollIndicator: false)
    self.addSubview(contentStackView)
    constrainViews()
  }
  
  private func constrainViews() {
    contentStackView.snp.makeConstraints { (make) in
      make.top.equalTo(self)
      make.left.equalTo(self).offset(-(itemWidth * (scrollFactor-1) / 2))
      make.right.equalTo(self)
      make.bottom.equalTo(self)
      
      make.width.equalTo(itemWidth*CGFloat(viewItems.count)*scrollFactor)
      if let itemHeight = itemHeight {
        make.height.equalTo(itemHeight)
      }
    }
  }
  
  private func configure(scrollObservable: Observable<CGPoint>) {
    disposeBag = DisposeBag()
    
    scrollObservable.asDriver(onErrorJustReturn: CGPoint.zero)
      .map(getScaledOffset)
      .drive(self.rx.contentOffset)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helper
  private func getScaledOffset(for otherOffset: CGPoint) -> CGPoint {
    let totalWidth = itemWidth * CGFloat(self.viewItems.count)
    let percentage = otherOffset.x / totalWidth
    let updatedOffsetX = totalWidth * scrollFactor * percentage
    return CGPoint(x: updatedOffsetX, y: otherOffset.y)
  }
  
}
