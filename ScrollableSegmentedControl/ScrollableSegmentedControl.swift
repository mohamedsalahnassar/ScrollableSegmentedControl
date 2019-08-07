//
//  ScrollableSegmentedControl.swift
//  ScrollableSegmentedControl
//
//  Created by Goce Petrovski on 10/11/16.
//  Copyright © 2017 Pomarium. All rights reserved.
//

import UIKit

@objc
public enum ScrollableSegmentedControlSegmentStyle: Int {
    case textOnly, imageOnly, imageOnTop, imageOnLeft
}

/**
 A ScrollableSegmentedControl object is horizontaly scrollable control made of multiple segments, each segment functioning as discrete button.
 */
@IBDesignable
@objc public class ScrollableSegmentedControl: UIControl {
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate var collectionView: UICollectionView?
    private var collectionViewController: CollectionViewController?
    private var segmentsData = [SegmentData]()
    private var longestTextWidth: CGFloat = 10
    
    /**
     A Boolean value that determines if the width of all segments is going to be fixed or not.
     
     When this value is set to true all segments have the same width which equivalent of the width required to display the text that requires the longest width to be drawn.
     The default value is true.
     */
    public var fixedSegmentWidth: Bool = true {
        didSet {
            if oldValue != fixedSegmentWidth {
                setNeedsLayout()
            }
        }
    }
    
    
    @objc public var segmentStyle: ScrollableSegmentedControlSegmentStyle = .textOnly {
        didSet {
            if oldValue != segmentStyle {
                if let collectionView_ = collectionView {
                    let nilCellClass: AnyClass? = nil
                    // unregister the old cell
                    switch oldValue {
                    case .textOnly:
                        collectionView_.register(nilCellClass, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
                    case .imageOnly:
                        collectionView_.register(nilCellClass, forCellWithReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier)
                    case .imageOnTop:
                        collectionView_.register(nilCellClass, forCellWithReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier)
                    case .imageOnLeft:
                        collectionView_.register(nilCellClass, forCellWithReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier)
                    }
                    
                    // register the new cell
                    switch segmentStyle {
                    case .textOnly:
                        collectionView_.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
                    case .imageOnly:
                        collectionView_.register(ImageOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier)
                    case .imageOnTop:
                        collectionView_.register(ImageOnTopSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier)
                    case .imageOnLeft:
                        collectionView_.register(ImageOnLeftSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier)
                    }
                    
                    let indexPath = collectionView?.indexPathsForSelectedItems?.last
                    
                    setNeedsLayout()
                    
                    if indexPath != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                        })
                    }
                }
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            collectionView?.tintColor = tintColor
            reloadSegments()
        }
    }
    
    fileprivate var _segmentBackgroundColor: UIColor  = .white
    @objc public dynamic var segmentBackgroundColor: UIColor {
        get { return _segmentBackgroundColor }
        set {
            _segmentBackgroundColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _selectedSegmentBackgroundColor: UIColor = .white
    @objc public dynamic var selectedSegmentBackgroundColor: UIColor {
        get { return _selectedSegmentBackgroundColor }
        set {
            _selectedSegmentBackgroundColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _segmentTitleColor: UIColor?
    @objc public dynamic var segmentTitleColor: UIColor? {
        get { return _segmentTitleColor }
        set {
            _segmentTitleColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _segmentBorderColor: UIColor = .gray
    @objc public dynamic var segmentBorderColor: UIColor {
        get { return _segmentBorderColor }
        set {
            _segmentBorderColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _segmentBorderWidth: NSNumber = 0.0
    @objc public dynamic var segmentBorderWidth: NSNumber {
        get { return _segmentBorderWidth }
        set {
            _segmentBorderWidth = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _segmentCornerRadius: NSNumber = 0.0
    @objc public dynamic var segmentCornerRadius: NSNumber {
        get { return _segmentCornerRadius }
        set {
            _segmentCornerRadius = newValue
            reloadSegments()
        }
    }
    

    fileprivate var _underlineHeight: CGFloat = 4.0
    @objc public dynamic var underlineHeight: CGFloat {
        get { return _underlineHeight }
        set {
            if newValue != _underlineHeight {
                _underlineHeight = newValue
                reloadSegments()
            }
        }
    }
    
    fileprivate var _selectedSegmentTitleColor: UIColor?
    @objc public dynamic var selectedSegmentTitleColor: UIColor? {
        get { return _selectedSegmentTitleColor }
        set {
            _selectedSegmentTitleColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _selectedSegmentBorderColor: UIColor?
    @objc public dynamic var selectedSegmentBorderColor: UIColor? {
        get { return _selectedSegmentBorderColor }
        set {
            _selectedSegmentBorderColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _selectedSegmentBorderWidth: NSNumber?
    @objc public dynamic var selectedSegmentBorderWidth: NSNumber? {
        get { return _selectedSegmentBorderWidth }
        set {
            _selectedSegmentBorderWidth = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _selectedSegmentCornerRadius: NSNumber?
    @objc public dynamic var selectedSegmentCornerRadius: NSNumber? {
        get { return _selectedSegmentCornerRadius }
        set {
            _selectedSegmentCornerRadius = newValue
            reloadSegments()
        }
    }
    

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate var normalAttributes: [NSAttributedString.Key : Any]?
    fileprivate var highlightedAttributes: [NSAttributedString.Key : Any]?
    fileprivate var selectedAttributes: [NSAttributedString.Key : Any]?
    fileprivate var _titleAttributes: [UInt: [NSAttributedString.Key : Any]] = [UInt: [NSAttributedString.Key : Any]]()
    @objc public func setTitleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) {
        _titleAttributes[state.rawValue] = attributes
        
        normalAttributes = _titleAttributes[UIControl.State.normal.rawValue]
        highlightedAttributes = _titleAttributes[UIControl.State.highlighted.rawValue]
        selectedAttributes = _titleAttributes[UIControl.State.selected.rawValue]
        
        for segment in segmentsData {
            configureAttributedTitlesForSegment(segment)
            
            if let title = segment.title {
                calculateLongestTextWidth(text: title)
            }
        }
        
        flowLayout.invalidateLayout()
        reloadSegments()
    }
    
    private func configureAttributedTitlesForSegment(_ segment:SegmentData) {
        segment.normalAttributedTitle = nil
        segment.highlightedAttributedTitle = nil
        segment.selectedAttributedTitle = nil
        
        if let title = segment.title {
            if normalAttributes != nil {
                segment.normalAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
            }
            
            if highlightedAttributes != nil {
                segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
            } else {
                if selectedAttributes != nil {
                    segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
            
            if selectedAttributes != nil {
                segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
            } else {
                if highlightedAttributes != nil {
                    segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
        }
    }
    
    @objc public func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key : Any]? {
        return _titleAttributes[state.rawValue]
    }
    
    // MARK: - Managing Segments
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content.
     */
    @objc public func insertSegment(withTitle title: String, at index: Int) {
        let segment = SegmentData()
        segment.title = title
        configureAttributedTitlesForSegment(segment)
        segmentsData.insert(segment, at: index)
        calculateLongestTextWidth(text: title)
        reloadSegments()
    }
    
    /**
     Inserts a segment at a specified position in the receiver and gives it an image as content.
     */
    @objc public func insertSegment(with image: UIImage, at index: Int) {
        let segment = SegmentData()
        segment.image = image.withRenderingMode(.alwaysTemplate)
        segmentsData.insert(segment, at: index)
        reloadSegments()
    }
    
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content and/or image as content.
     */
    @objc public func insertSegment(withTitle title: String?, image: UIImage?, at index: Int) {
        let segment = SegmentData()
        segment.title = title
        segment.image = image?.withRenderingMode(.alwaysTemplate)
        segmentsData.insert(segment, at: index)
        
        if let str = title {
            calculateLongestTextWidth(text: str)
        }
        reloadSegments()
    }
    
    /**
     Removes segment at a specific position from the receiver.
     */
    @objc public func removeSegment(at index: Int){
        segmentsData.remove(at: index)
        if(selectedSegmentIndex == index) {
            selectedSegmentIndex = selectedSegmentIndex - 1
        } else if(selectedSegmentIndex > segmentsData.count) {
            selectedSegmentIndex = -1
        }
        reloadSegments()
    }
    
    /**
     Returns the number of segments the receiver has.
     */
    @objc public var numberOfSegments: Int { return segmentsData.count }
    
    /**
     Returns the title of the specified segment.
     */
    @objc public func titleForSegment(at segment: Int) -> String? {
        if segmentsData.count == 0 {
            return nil
        }
        
        return safeSegmentData(forIndex: segment).title
    }
    
    
    /**
     The index number identifying the selected segment (that is, the last segment touched).
     
     Set this property to -1 to turn off the current selection.
     */
    @objc public var selectedSegmentIndex: Int = -1 {
        didSet{
            if selectedSegmentIndex < -1 {
                selectedSegmentIndex = -1
            } else if selectedSegmentIndex > segmentsData.count - 1 {
                selectedSegmentIndex = segmentsData.count - 1
            }
            
            if selectedSegmentIndex >= 0 {
                var scrollPossition: UICollectionView.ScrollPosition = .bottom
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                if let atribs = collectionView?.layoutAttributesForItem(at: indexPath) {
                    let frame = atribs.frame
                    if frame.origin.x < collectionView!.contentOffset.x {
                        scrollPossition = .left
                    } else if frame.origin.x + frame.size.width > (collectionView!.frame.size.width + collectionView!.contentOffset.x) {
                        scrollPossition = .right
                    }
                }
                
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: scrollPossition)
            } else {
                if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
                    collectionView?.deselectItem(at: indexPath, animated: true)
                }
            }
            
            if oldValue != selectedSegmentIndex {
                self.sendActions(for: .valueChanged)
            }
        }
    }
    
    /**
     Configure if the selected segment should have underline. Default value is false.
     */
    @IBInspectable
    @objc public var underlineSelected: Bool = false
    
    // MARK: - Layout management
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let collectionView_ = collectionView else {
            return
        }
        
        collectionView_.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        collectionView_.contentOffset = CGPoint(x: 0, y: 0)
        collectionView_.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        flowLayout.invalidateLayout()
        configureSegmentSize()
        reloadSegments()
    }
    
    // MARK: - Private
    
    fileprivate func configure() {
        clipsToBounds = true
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView!.tag = 1
        collectionView!.tintColor = tintColor
        collectionView!.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
        collectionViewController = CollectionViewController(segmentedControl: self)
        collectionView!.dataSource = collectionViewController
        collectionView!.delegate = collectionViewController
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
    }
    
    fileprivate func configureSegmentSize() {
        let width: CGFloat
        
        if fixedSegmentWidth == true {
            switch segmentStyle {
            case .imageOnLeft:
                width = longestTextWidth + BaseSegmentCollectionViewCell.imageSize + BaseSegmentCollectionViewCell.imageToTextMargin * 2
            default:
                if collectionView!.frame.size.width > longestTextWidth * CGFloat(segmentsData.count) {
                    width = collectionView!.frame.size.width / CGFloat(segmentsData.count)
                } else {
                    width = longestTextWidth
                }
            }
            
            flowLayout.estimatedItemSize = CGSize()
            flowLayout.itemSize = CGSize(width: width, height: frame.size.height)
        } else {
            width = 1.0
            flowLayout.itemSize = CGSize(width: width, height: frame.size.height)
            flowLayout.estimatedItemSize = CGSize(width: width, height: frame.size.height)
        }
    }
    
    fileprivate func calculateLongestTextWidth(text: String) {
        let fontAttributes: [NSAttributedString.Key:Any]
        if normalAttributes != nil {
            fontAttributes = normalAttributes!
        } else  if highlightedAttributes != nil {
            fontAttributes = highlightedAttributes!
        } else if selectedAttributes != nil {
            fontAttributes = selectedAttributes!
        } else {
            fontAttributes =  [NSAttributedString.Key.font: BaseSegmentCollectionViewCell.defaultFont]
        }
        
        let size = (text as NSString).size(withAttributes: fontAttributes)
        let newLongestTextWidth = 2.0 + size.width + BaseSegmentCollectionViewCell.textPadding * 2
        if newLongestTextWidth > longestTextWidth {
            longestTextWidth = newLongestTextWidth
            configureSegmentSize()
        }
    }
    
    private func safeSegmentData(forIndex index: Int) -> SegmentData {
        let segmentData: SegmentData
        
        if index <= 0 {
            segmentData = segmentsData[0]
        } else if index >= segmentsData.count {
            segmentData = segmentsData[segmentsData.count - 1]
        } else {
            segmentData = segmentsData[index]
        }
        
        return segmentData
    }
    
    fileprivate func reloadSegments() {
        if let collectionView_ = collectionView {
            collectionView_.reloadData()
            if selectedSegmentIndex >= 0 {
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                collectionView_.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
    
    /*
     Private internal classes to be used only by this class.
     */
    
    // MARK: - SegmentData
    
    final private class SegmentData {
        var title: String?
        var normalAttributedTitle: NSAttributedString?
        var highlightedAttributedTitle: NSAttributedString?
        var selectedAttributedTitle: NSAttributedString?
        var image: UIImage?
    }
    
    // MARK : - CollectionViewController
    
    /**
     A CollectionViewController is private inner class with main purpose to hide UICollectionView protocol conformances.
     */
    final private class CollectionViewController : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        static let textOnlyCellIdentifier = "textOnlyCellIdentifier"
        static let imageOnlyCellIdentifier = "imageOnlyCellIdentifier"
        static let imageOnTopCellIdentifier = "imageOnTopCellIdentifier"
        static let imageOnLeftCellIdentifier = "imageOnLeftCellIdentifier"
        
        private weak var segmentedControl: ScrollableSegmentedControl!
        
        init(segmentedControl:ScrollableSegmentedControl) {
            self.segmentedControl = segmentedControl
        }
        
        // UICollectionViewDataSource
        
        fileprivate func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        
        fileprivate func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return segmentedControl.numberOfSegments
        }
        
        fileprivate func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let segmentCell:BaseSegmentCollectionViewCell
            let data = segmentedControl.segmentsData[indexPath.item]
            
            switch segmentedControl.segmentStyle {
            case .textOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.textOnlyCellIdentifier, for: indexPath) as! TextOnlySegmentCollectionViewCell
                cell.titleLabel.text = data.title
                segmentCell = cell
            case .imageOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier, for: indexPath) as! ImageOnlySegmentCollectionViewCell
                cell.imageView.image = data.image
                segmentCell = cell
            case .imageOnTop:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier, for: indexPath) as! ImageOnTopSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                
                segmentCell = cell
            case .imageOnLeft:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier, for: indexPath) as! ImageOnLeftSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                
                segmentCell = cell
            }
            segmentCell.underlineHeight = segmentedControl.underlineHeight
            segmentCell.showUnderline = segmentedControl.underlineSelected
            if segmentedControl.underlineSelected {
                segmentCell.tintColor = segmentedControl.tintColor
            }
            
            
            segmentCell.contentColor = segmentedControl.segmentTitleColor
            segmentCell.selectedContentColor = segmentedControl.selectedSegmentTitleColor
            
            segmentCell.containerViewBackgroundColor = segmentedControl.segmentBackgroundColor
            segmentCell.selectedContainerViewBackgroundColor = segmentedControl.selectedSegmentBackgroundColor

            segmentCell.containerViewBorderColor = segmentedControl.segmentBorderColor
            segmentCell.containerViewBorderWidth = CGFloat(truncating: segmentedControl.segmentBorderWidth)
            segmentCell.containerViewCornerRadius = CGFloat(truncating: segmentedControl.segmentCornerRadius)
            
            segmentCell.selectedContainerViewBorderColor = segmentedControl.selectedSegmentBorderColor ?? UIColor.black
            segmentCell.selectedContainerViewBorderWidth = CGFloat(truncating: segmentedControl.selectedSegmentBorderWidth ?? segmentedControl.segmentBorderWidth)
            segmentCell.selectedContainerViewCornerRadius = CGFloat(truncating: segmentedControl.selectedSegmentCornerRadius ?? segmentedControl.segmentCornerRadius)
            

            segmentCell.normalAttributedTitle = data.normalAttributedTitle
            segmentCell.highlightedAttributedTitle = data.highlightedAttributedTitle
            segmentCell.selectedAttributedTitle = data.selectedAttributedTitle
            
            return segmentCell
        }
        
        // MARK UICollectionViewDelegate
        
        fileprivate func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            segmentedControl.selectedSegmentIndex = indexPath.item
        }
        
        fileprivate func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            var label: UILabel?
            if let _cell = cell as? TextOnlySegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnTopSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnLeftSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else {
                label = nil
            }
            
            if let titleLabel = label {
                let data = segmentedControl.segmentsData[indexPath.item]
                
                if cell.isHighlighted && data.highlightedAttributedTitle != nil {
                    titleLabel.attributedText = data.highlightedAttributedTitle!
                } else if cell.isSelected && data.selectedAttributedTitle != nil {
                    titleLabel.attributedText = data.selectedAttributedTitle!
                } else {
                    if data.normalAttributedTitle != nil {
                        titleLabel.attributedText = data.normalAttributedTitle!
                    }
                }
            }
        }
    }
    
    
    // MARK: - SegmentCollectionViewCell
    
    private class BaseSegmentCollectionViewCell: UICollectionViewCell {
        static let textPadding: CGFloat = 8.0
        static let imageToTextMargin: CGFloat = 14.0
        static let imageSize: CGFloat = 14.0
        static let defaultFont = UIFont.systemFont(ofSize: 14)
        static let defaultTextColor = UIColor.darkGray
        
        var underlineView: UIView?
        var underlineHeight: CGFloat = 4.0 {
            didSet {
                if oldValue != underlineHeight {
                    setNeedsUpdateConstraints()
                }
            }
        }
        var containerView: UIView = UIView()
        var containerViewPadding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 ) {
            didSet {
                if oldValue != containerViewPadding {
                    setNeedsUpdateConstraints()
                }
            }
        }
        var containerViewBackgroundColor: UIColor? {
            didSet {
                if oldValue != containerViewBackgroundColor {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var containerViewCornerRadius: CGFloat? {
            didSet {
                if oldValue != containerViewCornerRadius {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var containerViewBorderWidth: CGFloat? {
            didSet {
                if oldValue != containerViewBorderWidth {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var containerViewBorderColor: UIColor? {
            didSet {
                if oldValue != containerViewBorderColor {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var selectedContainerViewBackgroundColor: UIColor? {
            didSet {
                if oldValue != selectedContainerViewBackgroundColor {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var selectedContainerViewCornerRadius: CGFloat? {
            didSet {
                if oldValue != selectedContainerViewCornerRadius {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var selectedContainerViewBorderWidth: CGFloat? {
            didSet {
                if oldValue != selectedContainerViewBorderWidth {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        var selectedContainerViewBorderColor: UIColor? {
            didSet {
                if oldValue != selectedContainerViewBorderColor {
                    setupContainerView()
                    setNeedsUpdateConstraints()
                }
            }
        }
        public var contentColor: UIColor?
        public var selectedContentColor: UIColor?
        
        var normalAttributedTitle: NSAttributedString?
        var highlightedAttributedTitle: NSAttributedString?
        var selectedAttributedTitle: NSAttributedString?
        var variableConstraints = [NSLayoutConstraint]()
        
        var showUnderline: Bool = false {
            didSet {
                if oldValue != showUnderline {
                    if oldValue == false && underlineView != nil {
                        underlineView?.removeFromSuperview()
                    } else {
                        underlineView = UIView()
                        underlineView!.tag = 999
                        underlineView!.backgroundColor = tintColor
                        underlineView!.isHidden = !isSelected
                        containerView.insertSubview(underlineView!, at: contentView.subviews.count)
                    }
                    
                    configureConstraints()
                }
            }
        }
        
        override var tintColor: UIColor! {
            didSet{
                underlineView?.backgroundColor = tintColor
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            configure()
        }
        
        func configure() {
            setupContainerView()
            contentView.insertSubview(containerView, at: contentView.subviews.count)
            configureConstraints()
        }
        
        func setupContainerView() {
            if isSelected {
                containerView.backgroundColor = selectedContainerViewBackgroundColor
                containerView.layer.borderWidth = selectedContainerViewBorderWidth ?? (containerViewBorderWidth ?? 0.0)
                containerView.layer.borderColor = selectedContainerViewBorderColor?.cgColor ?? (containerViewBorderColor?.cgColor ?? UIColor.white.cgColor)
                containerView.layer.cornerRadius = selectedContainerViewCornerRadius ?? (containerViewCornerRadius ?? 0.0)
            } else {
                containerView.backgroundColor = containerViewBackgroundColor
                containerView.layer.borderWidth = containerViewBorderWidth ?? 0.0
                containerView.layer.borderColor = containerViewBorderColor?.cgColor ?? UIColor.white.cgColor
                containerView.layer.cornerRadius = containerViewCornerRadius ?? 0.0
            }
        }
        
        private func configureConstraints() {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerViewPadding.top).isActive = true
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerViewPadding.left).isActive = true
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerViewPadding.right).isActive = true
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -containerViewPadding.bottom).isActive = true
            if let underline = underlineView {
                underline.translatesAutoresizingMaskIntoConstraints = false
                underline.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
                underline.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
                underline.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            }
        }
        
        override func setNeedsUpdateConstraints() {
            super.setNeedsUpdateConstraints()
            NSLayoutConstraint.deactivate(variableConstraints)
            variableConstraints.removeAll()
        }
        
        override var isHighlighted: Bool {
            didSet {
                underlineView?.isHidden = !isHighlighted && !isSelected
            }
        }
        
        override var isSelected: Bool {
            didSet {
                setupContainerView()
                underlineView?.isHidden = !isSelected
            }
        }
    }
    
    private class TextOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        
        override var contentColor: UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var selectedContentColor: UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                }
            }
        }
        
        override func configure(){
            super.configure()
            containerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = BaseSegmentCollectionViewCell.defaultTextColor
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            titleLabel.textAlignment = .center
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            NSLayoutConstraint.deactivate(variableConstraints)
            variableConstraints.removeAll()
            
            variableConstraints.append(titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
            variableConstraints.append(titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
            variableConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding))
            variableConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BaseSegmentCollectionViewCell.textPadding))
            
            if let underline = underlineView {
                variableConstraints.append(underline.heightAnchor.constraint(equalToConstant: underlineHeight))
            }
            NSLayoutConstraint.activate(variableConstraints)
        }
    }
    
    private class ImageOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let imageView = UIImageView()
        
        override var contentColor: UIColor? {
            didSet {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override func configure(){
            super.configure()
            
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = BaseSegmentCollectionViewCell.defaultTextColor
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            NSLayoutConstraint.deactivate(variableConstraints)
            variableConstraints.removeAll()
            
            variableConstraints.append(imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
            variableConstraints.append(imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
            variableConstraints.append(imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding))
            variableConstraints.append(contentView.trailingAnchor.constraint(greaterThanOrEqualTo: imageView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding))
            
            if let underline = underlineView {
                variableConstraints.append(underline.heightAnchor.constraint(equalToConstant: underlineHeight))
            }
            
            NSLayoutConstraint.activate(variableConstraints)
        }
    }
    
    private class BaseImageSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        let imageView = UIImageView()
        internal let stackView = UIStackView()
        
        override var contentColor: UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var selectedContentColor: UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
                
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override func configure(){
            super.configure()
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.distribution = .fill
            stackView.spacing = BaseSegmentCollectionViewCell.textPadding
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleLabel)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            NSLayoutConstraint.deactivate(variableConstraints)
            variableConstraints.removeAll()
            
            variableConstraints.append(stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
            variableConstraints.append(stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
            variableConstraints.append(stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding))
            variableConstraints.append(contentView.trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding))
            
            if let underline = underlineView {
                variableConstraints.append(underline.heightAnchor.constraint(equalToConstant: underlineHeight))
            }
            
            NSLayoutConstraint.activate(variableConstraints)
        }
    }
    
    private class ImageOnTopSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
        override func configure() {
            super.configure()
            stackView.axis = .vertical
        }
    }
    
    private class ImageOnLeftSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
        override func configure(){
            super.configure()
            var imgFrame = imageView.frame
            imgFrame.size = CGSize(width: BaseSegmentCollectionViewCell.imageSize, height: BaseSegmentCollectionViewCell.imageSize)
            imageView.frame = imgFrame
            imageView.heightAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            
            stackView.axis = .horizontal
        }
    }
}
