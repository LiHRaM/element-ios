//
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

/// Base class to support an avatar view
/// Note: This class is made to be sublcassed
class AvatarView: UIView, Themable {
    
    // MARK: - Properties

    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: MXKImageView! {
        didSet {
            self.setupAvatarImageView()
        }
    }
    
    // MARK: Private

    private(set) var theme: Theme?
    
    // MARK: Public
    
    override var isUserInteractionEnabled: Bool {
        get {
            return super.isUserInteractionEnabled
        }
        set {
            super.isUserInteractionEnabled = newValue
            self.updateAccessibilityTraits()
        }
    }
    
    /// Indicate highlighted state
    var isHighlighted: Bool = false {
        didSet {
            self.updateView()
        }
    }

    var action: (() -> Void)?
    
    // MARK: - Setup
    
    private func commonInit() {
        self.setupGestureRecognizer()
        self.updateAccessibilityTraits()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height/2
    }
    
    // MARK: - Public
    
    func fill(with viewData: AvatarViewDataProtocol) {
        self.updateAvatarImageView(with: viewData)
        self.setNeedsLayout()
    }
        
    func update(theme: Theme) {
        self.theme = theme
    }
    
    func updateAccessibilityTraits() {
        // Override in subclass
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.defaultBackgroundColor = UIColor.clear
        self.avatarImageView.enableInMemoryCache = true
        self.avatarImageView.layer.masksToBounds = true
    }
    
    func updateAvatarImageView(with viewData: AvatarViewDataProtocol) {
        guard let avatarImageView = self.avatarImageView else {
            return
        }
        
        let defaultAvatarImage: UIImage?
        var defaultAvatarImageContentMode: UIView.ContentMode = .scaleAspectFill
        
        switch viewData.fallbackImage {
        case .matrixItem(let matrixItemId, let matrixItemDisplayName):
            defaultAvatarImage = AvatarGenerator.generateAvatar(forMatrixItem: matrixItemId, withDisplayName: matrixItemDisplayName)
        case .image(let image, let contentMode):
            defaultAvatarImage = image
            defaultAvatarImageContentMode = contentMode ?? .scaleAspectFill
        case .none:
            defaultAvatarImage = nil
        }
                
        if let avatarUrl = viewData.avatarUrl {
            avatarImageView.setImageURI(avatarUrl,
                                        withType: nil,
                                        andImageOrientation: .up,
                                        toFitViewSize: avatarImageView.frame.size,
                                        with: MXThumbnailingMethodScale,
                                        previewImage: defaultAvatarImage,
                                        mediaManager: viewData.mediaManager)
            avatarImageView.contentMode = .scaleAspectFill
        } else {
            avatarImageView.image = defaultAvatarImage
            avatarImageView.contentMode = defaultAvatarImageContentMode
        }
    }
    
    func updateView() {
        // Override in subclass if needed
        // TODO: Handle highlighted state
    }
    
    // MARK: - Private
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(buttonAction(_:)))
        gestureRecognizer.minimumPressDuration = 0
        self.addGestureRecognizer(gestureRecognizer)
    }
        
    // MARK: - Actions

    @objc private func buttonAction(_ sender: UILongPressGestureRecognizer) {

        let isBackgroundViewTouched = sender.vc_isTouchingInside()

        switch sender.state {
        case .began, .changed:
            self.isHighlighted = isBackgroundViewTouched
        case .ended:
            self.isHighlighted = false

            if isBackgroundViewTouched {
                self.action?()
            }
        case .cancelled:
            self.isHighlighted = false
        default:
            break
        }
    }
}
