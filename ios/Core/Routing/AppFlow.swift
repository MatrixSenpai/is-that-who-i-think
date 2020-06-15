//
//  AppFlow.swift
//  ios
//
//  Created by Mason Phillips on 6/10/20.
//

import UIKit
import RxCocoa
import RxFlow
import RxSwift
import libtmdb

class AppFlow: Flow {
    var root: Presentable {
        return rootViewController
    }
    
    let stepper = AppStepper()
    let api = API(API_KEY)
    
    private let rootViewController = UINavigationController()
    
    init() {
        
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .search: return toSearch()
            
        case .movieDetails(let id) : return toMovieDetails(id)
            
        case .showDetails(let id)  : return toShowDetails(id)
        case .episodes(let tv, let season): return showSeasons(tv, season: season)
        case .episodeDetails(let tv, let season, let episode): return showEpisodes(tv, season: season, episode: episode)
            
        case .personDetails(let id): return toPersonDetails(id)
            
        case .detailsDone: return detailsDone()
            
        default: return .none
        }
    }
    
    private func toSearch() -> FlowContributors {
        let controller = SearchViewController()
        controller.model.stepper = stepper
        controller.model.api = api
        rootViewController.setViewControllers([controller], animated: false)
        
        return .none
    }
    
    private func toMovieDetails(_ id: Int) -> FlowContributors {
        let controller = MovieViewController()
        controller.model.stepper = stepper
        controller.model.api = api
        
        controller.model.details(for: id)
        
        rootViewController.pushViewController(controller, animated: true)
        return .none
    }
    
    private func toShowDetails(_ id: Int) -> FlowContributors {
        let controller = TVShowViewController()
        controller.model.stepper = stepper
        controller.model.api = api
        
        controller.model.details(for: id)
        
        rootViewController.pushViewController(controller, animated: true)
        return .none
    }
    private func showSeasons(_ id: Int, season: Int) -> FlowContributors {
        let controller = BySeasonController()
        controller.model.stepper = stepper
        controller.model.api = api
        
        controller.model.details(id, season: season)
        
        rootViewController.pushViewController(controller, animated: true)
        return .none
    }
    private func showEpisodes(_ id: Int, season: Int, episode: Int) -> FlowContributors {
        let controller = EpisodeDetailController()
        controller.model.stepper = stepper
        controller.model.api = api
        
        controller.model.details(id, season: season, episode: episode)
        
        rootViewController.pushViewController(controller, animated: true)
        return .none
    }
    
    private func toPersonDetails(_ id: Int) -> FlowContributors {
        let controller = PersonViewController()
        controller.model.stepper = stepper
        controller.model.api = api
        
        controller.model.details(id)
        
        rootViewController.pushViewController(controller, animated: true)
        return .none
    }
    
    private func detailsDone() -> FlowContributors {
        rootViewController.popViewController(animated: true)
        return .none
    }
}

struct AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    var initialStep: Step = AppStep.search
    
    func readyToEmitSteps() {
        steps.accept(initialStep)
    }
}
