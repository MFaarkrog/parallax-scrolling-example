//
//  ViewController.swift
//  Parallax-scrolling
//
//  Created by Morten Faarkrog on 7/11/17.
//  Copyright © 2017 MFaarkrog. All rights reserved.
//

import UIKit
import SnapKit
import Apply
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
  
  // MARK: - Views
  let contentView = UIView()
  let contentScrollView: UIScrollView = UIScrollView()
    .apply(isScrollEnabled: true)
    .apply(isPagingEnabled: true)
    .apply(bounces: false)
    .apply(showsScrollIndicator: false)
  
  fileprivate lazy var backgroundBlurEffectView: UIVisualEffectView = {
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    effectView.frame = self.view.frame
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return effectView
  }()
  
  lazy var backgroundImageScrollView: ParallaxableScrollView = {
    return ParallaxableScrollView(
      scrollFactor: 0.4,
      itemWidth: UIScreen.main.bounds.width*1.4,
      itemHeight: UIScreen.main.bounds.height,
      views: [UIImageView(image: UIImage(named: "background"))
        .apply(contentMode: .scaleAspectFill)],
      scrollObservable: self.contentScrollView.rx.contentOffset.asObservable()
    )
  }()
  
  lazy var imagesScrollView: ParallaxableScrollView = {
    let imageNames = self.viewModel.pages.map { $0.page.iconImageName }
    let viewItems = imageNames.map {
      UIImageView(image: UIImage(named: $0))
        .apply(contentMode: .center)
    }
    
    return ParallaxableScrollView(
      scrollFactor: 1,
      itemWidth: UIScreen.main.bounds.width,
      views: viewItems,
      scrollObservable: self.contentScrollView.rx.contentOffset.asObservable()
    )
  }()
  
  lazy var titlesScrollView: ParallaxableScrollView = {
    let titles = self.viewModel.pages.map { $0.page.title }
    let viewItems = titles.map {
      UILabel()
        .apply(text: $0)
        .apply(font: UIFont.boldSystemFont(ofSize: 26))
        .apply(textAlignment: .center)
        .apply(textColor: .white)
    }
    
    return ParallaxableScrollView(
      scrollFactor: 1.5,
      itemWidth: UIScreen.main.bounds.width,
      views: viewItems,
      scrollObservable: self.contentScrollView.rx.contentOffset.asObservable()
    )
  }()
  
  lazy var descriptionsScrollView: ParallaxableScrollView = {
    let descriptions = self.viewModel.pages.map { $0.page.description }
    let viewItems = descriptions.map { DescriptionView(text: $0, width: 300) }
    
    return ParallaxableScrollView(
      scrollFactor: 2,
      itemWidth: UIScreen.main.bounds.width,
      views: viewItems,
      scrollObservable: self.contentScrollView.rx.contentOffset.asObservable()
    )
  }()
  
  lazy var pageControl: UIPageControl = {
    return UIPageControl()
      .apply(currentPage: 0)
      .apply(numberOfPages: self.viewModel.pages.count)
  }()
  
  let nextButton: UIButton = UIButton(type: .system)
    .apply(title: "Let's get started!")
    .apply(titleFont: UIFont.boldSystemFont(ofSize: 20))
    .apply(titleColor: .white)
    .apply(backgroundColor: UIColor(red: 255/255.0, green: 47/255.0, blue: 82/255.0, alpha: 0.75))
  
  
  // MARK: - Properties
  internal let viewModel: OnboardingViewModel
  private let disposeBag = DisposeBag()
  
  
  // MARK: - Init & Deinit
  init(viewModel: OnboardingViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
    setupViews()
    setupEvents()
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:)") }
  
  deinit { print("[OnboardingViewController] Deinitialized 🔥") }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  
  // MARK: - Setup
  private func setupViews() {
    contentScrollView.addSubview(contentView)
    
    [backgroundImageScrollView, backgroundBlurEffectView, imagesScrollView, titlesScrollView, descriptionsScrollView, pageControl, contentScrollView, nextButton].forEach { self.view.addSubview($0) }
    constrainViews()
  }
  
  private func constrainViews() {
    contentScrollView.snp.makeConstraints { $0.edges.equalTo(view) }
    
    contentView.snp.makeConstraints { (make) in
      make.edges.equalTo(contentScrollView)
      make.height.equalTo(view)
      make.width.equalTo(UIScreen.main.bounds.width * CGFloat(viewModel.pages.count))
    }
    
    backgroundImageScrollView.snp.makeConstraints { $0.edges.equalTo(view) }
    
    imagesScrollView.snp.makeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(titlesScrollView.snp.top).offset(-30)
      make.height.equalTo(75)
    }
    
    titlesScrollView.snp.makeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.centerY.equalTo(view).offset(-50)
      make.height.equalTo(30)
    }
    
    descriptionsScrollView.snp.makeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.top.equalTo(titlesScrollView.snp.bottom).offset(20)
      make.height.greaterThanOrEqualTo(100)
    }
    
    nextButton.transform = CGAffineTransform(translationX: 0, y: 60)
    nextButton.snp.makeConstraints { (make) in
      make.height.equalTo(60)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view)
    }
    
    pageControl.snp.makeConstraints { (make) in
      make.bottom.equalTo(nextButton.snp.top).offset(-8)
      make.centerX.equalTo(view)
    }
  }

  private func setupEvents() {
    contentScrollView.rx.contentOffset.asDriver()
      .map(currentPage)
      .map(isLastPage)
      .drive(onNext: { [weak self] isLastPage in
        guard let strongSelf = self else { return }
        UIView.animate(withDuration: 0.5, animations: {
          strongSelf.nextButton.transform = isLastPage ?
            CGAffineTransform.identity :
            CGAffineTransform(translationX: 0, y: 60)
        })
      })
      .disposed(by: disposeBag)
    
    contentScrollView.rx.contentOffset.asDriver()
      .map(currentPage)
      .map { $0 - 1 }
      .drive(pageControl.rx.currentPage)
      .disposed(by: disposeBag)
  }
  
  private func currentPage(forOffset offset: CGPoint) -> Int {
    let numberOfPages = CGFloat(viewModel.pages.count)
    let pageWidth = UIScreen.main.bounds.width
    let totalWidth = pageWidth * numberOfPages
    let page = 1 + Int(numberOfPages * offset.x / (totalWidth - pageWidth/2))
    return page
  }
  
  private func isLastPage(page: Int) -> Bool {
    return page == viewModel.pages.count
  }
  
}
