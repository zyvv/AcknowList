//
//  AcknowCell.swift
//  AcknowList
//
//  Created by 张洋威 on 2019/12/27.
//  Copyright © 2019 VTourraine. All rights reserved.
//

import UIKit

let TopBottomDefaultMargin: CGFloat = 5
let LeftRightDefaultMargin: CGFloat = 10
let TitleDefaultHeight: CGFloat = 20


class AcknowCell: UITableViewCell {
    
    var titleTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
            textView.isEditable = false
            textView.dataDetectorTypes = .link
        #endif
        textView.textContainerInset = UIEdgeInsets.init(top: 0, left: LeftRightDefaultMargin, bottom: 0, right: LeftRightDefaultMargin)
        return textView
    }()
        
    var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .caption2)
        textView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
            textView.isEditable = false
            textView.dataDetectorTypes = .link
        #endif
        textView.textContainerInset = UIEdgeInsets.init(top: TopBottomDefaultMargin, left: LeftRightDefaultMargin, bottom: TopBottomDefaultMargin, right: LeftRightDefaultMargin)
         return textView
    }()

    /// The represented acknowledgement.
    var acknowledgement: Acknow? {
        didSet {
            titleTextView.text = acknowledgement?.title
            textView.text = acknowledgement?.text
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(titleTextView)
        contentView.addSubview(textView)
        
        let tLeft = NSLayoutConstraint(item: titleTextView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0)
        let tRight = NSLayoutConstraint(item: titleTextView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
        let tTop = NSLayoutConstraint(item: titleTextView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: TopBottomDefaultMargin)
        let tHeight = NSLayoutConstraint(item: titleTextView, attribute: .height, relatedBy: .equal, toItem:nil, attribute: .notAnAttribute, multiplier: 1, constant: TitleDefaultHeight)
        contentView.addConstraint(tLeft)
        contentView.addConstraint(tRight)
        contentView.addConstraint(tTop)
        titleTextView.addConstraint(tHeight)
        
        let left = NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: titleTextView, attribute: .bottom, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        contentView.addConstraint(left)
        contentView.addConstraint(right)
        contentView.addConstraint(top)
        contentView.addConstraint(bottom)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
