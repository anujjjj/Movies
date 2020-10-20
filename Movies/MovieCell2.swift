//
//  MovieCell2.swift
//  Movies
//
//  Created by Anuj Pande on 15/10/20.
//

import UIKit

class MovieCell2: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var totalVotes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func heightOfCell(model: MovieItem, width: CGFloat, expanded: Bool) -> CGFloat {
        if expanded {
            let font = UIFont.systemFont(ofSize: 17)
            let textAttributes = [NSAttributedString.Key.font: font]
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let textRect = model.overview.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
            return 200 + textRect.height - 20.7
//            return UITableView.automaticDimension
        } else {
            return 200
        }
    }
    
}
