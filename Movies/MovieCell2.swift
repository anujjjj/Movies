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
        let font = UIFont.systemFont(ofSize: 17)
        let textAttributes = [NSAttributedString.Key.font: font]
        let cellWidth = width - 16*2
        let lineHeight = font.lineHeight
        let constraintRect = CGSize(width: cellWidth, height: .greatestFiniteMagnitude)
        let textRect = model.overview.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
        let numberOfLinesRequired = Int(ceil(textRect.height / lineHeight))
        print("\(model.title) \(numberOfLinesRequired)")
        var contentHeight = 0.0
        contentHeight += 16
        contentHeight += 120
        contentHeight += 8
        contentHeight += 8
        
        if expanded {
            contentHeight += Double(textRect.height + 4)
        } else {
            contentHeight += Double(lineHeight * CGFloat(min(2,numberOfLinesRequired)) + 4)
        }
        return CGFloat(contentHeight)
    }
}
