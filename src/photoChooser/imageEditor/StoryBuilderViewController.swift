//
//  StoryBuilderViewController.swift
//  Stories
//
//  Created by vlad on 9/2/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import Messages
import MBProgressHUD

public protocol StoryBuilderViewControllerDelegate: class {
    func shareImage(_ image: UIImage)
}

public class StoryBuilderViewController: UIViewController {
    public weak var delegate: StoryBuilderViewControllerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()

        stampChooserViewController.delegate = self
        capturePhotoViewController.delegate = self

        showCamera(true)

        loadInitialData()
    }

    private func loadInitialData() {
        loadCachedStories()

        var activityIndicator: MBProgressHUD?

        if animatedStories?.count ?? 0 == 0 {
            activityIndicator = view.showActivityIndicator()
        }

        stickersService.updateStories { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    printErr("error during updating stories", logToServer: true, error: error)

                    return
                }

                if let activityIndicator = activityIndicator {
                    activityIndicator.hide(animated: true)
                }

                if self.animatedStories?.count ?? 0 == 0 {
                    self.loadCachedStories()
                }
            }
        }

        stickersService.updateStamps { error in
            // TODO: add error processing
        }
    }

    fileprivate func setUp(for image: UIImage?) {
        imageEditor.setImage(image)

        guard let image = image else {
            return
        }

        DispatchQueue.global().async {
            guard let ciImage = CIImage(image: image) else {
                UIAlertController.show(from: self, for: UIAlertController.UserAlert.lIncorrectImage)

                return
            }

            var cords: [Face]? = nil

            do {
                cords = try ImageDetector.getCords(from: ciImage, for: self.view.bounds)
            } catch {
                printErr("can't scan image", error: error)
            }

            self.imageCords = cords

            self.imageEditor.stampsLayerView.faceObjects = cords
        }
    }


    // MARK: -

    func showCamera(_ show: Bool) {
        // use this code instead of self.present(_...), because of inability to present from viewDidLoad
        if show {
            let captureView = capturePhotoViewController.view!
            captureView.translatesAutoresizingMaskIntoConstraints = false

            addChildViewController(capturePhotoViewController)

            view.addSubview(captureView)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[captureView]|", metrics: nil, views: ["captureView": captureView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[captureView]|", metrics: nil, views: ["captureView": captureView]))
        } else {
            capturePhotoViewController.view.removeFromSuperview()

            capturePhotoViewController.removeFromParentViewController()
        }
    }


    // MARK: -

    @IBAction private func showStoryPickerButtonTapped(_ sender: UIButton) {
        storyPickerView.changePresentation(.shown)
    }

    @IBAction private func resetButtonTapped() {
        setUp(for: nil)
        showCamera(true)
        storyIdx = -1
        storyPickerView.selectIdx(-1)
        imageEditor.stampsLayerView.removeAllStamps(animated: false)
    }

    @IBAction private func showStickersButtonTapped() {
        show(stampChooserViewController, sender: nil)
    }

    @IBAction private func shareButtonTapped() {
        do {
            let image = try imageEditor.getResultImage().image

            guard let delegate = delegate else {
                printErr("set delegate to capture result image in -shareImage method")

                return
            }

            delegate.shareImage(image)
        } catch {
            UIAlertController.show(from: self, for: UIAlertController.UserAlert.lIncorrectImage)
        }
    }

    fileprivate class AnimatedStory {
        let story: Story
        var shown = false

        init(story: Story) {
            self.story = story
        }
    }

    fileprivate var animatedStories: [AnimatedStory]? = nil

    private func loadCachedStories() {
        let defaultSortDescriptor = NSSortDescriptor(key: #keyPath(Story.orderNumber), ascending: true)

        guard let stories = Story.stk_findAll(sortDescriptors: [defaultSortDescriptor]) as? [Story], !stories.isEmpty else {
            printErr("no stamp stories found")

            return
        }

        var _stories = [AnimatedStory]()

        for story in stories {
            guard story.stamps?.count ?? 0 > 0 else {
                printErr("no stamps for story \(story)")

                continue
            }

            _stories.append(AnimatedStory(story: story))
        }

        animatedStories = _stories

        guard let animatedStories = animatedStories else {
            printErr("no available stories found")

            return
        }

        storyPickerView.imageUrls = animatedStories.map { animatedStory in
            if let iconUrl = animatedStory.story.iconUrl {
                return URL(string: iconUrl)
            } else {
                return nil
            }
        }
    }


    private var storyIdx: Int = -1

    fileprivate func changeToStory(withIdx storyIdx: Int) {
        guard let imageCords = imageCords else {
            printErr("no face detected, can't randomize")

            return
        }

        guard let animatedStories = animatedStories else {
            printErr("animatedStories didn't loaded")

            return
        }

        guard storyIdx < animatedStories.count else {
            printErr("storyIdx is out of range")

            return
        }

        guard storyIdx >= 0 else {
            imageEditor.stampsLayerView.removeAllStamps(animated: true)

            return
        }

        guard self.storyIdx != storyIdx else {
            return
        }

        self.storyIdx = storyIdx

        func randomInterval() -> TimeInterval {
            let randomNum: UInt32 = arc4random_uniform(200)

            return Double(randomNum) / 1000
        }

        let animatedStory = animatedStories[storyIdx]

        guard let stamps = animatedStory.story.stamps as? Set<StoryStamp> else {
            printErr("unexpected condition; stamps is nil")

            return
        }

        let sortedStamps = stamps.sorted{ $0.orderNumber < $1.orderNumber }

        func addRecursively(forStampIdx idx: Int, storyIdx _storyIdx: Int, completion: (() -> ())? = nil) {
            if idx < sortedStamps.count, self.storyIdx == _storyIdx {
                let interval = animatedStory.shown ? 0 : randomInterval()

                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    let stamp = sortedStamps[idx]

                    self.imageEditor.stampsLayerView.addPositionedStamp(stamp)

                    addRecursively(forStampIdx: idx + 1, storyIdx: _storyIdx, completion: completion)
                }
            } else {
                animatedStory.shown = true

                if self.storyIdx != _storyIdx {
                    self.imageEditor.stampsLayerView.removeAllStamps()
                }

                completion?()
            }
        }

        imageEditor.stampsLayerView.removeAllStamps(animated: true) {
            addRecursively(forStampIdx: 0, storyIdx: storyIdx)
        }
    }

    private let stickersService = StoriesEntityService()

    fileprivate var removeMode = false {
        didSet {
            let scale: CGFloat = removeMode ? 1.3 : 1.0

            UIView.animate(withDuration: 0.3) {
                self.stampsButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    fileprivate var imageCords: [Face]? {
        didSet {
            DispatchQueue.main.async {
                if self.imageCords != nil {
                    if self.animatedStories != nil {
                        self.changeToStory(withIdx: 0)
                    }

                    self.storyPickerView.changePresentation(.shown, animated: true)
                } else {
                    UIAlertController.show(from: self, for: UIAlertController.UserAlert.lNoFaceFound)

                    self.storyPickerView.changePresentation(.locked, animated: true)
                }
            }
        }
    }

    @IBOutlet fileprivate weak var storyPickerView: StoryPickerView! {
        didSet {
            storyPickerView.storyPickerDelegate = self
        }
    }
    @IBOutlet fileprivate weak var imageEditor: ImageEditorView! {
        didSet {
            imageEditor.stampViewsDelegate = self
        }
    }
    @IBOutlet fileprivate weak var stampsButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet fileprivate weak var resetButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var sendButtonBottomConstraint: NSLayoutConstraint!

    fileprivate let stampChooserViewController = StampChooserViewController.storyboardController()
    private let capturePhotoViewController = CapturePhotoViewController.storyboardController()

    fileprivate let buttonsShownYPosition: CGFloat = 14
}


extension StoryBuilderViewController: CapturePhotoViewControllerDelegate {
    func photoWasCaptured(_ photo: UIImage) {
        showCamera(false)

        setUp(for: photo)

        imageEditor.changeFilter()
    }
}


extension StoryBuilderViewController: StampViewDelegate {
    func doubleTap(forStampView stampView: StampView) {

    }

    func touchEnded(_ ended: Bool, view: StampView) {
        stampsButton.isSelected = !ended

        if ended && removeMode {
            imageEditor.stampsLayerView.remove(stampView: view)

            removeMode = false
        }
    }

    func centerMovedTo(point: CGPoint, view: StampViewProtocol) {
        let convertedPoint = imageEditor.convert(point, to: self.view)
        let enableRemoving = stampsButton.frame.contains(convertedPoint)

        if removeMode != enableRemoving {
            removeMode = enableRemoving
        }

        view.removingMode = enableRemoving
    }
}


extension StoryBuilderViewController: StampInteractionDelegate {
    func stampLongPressed(_ stamp: Stamp, fromCellWith frame: CGRect) {
        let point = view.convert(frame.origin, from: stampChooserViewController.view)

        imageEditor.stampsLayerView.addStamp(stamp, forRect: CGRect(origin: point, size: frame.size))

        SessionManager.shared.analyticService.stampSelected(stampId: stamp.id)

        fadeStickerView()
    }

    func stampSelected(_ stamp: Stamp) {
        hideStickerView()

        SessionManager.shared.analyticService.stampSelected(stampId: stamp.id)

        imageEditor.stampsLayerView.addStamp(stamp)
    }

    private func fadeStickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.stampChooserViewController.view.alpha = 0.0
        }) { _ in
            self.hideStickerView() {
                self.stampChooserViewController.view.alpha = 1.0
            }
        }
    }

    private func hideStickerView(completion: (() -> ())? = nil) {
        stampChooserViewController.dismiss(animated: true, completion: completion)
    }
}


extension StoryBuilderViewController: StoryPickerViewDelegate {
    func selectedIdxChanged(_ idx: Int) {
        if imageCords != nil && self.animatedStories != nil {
            changeToStory(withIdx: idx)
        }
    }

    func presentationChanged(_ presentation: StoryPickerViewPresentation) {
        setUpInterface(for: presentation)
    }

    func pickerPositionChanged(_ value: CGFloat) {
        resetButtonTopConstraint.constant = -value + 14
        sendButtonBottomConstraint.constant = -value + 14

        view.layoutIfNeeded()
    }

    func shouldReceiveTouch(for point: CGPoint) -> Bool {
        return !imageEditor.isPointInsideStamp(point)
    }

    private func setUpInterface(for presentation: StoryPickerViewPresentation) {
        let buttonsHiddenYPosition = storyPickerView.constantForPickerShown - buttonsShownYPosition

        view.layoutIfNeeded()

        resetButtonTopConstraint.constant = presentation == .shown ? -buttonsHiddenYPosition : buttonsShownYPosition
        sendButtonBottomConstraint.constant = presentation == .shown ? -buttonsHiddenYPosition : buttonsShownYPosition

        UIView.animate(withDuration: 0.3) { _ in
            self.view.layoutIfNeeded()
        }
    }
}
