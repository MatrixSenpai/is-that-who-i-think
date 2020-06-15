//
//  AppStep.swift
//  ios
//
//  Created by Mason Phillips on 6/10/20.
//

import RxFlow

enum AppStep: Step {
    case search
    
    case movieDetails(id: Int)
    case showDetails(id: Int), episodes(tv: Int, season: Int), episodeDetails(tv: Int, season: Int, episode: Int)
    case personDetails(id: Int)
    
    case detailsDone
}
