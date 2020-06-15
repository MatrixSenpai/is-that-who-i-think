//
//  EpisodeCastCell.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import UIKit
import RxSwift
import Nuke

class EpisodeDetailCell: UITableViewCell {
    static let identifier: String = "castCell"
    
    let icon = UIImageView()
    
    let actorLabel = UILabel()
    let characterLabel = UILabel()
    
    let bag = DisposeBag()

    var item: EpisodeDetailSection.Types?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            
        icon.contentMode = .scaleAspectFill
        contentView.addSubview(icon)
                
        actorLabel.font = .systemFont(ofSize: 21)
        contentView.addSubview(actorLabel)
                
        characterLabel.font = .italicSystemFont(ofSize: 17)
        contentView.addSubview(characterLabel)
    }
    
    func configure(_ item: EpisodeDetailSection.Types) {
        self.item = item
        
        let basePath: String?
        switch item {
        case .cast(let item):
            actorLabel.text = item.name
            characterLabel.text = item.character
            basePath = item.profile_path
        case .guest(let item):
            actorLabel.text = item.name
            characterLabel.text = item.character
            basePath = item.profile_path
        }
        
        if
            let path = basePath,
            let baseURL = URL(string: "https://image.tmdb.org/t/p/w500") {
            let imageURL = baseURL.appendingPathComponent(path)
            ImagePipeline.shared.rx.loadImage(with: imageURL)
                .asObservable()
                .map { $0.image }
                .bind(to: icon.rx.image)
                .disposed(by: bag)
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()
                
        icon.anchorToEdge(.left, padding: 10, width: 50, height: 50)
        icon.layer.cornerRadius = 25
        icon.clipsToBounds = true
                
        actorLabel.alignAndFillWidth(align: .toTheRightMatchingTop, relativeTo: icon, padding: 20, height: 25)
        characterLabel.alignAndFillWidth(align: .toTheRightMatchingBottom, relativeTo: icon, padding: 20, height: 20)
    }
            
    required init?(coder: NSCoder) {
        fatalError()
    }
}
