
import UIKit

public typealias IndexChange = (Int) -> Void
public typealias HMTitleFormatter = (HMSegmentedControl, String, Int, Bool) -> NSAttributedString
public typealias HMAttributes = [NSAttributedStringKey: Any]
public let HMSegmentedControlNoSegment = -1

public class HMSegmentedControl: UIControl {
    public var sectionTitles: [String] = [] {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    public var sectionImages: [UIImage] = [] {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    public lazy var sectionSelectedImages: [UIImage] = []

    /**
     Provide a block to be executed when selected index is changed.

     Alternativly, you could use `addTarget:action:forControlEvents:`
     */
    public var indexChangeHandle: IndexChange?

    /**
     Used to apply custom text styling to titles when set.

     When this block is set, no additional styling is applied to the `NSAttributedString` object returned from this block.
     */
    public var titleFormatter: HMTitleFormatter?

    /**
     Text attributes to apply to item title text.
     */
    public var titleTextAttributes: HMAttributes?

    /*
     Text attributes to apply to selected item title text.

     Attributes not set in this dictionary are inherited from `titleTextAttributes`.
     */
    public var selectedTitleTextAttributes: HMAttributes?

    /**
     Segmented control background color.

     Default is `[UIColor whiteColor]`
     */
    //    public var backgroundColor: UIColor?

    /**
     Color for the selection indicator stripe

     Default is `R:52, G:181, B:229`
     */
    //public var selectionIndicatorColor = UIColor(red: 52.0 / 255.0, green: 181.0 / 255.0, blue: 229.0 / 255.0, alpha: 1)
    
    public var selectionIndicatorColor = UIColor.red

    /**
     Color for the selection indicator box

     Default is selectionIndicatorColor
     */
    public var selectionIndicatorBoxColor: UIColor!

    /**
     Color for the vertical divider between segments.

     Default is `UIColor.black`
     */
    public var verticalDividerColor = UIColor.black

    /**
     Opacity for the seletion indicator box.

     Default is `0.2f`
     */
    public var selectionIndicatorBoxOpacity: CGFloat = 0.2 {
        didSet {
            selectionIndicatorBoxLayer.opacity = Float(selectionIndicatorBoxOpacity)
        }
    }

    /**
     Width the vertical divider between segments that is added when `verticalDividerEnabled` is set to YES.

     Default is `1.0f`
     */
    public var verticalDividerWidth: CGFloat = 1

    /**
     Specifies the style of the control

     Default is `text`
     */
    public var type: HMSegmentedControlType = .text

    /**
     Specifies the style of the selection indicator.

     Default is `HMSegmentedControlSelectionStyleTextWidthStripe`
     */
    public var selectionStyle: HMSegmentedControlSelectionStyle = .textWidthStripe

    /**
     Specifies the style of the segment's width.

     Default is `fixed`
     */
    public var segmentWidthStyle: HMSegmentedControlSegmentWidthStyle = .fixed {
        didSet {
            // Force HMSegmentedControlSegmentWidthStyleFixed when type is HMSegmentedControlTypeImages.
            if type == .images {
                segmentWidthStyle = .fixed
            }
        }
    }

    /**
     Specifies the location of the selection indicator.

     Default is `down`
     */
    public var selectionIndicatorLocation: HMSegmentedControlSelectionIndicatorLocation = .down {
        didSet {
            if selectionIndicatorLocation == .none {
                selectionIndicatorHeight = 0
            }
        }
    }

    /*
     Specifies the border type.

     Default is `none`
     */
    public var borderType: HMSegmentedControlBorderType = .none {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     Specifies the image position relative to the text. Only applicable for HMSegmentedControlTypeTextImages
     
     Default is `.behindText`
     */
    public var imagePosition: HMSegmentedControlImagePosition = .behindText

    /**
     Specifies the distance between the text and the image. Only applicable for HMSegmentedControlTypeTextImages
     
     Default is `0,0`
     */
    public var textImageSpacing: CGFloat = 10
    
    /**
     Specifies the border color.

     Default is `UIColor.black`
     */
    public var borderColor = UIColor.black

    /**
     Specifies the border width.

     Default is `1.0f`
     */
    public var borderWidth: CGFloat = 1

    /**
     Default is true. Set to false to deny scrolling by dragging the scrollView by the user.
     */
    public var isUserDraggable = true

    /**
     Default is true. Set to false to deny any touch events by the user.
     */
    public var isTouchEnabled = true

    /**
     Default is false. Set to true to show a vertical divider between the segments.
     */
    public var isVerticalDividerEnabled = false

    /**
     Index of the currently selected segment.
     */
    public var selectedSegmentIndex: Int {
        set {
            setSelectedSegmentIndex(newValue, animated: false, notify: false)
        }
        get {
            return _selectedSegmentIndex
        }
    }

    private var _selectedSegmentIndex = 0

    /**
     Height of the selection indicator. Only effective when `HMSegmentedControlSelectionStyle` is either `HMSegmentedControlSelectionStyleTextWidthStripe` or `HMSegmentedControlSelectionStyleFullWidthStripe`.

     Default is 5.0
     */
    public var selectionIndicatorHeight: CGFloat = 5

    /**
     Edge insets for the selection indicator.
     NOTE: This does not affect the bounding box of HMSegmentedControlSelectionStyleBox

     When HMSegmentedControlSelectionIndicatorLocationUp is selected, bottom edge insets are not used

     When HMSegmentedControlSelectionIndicatorLocationDown is selected, top edge insets are not used

     Defaults is zero
     */
    public var selectionIndicatorEdgeInsets: UIEdgeInsets = .zero

    /**
     Inset left and right edges of segments.

     Default is UIEdgeInsetsMake(0, 5, 0, 5)
     */
    public var segmentEdgeInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    public var enlargeEdgeInset: UIEdgeInsets = .zero

    /**
     Default is true. Set to false to disable animation during user selection.
     */
    public var shouldAnimateUserSelection = true

    private var selectionIndicatorStripLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()

    private var selectionIndicatorBoxLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()

    private lazy var selectionIndicatorArrowLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()

    private var segmentWidth: CGFloat = 0
    private lazy var segmentWidthsArray: [CGFloat] = []

    private lazy var _scrollView: HMScrollView = {
        let scrollView = HMScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public convenience init(sectionTitles: [String]) {
        self.init(frame: .zero)
        self.sectionTitles = sectionTitles
    }

    public convenience init(sectionImages: [UIImage], sectionSelectedImages: [UIImage]) {
        self.init(frame: .zero)
        self.sectionImages = sectionImages
        self.sectionSelectedImages = sectionSelectedImages
        type = .images
    }

    public convenience init(sectionImages: [UIImage], sectionSelectedImages: [UIImage], sectiontitles: [String]) {
        self.init(frame: .zero)

        if sectionImages.count != sectiontitles.count {
            //            NSException.raise(NSExceptionName.rangeException, format: "***%s: Images bounds (%ld) Don't match Title bounds (%ld)", arguments: sel_getName(_cmd), (unsigned long)sectionImages.count, (unsigned long)sectiontitles.count)
        }

        self.sectionImages = sectionImages
        self.sectionSelectedImages = sectionSelectedImages
        sectionTitles = sectiontitles
        type = .textImages
    }
    
    private var isLowVersion: Bool {
        // 小于iOS 10
        let result = UIDevice.current.systemVersion.compare("10.0.0", options: .numeric)
        if case .orderedAscending = result {
            return true
        }
        return false
    }

    private func commonInit() {
        addSubview(_scrollView)

        backgroundColor = UIColor.white
        isOpaque = false

        selectionIndicatorBoxColor = selectionIndicatorColor

        selectionIndicatorBoxLayer.opacity = Float(selectionIndicatorBoxOpacity)
        selectionIndicatorBoxLayer.borderWidth = 1.0

        contentMode = .redraw
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateSegmentsRects()
    }

    public override var frame: CGRect {
        didSet {
            updateSegmentsRects()
        }
    }

    // MARK: - Drawing

    func measureTitle(at index: Int) -> CGSize {
        if index >= sectionTitles.count {
            return .zero
        }

        let title = sectionTitles[index]
        var size = CGSize.zero
        let selected = index == selectedSegmentIndex
        
        
        if let titleFormatter = titleFormatter {
            size = titleFormatter(self, title, index, selected).size()
        } else if titleFormatter == nil {
            let titleAttrs = selected ? resultingSelectedTitleTextAttributes : resultingTitleTextAttributes
            size = (title as NSString).size(withAttributes: titleAttrs)
        } else {
//            size = [(NSAttributedString *)title size]
        }

        return CGRect(origin: .zero, size: size).integral.size
    }

    func attributedTitle(at index: Int) -> NSAttributedString {
        let title = sectionTitles[index]
        let selected = index == selectedSegmentIndex

        guard let titleFormatter = titleFormatter else {
            let titleAttrs = selected ? resultingSelectedTitleTextAttributes : resultingTitleTextAttributes

            // the color should be cast to CGColor in order to avoid invalid context on iOS7
//            let titleColor = titleAttrs[NSForegroundColorAttributeName]
//
//            if let titleColor = titleColor {
//                titleAttrs[NSForegroundColorAttributeName] = (titleColor as AnyObject).cgColor
//            }

            return NSAttributedString(string: title, attributes: titleAttrs)
        }

        return titleFormatter(self, title, index, selected)
    }

    public override func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(bounds)

        selectionIndicatorArrowLayer.backgroundColor = selectionIndicatorColor.cgColor

        selectionIndicatorStripLayer.backgroundColor = selectionIndicatorColor.cgColor

        selectionIndicatorBoxLayer.backgroundColor = selectionIndicatorBoxColor.cgColor
        selectionIndicatorBoxLayer.borderColor = selectionIndicatorBoxColor.cgColor

        // Remove all sublayers to avoid drawing images over existing ones
        _scrollView.layer.sublayers = nil

        let oldRect = rect

        if type == .text {

            for idx in 0 ..< sectionTitles.count {

                var stringWidth: CGFloat = 0
                var stringHeight: CGFloat = 0

                let size = measureTitle(at: idx)
                stringWidth = size.width
                stringHeight = size.height
                var rectDiv = CGRect.zero
                var fullRect = CGRect.zero

                // Text inside the CATextLayer will appear blurry unless the rect values are rounded
                let locationUp: CGFloat = selectionIndicatorLocation == .up ? 1 : 0
                let selectionStyleNotBox: CGFloat = selectionStyle != .box ? 1 : 0

                let height = (frame.height - selectionStyleNotBox * selectionIndicatorHeight) / 2
                let y = round(height - stringHeight / 2 + selectionIndicatorHeight * locationUp)

                var _rect: CGRect
                if segmentWidthStyle == .fixed {
                    let x = segmentWidth * CGFloat(idx)
                    _rect = CGRect(x: x + (segmentWidth - stringWidth) / 2, y: y, width: stringWidth, height: stringHeight)
                    rectDiv = CGRect(x: x - (verticalDividerWidth / 2), y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.height - (selectionIndicatorHeight * 4))
                    fullRect = CGRect(x: x, y: 0, width: segmentWidth, height: oldRect.height)
                } else {
                    // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                    var xOffset: CGFloat = 0
                    var i = 0
                    for width in segmentWidthsArray {
                        if idx == i {
                            break
                        }
                        xOffset += width
                        i += 1
                    }

                    let widthForIndex = segmentWidthsArray[idx]
                    _rect = CGRect(x: xOffset, y: y, width: widthForIndex, height: stringHeight)
                    fullRect = CGRect(x: segmentWidth * CGFloat(idx), y: 0, width: widthForIndex, height: oldRect.height)
                    rectDiv = CGRect(x: xOffset - (verticalDividerWidth / 2), y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.height - (selectionIndicatorHeight * 4))
                }

                // Fix rect position/size to avoid blurry labels
                _rect = CGRect(x: ceil(_rect.minX), y: ceil(_rect.minY), width: ceil(_rect.width), height: ceil(_rect.height))

                let titleLayer = CATextLayer()
                titleLayer.frame = _rect
                titleLayer.alignmentMode = kCAAlignmentCenter

                if isLowVersion {
                    titleLayer.truncationMode = kCATruncationEnd
                }
                titleLayer.string = attributedTitle(at: idx)

                titleLayer.contentsScale = UIScreen.main.scale

                _scrollView.layer.addSublayer(titleLayer)

                // Vertical Divider
                if isVerticalDividerEnabled && idx > 0 {
                    let verticalDividerLayer = CALayer()
                    verticalDividerLayer.frame = rectDiv
                    verticalDividerLayer.backgroundColor = verticalDividerColor.cgColor

                    _scrollView.layer.addSublayer(verticalDividerLayer)
                }

                addBackgroundAndBorderLayer(with: fullRect)
            }
        } else if type == .images {

            for (idx, iconImage) in sectionImages.enumerated() {
                let icon = iconImage
                let imageWidth = icon.size.width
                let imageHeight = icon.size.height
                let y = round(frame.height - selectionIndicatorHeight) / 2 - imageHeight / 2 + ((selectionIndicatorLocation == .up) ? selectionIndicatorHeight : 0)

                let x = segmentWidth * CGFloat(idx) + (segmentWidth - imageWidth) / 2.0

                let _rect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)

                let imageLayer = CALayer()
                imageLayer.frame = _rect

                if selectedSegmentIndex == idx {
                    let highlightIcon = sectionSelectedImages[idx]
                    imageLayer.contents = highlightIcon.cgImage
                } else {
                    imageLayer.contents = icon.cgImage
                }

                _scrollView.layer.addSublayer(imageLayer)
                // Vertical Divider
                if isVerticalDividerEnabled && idx > 0 {
                    let verticalDividerLayer = CALayer()
                    verticalDividerLayer.frame = CGRect(x: (segmentWidth * CGFloat(idx)) - (verticalDividerWidth / 2), y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.height - (selectionIndicatorHeight * 4))
                    verticalDividerLayer.backgroundColor = verticalDividerColor.cgColor

                    _scrollView.layer.addSublayer(verticalDividerLayer)
                }

                addBackgroundAndBorderLayer(with: _rect)
            }
        } else if type == .textImages {

            for (idx, iconImage) in sectionImages.enumerated() {
                let icon = iconImage
                let imageWidth = icon.size.width
                let imageHeight = icon.size.height
                
                let stringSize = measureTitle(at: idx)
                let stringHeight = stringSize.height
                let stringWidth = stringSize.width

                let yOffset = round(((frame.height - selectionIndicatorHeight) / 2) - (stringHeight / 2))

                var imageXOffset = segmentEdgeInset.left // Start with edge inset
                var textXOffset = segmentEdgeInset.left
                var imageYOffset = ceil((frame.height - imageHeight) / 2.0) // Start in center
                var textYOffset  = ceil((frame.height - stringHeight) / 2.0)

                if segmentWidthStyle == .fixed {
                    if imagePosition.isImageInLineWidthText {
                        let whitespace = segmentWidth - stringSize.width - imageWidth - textImageSpacing
                        if imagePosition == .leftOfText {
                            imageXOffset += whitespace / 2.0
                            textXOffset = imageXOffset + imageWidth + textImageSpacing
                        } else {
                            textXOffset += whitespace / 2.0
                            imageXOffset = textXOffset + stringWidth + textImageSpacing
                        }
                    } else {
                        imageXOffset = segmentWidth * CGFloat(idx) + (segmentWidth - imageWidth) / 2.0 // Start with edge inset
                        textXOffset  = segmentWidth * CGFloat(idx) + (segmentWidth - stringWidth) / 2.0

                        let whitespace = frame.height - imageHeight - stringHeight - textImageSpacing
                        if imagePosition == .aboveText {
                            imageYOffset = ceil(whitespace / 2.0)
                            textYOffset = imageYOffset + imageHeight + textImageSpacing
                        } else if imagePosition == .belowText {
                            textYOffset = ceil(whitespace / 2.0)
                            imageYOffset = textYOffset + stringHeight + textImageSpacing
                        }
                    }
                } else if segmentWidthStyle == .dynamic {
                    // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                    var xOffset: CGFloat = 0
                    var i = 0

                    for width in segmentWidthsArray {
                        if idx == i {
                            break
                        }

                        xOffset += width
                        i += 1
                    }
                    
                    if imagePosition.isImageInLineWidthText {
                        if imagePosition == .leftOfText {
                            imageXOffset = xOffset
                            textXOffset = imageXOffset + imageWidth + textImageSpacing
                        } else {
                            textXOffset = xOffset
                            imageXOffset = textXOffset + stringWidth + textImageSpacing
                        }
                    } else {
                        
                        imageXOffset = xOffset + (segmentWidthsArray[i] - imageWidth) / 2 // Start with edge inset
                        textXOffset  = xOffset + (segmentWidthsArray[i] - stringWidth) / 2

                        let whitespace = frame.height - imageHeight - stringHeight - textImageSpacing
                        if imagePosition == .aboveText {
                            imageYOffset = ceil(whitespace / 2.0)
                            textYOffset = imageYOffset + imageHeight + textImageSpacing
                        } else if imagePosition == .belowText {
                            textYOffset = ceil(whitespace / 2.0)
                            imageYOffset = textYOffset + stringHeight + textImageSpacing
                        }
                    }
                }

                let imageRect = CGRect(x: imageXOffset, y: imageYOffset, width: imageWidth, height: imageHeight)
                let textRect = CGRect(x: ceil(textXOffset), y: ceil(yOffset), width: ceil(stringWidth), height: ceil(stringHeight))

                let titleLayer = CATextLayer()
                titleLayer.frame = textRect
                titleLayer.alignmentMode = kCAAlignmentCenter
                titleLayer.string = attributedTitle(at: idx)

                if isLowVersion {
                    titleLayer.truncationMode = kCATruncationEnd
                }
                let imageLayer = CALayer()
                imageLayer.frame = imageRect

                if selectedSegmentIndex == idx {
                    let highlightIcon = sectionSelectedImages[idx]
                    imageLayer.contents = highlightIcon.cgImage
                } else {
                    imageLayer.contents = icon.cgImage
                }

                _scrollView.layer.addSublayer(imageLayer)
                titleLayer.contentsScale = UIScreen.main.scale
                _scrollView.layer.addSublayer(titleLayer)

                addBackgroundAndBorderLayer(with: imageRect)
            }
        }

        // Add the selection indicators
        guard selectedSegmentIndex != HMSegmentedControlNoSegment else {
            return
        }

        if selectionStyle == .arrow {
            guard selectionIndicatorArrowLayer.superlayer == nil else {
                return
            }
            setArrowFrame()
            _scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
        } else {
            guard selectionIndicatorStripLayer.superlayer == nil else {
                return
            }

            selectionIndicatorStripLayer.frame = frameForSelectionIndicator
            _scrollView.layer.addSublayer(selectionIndicatorStripLayer)

            if selectionStyle == .box && selectionIndicatorBoxLayer.superlayer == nil {
                selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator
                _scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
            }
        }
    }

    func addBackgroundAndBorderLayer(with fullRect: CGRect) {
        // Background layer
        let backgroundLayer = CALayer()
        backgroundLayer.frame = fullRect
        layer.insertSublayer(backgroundLayer, at: 0)

        func creatLayer(with _: CGRect) {
            let borderLayer = CALayer()
            borderLayer.frame = CGRect(x: 0, y: 0, width: fullRect.width, height: borderWidth)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        }

        // Border layer
        if borderType == .top {
            creatLayer(with: CGRect(x: 0, y: 0, width: fullRect.width, height: borderWidth))
        }
        if borderType == .left {
            creatLayer(with: CGRect(x: 0, y: 0, width: borderWidth, height: fullRect.height))
        }
        if borderType == .bottom {
            creatLayer(with: CGRect(x: 0, y: fullRect.height - borderWidth, width: fullRect.width, height: borderWidth))
        }
        if borderType == .right {
            creatLayer(with: CGRect(x: fullRect.width - borderWidth, y: 0, width: borderWidth, height: fullRect.height))
        }
    }

    func setArrowFrame() {
        selectionIndicatorArrowLayer.frame = frameForSelectionIndicator

        selectionIndicatorArrowLayer.mask = nil

        let arrowPath = UIBezierPath()

        var p1 = CGPoint.zero
        var p2 = CGPoint.zero
        var p3 = CGPoint.zero

        if selectionIndicatorLocation == .down {
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width / 2, y: 0)
            p2 = CGPoint(x: 0, y: selectionIndicatorArrowLayer.bounds.height)
            p3 = CGPoint(x: selectionIndicatorArrowLayer.bounds.width, y: selectionIndicatorArrowLayer.bounds.height)
        }

        if selectionIndicatorLocation == .up {
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.width / 2, y: selectionIndicatorArrowLayer.bounds.size.height)
            p2 = CGPoint(x: selectionIndicatorArrowLayer.bounds.width, y: 0)
            p3 = .zero
        }

        arrowPath.move(to: p1)
        arrowPath.addLine(to: p2)
        arrowPath.addLine(to: p3)
        arrowPath.close()

        let maskLayer = CAShapeLayer()
        maskLayer.frame = selectionIndicatorArrowLayer.bounds
        maskLayer.path = arrowPath.cgPath
        selectionIndicatorArrowLayer.mask = maskLayer
    }

    var frameForSelectionIndicator: CGRect {
        var indicatorYOffset: CGFloat = 0.0

        if selectionIndicatorLocation == .down {
            indicatorYOffset = bounds.height - selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom
        }

        if selectionIndicatorLocation == .up {
            indicatorYOffset = selectionIndicatorEdgeInsets.top
        }

        var sectionWidth: CGFloat = 0.0
        
        switch type {
        case .text:
            let stringWidth = measureTitle(at: selectedSegmentIndex).width
            sectionWidth = stringWidth
        case .images:
            let sectionImage = sectionImages[selectedSegmentIndex]
            let imageWidth = sectionImage.size.width
            sectionWidth = imageWidth
        case .textImages:
            let stringWidth = measureTitle(at: selectedSegmentIndex).width
            let sectionImage = sectionImages[selectedSegmentIndex]
            let imageWidth = sectionImage.size.width
            sectionWidth = max(stringWidth, imageWidth)
        }

        if selectionStyle == .arrow {
            let width = segmentWidth * CGFloat(selectedSegmentIndex)
            let widthToEndOfSelectedSegment = width + segmentWidth
            let widthToStartOfSelectedIndex = width

            let x = widthToStartOfSelectedIndex + ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) - (selectionIndicatorHeight / 2)
            return CGRect(x: x - (selectionIndicatorHeight / 2), y: indicatorYOffset, width: selectionIndicatorHeight * 2, height: selectionIndicatorHeight)
        } else {
            if selectionStyle == .textWidthStripe &&
                sectionWidth <= segmentWidth &&
                segmentWidthStyle != .dynamic {
                let width = segmentWidth * CGFloat(selectedSegmentIndex)
                let widthToEndOfSelectedSegment = width + segmentWidth
                let widthToStartOfSelectedIndex = width

                let x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - sectionWidth / 2)
                return CGRect(x: x + selectionIndicatorEdgeInsets.left, y: indicatorYOffset, width: sectionWidth - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight)
            } else {
                if segmentWidthStyle == .dynamic {
                    var selectedSegmentOffset: CGFloat = 0

                    var i = 0
                    for width in segmentWidthsArray {
                        if selectedSegmentIndex == i {
                            break
                        }

                        selectedSegmentOffset = CGFloat(selectedSegmentOffset) + width
                        i += 1
                    }
                    return CGRect(x: selectedSegmentOffset + selectionIndicatorEdgeInsets.left, y: indicatorYOffset, width: segmentWidthsArray[selectedSegmentIndex] - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom)
                }

                return CGRect(x: (segmentWidth + selectionIndicatorEdgeInsets.left) * CGFloat(selectedSegmentIndex), y: indicatorYOffset, width: segmentWidth - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight)
            }
        }
    }

    var frameForFillerSelectionIndicator: CGRect {
        if segmentWidthStyle == .dynamic {
            var selectedSegmentOffset: CGFloat = 0.0

            var i = 0
            for width in segmentWidthsArray {
                if selectedSegmentIndex == i {
                    break
                }
                selectedSegmentOffset += width

                i += 1
            }

            return CGRect(x: selectedSegmentOffset, y: 0, width: segmentWidthsArray[selectedSegmentIndex], height: frame.height)
        }
        return CGRect(x: segmentWidth * CGFloat(selectedSegmentIndex), y: 0, width: segmentWidth, height: frame.height)
    }

    func updateSegmentsRects() {
        _scrollView.contentInset = UIEdgeInsets.zero
        _scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

        if sectionCount > 0 {
            segmentWidth = frame.width / CGFloat(sectionCount)
        }

        if type == .text && segmentWidthStyle == .fixed {
            for idx in 0 ..< sectionTitles.count {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        } else if type == .text && segmentWidthStyle == .dynamic {
            var mutableSegmentWidths: [CGFloat] = []

            for idx in 0 ..< sectionTitles.count {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                mutableSegmentWidths.append(stringWidth)
            }
            segmentWidthsArray = mutableSegmentWidths
        } else if type == .images {
            for sectionImage in sectionImages {
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(imageWidth, segmentWidth)
            }
        } else if type == .textImages && segmentWidthStyle == .fixed {
            // lets just use the title.. we will assume it is wider then images...
            for idx in 0 ..< sectionTitles.count {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        } else if type == .textImages && segmentWidthStyle == .dynamic {
            var mutableSegmentWidths: [CGFloat] = []

            for idx in 0 ..< sectionTitles.count {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.right
                let sectionImage = sectionImages[0]
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left

                let combinedWidth = max(imageWidth, stringWidth)
                mutableSegmentWidths.append(combinedWidth)
            }
            segmentWidthsArray = mutableSegmentWidths
        }

        _scrollView.isScrollEnabled = isUserDraggable
        _scrollView.contentSize = CGSize(width: totalSegmentedControlWidth, height: frame.height)
    }

    var sectionCount: Int {
        if type == .text {
            return sectionTitles.count
        } else if type == .images || type == .textImages {
            return sectionImages.count
        }
        return 0
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        // Control is being removed
        if newSuperview == nil {
            return
        }

        if !sectionTitles.isEmpty || !sectionImages.isEmpty {
            updateSegmentsRects()
        }
    }

    // MARK: - Touch

    public override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        let touch = touches.first

        let touchLocation = touch?.location(in: self) ?? .zero

        let enlargeRect = CGRect(x: bounds.minX - enlargeEdgeInset.left,
                                 y: bounds.minY - enlargeEdgeInset.top,
                                 width: bounds.width + enlargeEdgeInset.left + enlargeEdgeInset.right,
                                 height: bounds.height + enlargeEdgeInset.top + enlargeEdgeInset.bottom)

        if enlargeRect.contains(touchLocation) {
            var segment = 0
            if segmentWidthStyle == .fixed {
                segment = Int((touchLocation.x + _scrollView.contentOffset.x) / segmentWidth)
            } else if segmentWidthStyle == .dynamic {
                // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
                var widthLeft = touchLocation.x + _scrollView.contentOffset.x
                for width in segmentWidthsArray {
                    widthLeft -= width

                    // When we don't have any width left to substract, we have the segment index.
                    if widthLeft <= 0 {
                        break
                    }

                    segment += 1
                }
            }

            var sectionsCount = 0

            if type == .images {
                sectionsCount = sectionImages.count
            } else if type == .textImages || type == .text {
                sectionsCount = sectionTitles.count
            }

            if segment != selectedSegmentIndex && segment < sectionsCount {
                // Check if we have to do anything with the touch event
                if isTouchEnabled {
                    setSelectedSegmentIndex(segment, animated: shouldAnimateUserSelection, notify: true)
                }
            }
        }
    }

    // MARK: - Scrolling

    var totalSegmentedControlWidth: CGFloat {
        if segmentWidthStyle == .dynamic {
            return segmentWidthsArray.reduce(0, +)
        } else {
            return CGFloat(sectionTitles.count) * segmentWidth
        }
    }

    func scrollToSelectedSegmentIndex(_ animated: Bool) {
        var rectForSelectedIndex = CGRect.zero
        var selectedSegmentOffset: CGFloat = 0
        if segmentWidthStyle == .fixed {
            rectForSelectedIndex = CGRect(
                x: segmentWidth * CGFloat(selectedSegmentIndex),
                y: 0,
                width: segmentWidth,
                height: frame.height)

            selectedSegmentOffset = (frame.width / 2) - (segmentWidth / 2)
        } else {
            var i = 0
            var offsetter: CGFloat = 0
            for width in segmentWidthsArray {
                if selectedSegmentIndex == i {
                    break
                }
                offsetter += width
                i += 1
            }

            rectForSelectedIndex = CGRect(
                x: offsetter,
                y: 0,
                width: segmentWidthsArray[selectedSegmentIndex],
                height: frame.height)

            selectedSegmentOffset = (frame.width / 2) - (segmentWidthsArray[selectedSegmentIndex] / 2)
        }

        var rectToScrollTo = rectForSelectedIndex
        rectToScrollTo.origin.x -= selectedSegmentOffset
        rectToScrollTo.size.width += selectedSegmentOffset * 2
        _scrollView.scrollRectToVisible(rectToScrollTo, animated: animated)
    }

    public func setSelectedSegmentIndex(_ index: Int, animated: Bool) {
        setSelectedSegmentIndex(index, animated: animated, notify: false)
    }

    func setSelectedSegmentIndex(_ index: Int, animated: Bool, notify: Bool) {
        _selectedSegmentIndex = index
        setNeedsDisplay()

        if index == HMSegmentedControlNoSegment {
            selectionIndicatorArrowLayer.removeFromSuperlayer()
            selectionIndicatorStripLayer.removeFromSuperlayer()
            selectionIndicatorBoxLayer.removeFromSuperlayer()
        } else {
            scrollToSelectedSegmentIndex(animated)

            if animated {
                // If the selected segment layer is not added to the super layer, that means no
                // index is currently selected, so add the layer then move it to the new
                // segment index without animating.
                if selectionStyle == .arrow {

                    if selectionIndicatorArrowLayer.superlayer == nil {
                        _scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
                    }
                    setSelectedSegmentIndex(index, animated: false, notify: true)
                    return
                } else {
                    if selectionIndicatorStripLayer.superlayer == nil {
                        _scrollView.layer.addSublayer(selectionIndicatorStripLayer)

                        if selectionStyle == .box && selectionIndicatorBoxLayer.superlayer == nil {
                            _scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
                        }

                        setSelectedSegmentIndex(index, animated: false, notify: true)
                        return
                    }
                }

                if notify {
                    notifyForSegmentChange(to: index)
                }

                // Restore CALayer animations
                selectionIndicatorArrowLayer.actions = nil
                selectionIndicatorStripLayer.actions = nil
                selectionIndicatorBoxLayer.actions = nil

                // Animate to new position
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)

                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
                setArrowFrame()
                selectionIndicatorBoxLayer.frame = frameForSelectionIndicator
                selectionIndicatorStripLayer.frame = frameForSelectionIndicator
                selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator
                CATransaction.commit()
            } else {
                // Disable CALayer animations
                let newActions = [
                    "position": NSNull(),
                    "bounds": NSNull()
                ]
                selectionIndicatorArrowLayer.actions = newActions
                setArrowFrame()

                selectionIndicatorStripLayer.actions = newActions
                selectionIndicatorStripLayer.frame = frameForSelectionIndicator

                selectionIndicatorBoxLayer.actions = newActions
                selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator

                if notify {
                    notifyForSegmentChange(to: index)
                }
            }
        }
    }

    func notifyForSegmentChange(to index: Int) {
        if superview != nil {
            sendActions(for: .valueChanged)
        }

        indexChangeHandle?(index)
    }

    // MARK: - Styling Support
    var resultingTitleTextAttributes: HMAttributes {
        var resultingAttrs: HMAttributes = [
            .font:UIFont(name: "Avenir Next Bold", size: 14),
            .foregroundColor: UIColor.red
        ]

        if let titleTextAttributes = titleTextAttributes {
            resultingAttrs.merge(titleTextAttributes) { (_, new) in new }
        }

        return resultingAttrs
    }

    var resultingSelectedTitleTextAttributes: HMAttributes {
        var resultingAttrs = resultingTitleTextAttributes

        if let selectedTitleTextAttributes = selectedTitleTextAttributes {
            resultingAttrs.merge(selectedTitleTextAttributes) { (_, new) in new }
        }

        return resultingAttrs
    }
}
