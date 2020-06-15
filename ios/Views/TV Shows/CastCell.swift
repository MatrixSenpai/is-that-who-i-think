//
//  CastCell.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import UIKit
import RxSwift
import Nuke
import RxNuke
import libtmdb

extension TVShowViewController {
    class CastCell: UITableViewCell {
        static let identifier: String = "castCell"
        
        let icon = UIImageView()
        
        let actorLabel = UILabel()
        let characterLabel = UILabel()
        
        let bag = DisposeBag()
        
        var item: TVCreditsModel.Cast?
            
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
                
            icon.contentMode = .scaleAspectFill
            contentView.addSubview(icon)
                
            actorLabel.font = .systemFont(ofSize: 21)
            contentView.addSubview(actorLabel)
                
            characterLabel.font = .italicSystemFont(ofSize: 17)
            contentView.addSubview(characterLabel)
        }
            
        func configure(_ item: TVCreditsModel.Cast) {
            self.item = item
            actorLabel.text = item.name
            characterLabel.text = item.character
                
            if
                let path = item.profile_path,
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
}
