//
//  ChatRightVideoCell.swift
//  Yep
//
//  Created by NIX on 15/4/23.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import YepKit

final class ChatRightVideoCell: ChatRightBaseCell {

    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.tintColor = UIColor.rightBubbleTintColor()
        return imageView
    }()

    lazy var borderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "right_tail_image_bubble_border"))
        return imageView
    }()

    lazy var playImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_playvideo"))
        return imageView
    }()

    typealias MediaTapAction = () -> Void
    var mediaTapAction: MediaTapAction?

    func makeUI() {

        let fullWidth = UIScreen.mainScreen().bounds.width

        let halfAvatarSize = YepConfig.chatCellAvatarSize() / 2

        avatarImageView.center = CGPoint(x: fullWidth - halfAvatarSize - YepConfig.chatCellGapBetweenWallAndAvatar(), y: halfAvatarSize)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(borderImageView)
        contentView.addSubview(playImageView)

        UIView.setAnimationsEnabled(false); do {
            makeUI()
        }
        UIView.setAnimationsEnabled(true)

        thumbnailImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatRightVideoCell.tapMediaView))
        thumbnailImageView.addGestureRecognizer(tap)

        prepareForMenuAction = { otherGesturesEnabled in
            tap.enabled = otherGesturesEnabled
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tapMediaView() {
        mediaTapAction?()
    }

    var loadingProgress: Double = 0

    func loadingWithProgress(progress: Double, image: UIImage?) {

        if progress >= loadingProgress {

            if progress <= 1.0 {
                loadingProgress = progress
            }

            if let image = image {

                self.thumbnailImageView.image = image

                UIView.animateWithDuration(YepConfig.ChatCell.imageAppearDuration, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.thumbnailImageView.alpha = 1.0
                }, completion: { (finished) -> Void in
                })
            }
        }
    }
    
    func configureWithMessage(message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: NSIndexPath) {

        self.message = message
        self.user = message.fromFriend

        self.mediaTapAction = mediaTapAction

        UIView.setAnimationsEnabled(false); do {
            makeUI()
        }
        UIView.setAnimationsEnabled(true)

        if let sender = message.fromFriend {
            let userAvatar = UserAvatar(userID: sender.userID, avatarURLString: sender.avatarURLString, avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
        }

        SafeDispatch.async { [weak self] in
            self?.thumbnailImageView.alpha = 0.0
        }

        let videoSize = message.fixedVideoSize

        thumbnailImageView.yep_setImageOfMessage(message, withSize: videoSize, tailDirection: .Right, completion: { loadingProgress, image in
            SafeDispatch.async { [weak self] in
                self?.loadingWithProgress(loadingProgress, image: image)
            }
        })

        UIView.setAnimationsEnabled(false); do {
            let width = videoSize.width
            thumbnailImageView.frame = CGRect(x: CGRectGetMinX(avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: bounds.height)
            playImageView.center = CGPoint(x: CGRectGetMidX(thumbnailImageView.frame) - YepConfig.ChatCell.playImageViewXOffset, y: CGRectGetMidY(thumbnailImageView.frame))
            dotImageView.center = CGPoint(x: CGRectGetMinX(thumbnailImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(thumbnailImageView.frame))

            borderImageView.frame = thumbnailImageView.frame
        }
        UIView.setAnimationsEnabled(true)

        /*
        if let (videoWidth, videoHeight) = videoMetaOfMessage(message) {

            let aspectRatio = videoWidth / videoHeight

            let messageImagePreferredWidth = max(messageImagePreferredWidth, ceil(YepConfig.ChatCell.mediaMinHeight * aspectRatio))
            let messageImagePreferredHeight = max(messageImagePreferredHeight, ceil(YepConfig.ChatCell.mediaMinWidth / aspectRatio))

            if aspectRatio >= 1 {

                let width = messageImagePreferredWidth
                
                UIView.performWithoutAnimation { [weak self] in

                    if let strongSelf = self {
                        strongSelf.thumbnailImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.playImageView.center = CGPoint(x: CGRectGetMidX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.playImageViewXOffset, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))
                        strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))

                        strongSelf.borderImageView.frame = strongSelf.thumbnailImageView.frame
                    }
                }

                let size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / aspectRatio))

                thumbnailImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
                    SafeDispatch.async { [weak self] in
                        self?.loadingWithProgress(loadingProgress, image: image)
                    }
                })

            } else {
                let width = messageImagePreferredHeight * aspectRatio
                
                UIView.performWithoutAnimation { [weak self] in

                    if let strongSelf = self {
                        strongSelf.thumbnailImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.playImageView.center = CGPoint(x: CGRectGetMidX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.playImageViewXOffset, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))
                        strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))

                        strongSelf.borderImageView.frame = strongSelf.thumbnailImageView.frame
                    }
                }

                let size = CGSize(width: messageImagePreferredHeight * aspectRatio, height: messageImagePreferredHeight)

                thumbnailImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
                    SafeDispatch.async { [weak self] in
                        self?.loadingWithProgress(loadingProgress, image: image)
                    }
                })
            }

        } else {
            let width = messageImagePreferredWidth
            
            UIView.performWithoutAnimation { [weak self] in

                if let strongSelf = self {
                    strongSelf.thumbnailImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                    strongSelf.playImageView.center = CGPoint(x: CGRectGetMidX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.playImageViewXOffset, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))
                    strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.thumbnailImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.thumbnailImageView.frame))

                    strongSelf.borderImageView.frame = strongSelf.thumbnailImageView.frame
                }
            }

            let size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / messageImagePreferredAspectRatio))

            thumbnailImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
                SafeDispatch.async { [weak self] in
                    self?.loadingWithProgress(loadingProgress, image: image)
                }
            })
        }
         */
    }
}

