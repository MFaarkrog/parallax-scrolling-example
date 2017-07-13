//
//  File.swift
//  Parallax-scrolling
//
//  Created by Morten Faarkrog on 7/13/17.
//  Copyright © 2017 MFaarkrog. All rights reserved.
//

enum OnboardingPage {
  case welcome, about, praise, next
  
  var title: String {
    switch self {
    case .welcome: return "Welcome to XYZ!"
    case .about:   return "Parallax Scrolling"
    case .praise:  return "It's Pretty Cool"
    case .next:    return "What's next?"
    }
  }
  
  var description: String {
    switch self {
    case .welcome: return "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    case .about:   return "Quis non odit sordidos, vanos, leves, futtiles?"
    case .praise:  return "Quae tamen a te agetur non melior, quam illae sunt, quas interdum optines."
    case .next:    return "Philosophi autem in suis lectulis plerumque moriuntur. Duo Reges: constructio interrete. Et nemo nimium beatus est!"
    }
  }
  
  var iconImageName: String {
    switch self {
    case .welcome: return "img1"
    case .about:   return "img2"
    case .praise:  return "img3"
    case .next:    return "img1"
    }
  }
}
