//
//  OnboardingViewModel.swift
//  Parallax-scrolling
//
//  Created by Morten Faarkrog on 7/13/17.
//  Copyright © 2017 MFaarkrog. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct OnboardingPageViewModel {
  let page: OnboardingPage
}


struct OnboardingViewModel {
  
  internal let pages: [OnboardingPageViewModel] = [
    OnboardingPageViewModel(page: .welcome),
    OnboardingPageViewModel(page: .about),
    OnboardingPageViewModel(page: .praise),
    OnboardingPageViewModel(page: .next),
  ]
  
}
