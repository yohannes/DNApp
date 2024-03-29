//
//  StoryTableViewCell.swift
//  DNApp
//
//  Created by Yohannes Wijaya on 12/31/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit

protocol StoryTableViewCellDelegate: NSObjectProtocol {
    func StoryTableViewCellUpvoteButtonDidTouch(cell: StoryTableViewCell)
    func StoryTableViewCellCommentButtonDidTouch(cell: StoryTableViewCell)
}

class StoryTableViewCell: UITableViewCell {

    // MARK: - Stored Properties
    
    let data = Data()
    
    weak var delegate: StoryTableViewCellDelegate?
    
    // MARK: - IBOutlet Properties

    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: AsyncImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var upvoteButton: SpringButton!
    @IBOutlet weak var commentButton: SpringButton!
    @IBOutlet weak var commentTextView: AutoTextView!
    
    // MARK: - IBAction Properties
    
    @IBAction func upvoteButtonDidTouch(sender: SpringButton) {
        self.delegate?.StoryTableViewCellUpvoteButtonDidTouch(self)
        
        self.upvoteButton.animation = "pop"
        self.upvoteButton.force = 3.0
        self.upvoteButton.animate()
        
        SoundPlayer.playSound("upvote.wav")
    }
    
    @IBAction func commentButtonDidTouch(sender: SpringButton) {
        self.delegate?.StoryTableViewCellCommentButtonDidTouch(self)
        
        self.commentButton.animation = "pop"
        self.commentButton.force = 3.0
        self.commentButton.animate()
    }
    
    // MARK: - Local Methods
    
    func configureCellWithArticle(article: JSON) {
        
        guard let validTitle = article["title"].string else { return }
        self.titleLabel.text = validTitle
        
        let badge = article["badge"].string ?? ""
        self.badgeImageView.image = UIImage(named: "badge-" + badge )

        let avatar = article["user_portrait_url"].string
        let avatarUrl = avatar?.toURL()
        self.avatarImageView.setURL(avatarUrl, placeholderImage: UIImage(named: "content-avatar-default"))
        
        let userDisplayName = article["user_display_name"].string ?? ""
        self.authorLabel.text = userDisplayName
        
        let jobTitle = article["user_job"].string ?? ""
        self.authorLabel.text = userDisplayName + ", " + jobTitle
        
        guard let validCreatedAt = article["created_at"].string else { return }
        self.timeLabel.text = timeAgoSinceDate(dateFromString(validCreatedAt, format: "yyyy-MM-dd'T'HH:mm:ssZ"), numericDates: true)
        
        guard let validVoteCount = article["vote_count"].int else { return }
        self.upvoteButton.setTitle("\(validVoteCount)", forState: UIControlState.Normal)
       
        guard let validCommentCount = article["comment_count"].int else { return }
        self.commentButton.setTitle("\(validCommentCount)", forState: .Normal)

        if let validCommentTextView = self.commentTextView {
            let validComment = article["comment"].string ?? ""
            validCommentTextView.text = validComment
            let commentInHTML = article["comment_html"].string ?? ""
            validCommentTextView.attributedText = htmlToAttributedString(commentInHTML + "<style>*{font-family:\"Avenir Next\";font-size:16px;line-height:20px}img{max-width:300px}</style>")
        }
        
        guard let validArticleID = article["id"].int else { return }
        if LocalDefaults.isStoryUpvoted(validArticleID) {
            self.upvoteButton.setImage(UIImage(named: "icon-upvote-active"), forState: UIControlState.Normal)
            self.upvoteButton.setTitle(String(validVoteCount + 1), forState: .Normal)
        }
        else {
            self.upvoteButton.setImage(UIImage(named: "icon-upvote"), forState: .Normal)
            self.upvoteButton.setTitle(String(validVoteCount), forState: .Normal)
        }
    }
}
