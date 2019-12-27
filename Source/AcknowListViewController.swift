//
// AcknowListViewController.swift
//
// Copyright (c) 2015-2019 Vincent Tourraine (http://www.vtourraine.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/// Subclass of `UITableViewController` that displays a list of acknowledgements.
open class AcknowListViewController: UITableViewController {

    /// The represented array of `Acknow`.
    open var acknowledgements: [Acknow]?

    /**
     Acknowledgements plist file name whose contents to be loaded.
     It expects to get set by "User Defined Runtime Attributes" in Interface Builder.
     */
    @IBInspectable var acknowledgementsPlistName: String?


    // MARK: - Initialization

    /**
     Initializes the `AcknowListViewController` instance based on default configuration.

     - returns: The new `AcknowListViewController` instance.
     */
    public convenience init() {
        let path = AcknowListViewController.defaultAcknowledgementsPlistPath()
        self.init(acknowledgementsPlistPath: path)
    }

    /**
     Initializes the `AcknowListViewController` instance for the plist file based on its name.

     - returns: The new `AcknowListViewController` instance.
     */
    public convenience init(fileNamed fileName: String) {
        let path = AcknowListViewController.acknowledgementsPlistPath(name: fileName)
        self.init(acknowledgementsPlistPath: path)
    }

    /**
     Initializes the `AcknowListViewController` instance for a plist file path.

     - parameter acknowledgementsPlistPath: The path to the acknowledgements plist file.

     - returns: The new `AcknowListViewController` instance.
     */
    public init(acknowledgementsPlistPath: String?) {
        super.init(style: .grouped)

        if let acknowledgementsPlistPath = acknowledgementsPlistPath {
            commonInit(acknowledgementsPlistPaths: [acknowledgementsPlistPath])
        }
        else {
            commonInit(acknowledgementsPlistPaths: [])
        }
    }

    /**
     Initializes the `AcknowListViewController` instance for a set of plist file paths.

     The first path is the "main" one which will be used for any custom header/footer.

     - parameter acknowledgementsPlistPaths: The paths to the acknowledgements plist files.

     - returns: The new `AcknowListViewController` instance.
     */
    public init(acknowledgementsPlistPaths: [String]) {
        super.init(style: .grouped)
        commonInit(acknowledgementsPlistPaths: acknowledgementsPlistPaths)
    }

    /**
     Initializes the `AcknowListViewController` instance with a coder.

     - parameter aDecoder: The archive coder.

     - returns: The new `AcknowListViewController` instance.
     */
    public required init(coder aDecoder: NSCoder) {
        super.init(style: .grouped)
        let path = AcknowListViewController.defaultAcknowledgementsPlistPath()
        if let path = path {
            commonInit(acknowledgementsPlistPaths: [path])
        }
        else {
            commonInit(acknowledgementsPlistPaths: [])
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    func commonInit(acknowledgementsPlistPaths: [String]) {
        title = AcknowLocalization.localizedTitle()

        guard !acknowledgementsPlistPaths.isEmpty else { return }

        var acknowledgements: [Acknow] = []
        for path in acknowledgementsPlistPaths {
            let parser = AcknowParser(plistPath: path)
            acknowledgements.append(contentsOf: parser.parseAcknowledgements())
        }

        let sortedAcknowledgements = acknowledgements.sorted(by: {
            (ack1: Acknow, ack2: Acknow) -> Bool in
            let result = ack1.title.compare(
                ack2.title,
                options: [],
                range: nil,
                locale: Locale.current)
            return (result == ComparisonResult.orderedAscending)
        })
        self.acknowledgements = sortedAcknowledgements
    }

    // MARK: - Paths

    class func acknowledgementsPlistPath(name:String) -> String? {
        return Bundle.main.path(forResource: name, ofType: "plist")
    }

    class func bundleName() -> String? {
        let infoDictionary = Bundle.main.infoDictionary

        if let cfBundleName = infoDictionary?["CFBundleName"] as? String {
            return cfBundleName
        }
        else if let cfBundleExecutable = infoDictionary?["CFBundleExecutable"] as? String {
            return cfBundleExecutable
        }
        else {
            return nil
        }
    }

    class func defaultAcknowledgementsPlistPath() -> String? {
        guard let bundleName = bundleName() else {
            return nil
        }

        let defaultAcknowledgementsPlistName = "Pods-\(bundleName)-acknowledgements"
        let defaultAcknowledgementsPlistPath = acknowledgementsPlistPath(name: defaultAcknowledgementsPlistName)

        if let defaultAcknowledgementsPlistPath = defaultAcknowledgementsPlistPath,
            FileManager.default.fileExists(atPath: defaultAcknowledgementsPlistPath) == true {
            return defaultAcknowledgementsPlistPath
        }
        else {
            // Legacy value
            return acknowledgementsPlistPath(name: "Pods-acknowledgements")
        }
    }

    // MARK: - View life cycle

    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override open func awakeFromNib() {
        super.awakeFromNib()

        let path: String?
        if let acknowledgementsPlistName = self.acknowledgementsPlistName {
            path = AcknowListViewController.acknowledgementsPlistPath(name: acknowledgementsPlistName)
        }
        else {
            path = AcknowListViewController.defaultAcknowledgementsPlistPath()
        }

        if let path = path {
            commonInit(acknowledgementsPlistPaths: [path])
        }
    }

    /// Called after the controller's view is loaded into memory.
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Register the cell before use it
        let identifier = String(describing: AcknowCell.self)
        tableView.register(AcknowCell.classForCoder(), forCellReuseIdentifier: identifier)
        tableView.separatorStyle = .none
        if let navigationController = self.navigationController {
            if presentingViewController != nil && navigationController.viewControllers.first == self {
                let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AcknowListViewController.dismissViewController(_:)))
                navigationItem.leftBarButtonItem = item
            }
        }
    }

    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.

     - parameter animated: If `YES`, the view is being added to the window using an animation.
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /**
     Notifies the view controller that its view was added to a view hierarchy.

     - parameter animated: If `YES`, the view is being added to the window using an animation.
     */
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if acknowledgements == nil {
            print(
                "** AcknowList Warning **\n" +
                "No acknowledgements found.\n" +
                "This probably means that you didn’t import the `Pods-acknowledgements.plist` to your main target.\n" +
                "Please take a look at https://github.com/vtourraine/AcknowList for instructions.", terminator: "\n")
        }
    }

    // MARK: - Actions

    /**
     Opens the CocoaPods website with Safari.

     - parameter sender: The event sender.
     */
    @IBAction open func openCocoaPodsWebsite(_ sender: AnyObject) {
        let url = URL(string: AcknowLocalization.CocoaPodsURLString())
        if let url = url {
            if #available(iOS 10.0, tvOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    /**
     Dismisses the view controller.

     - parameter sender: The event sender.
     */
    @IBAction open func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    /**
     Asks the data source to return the number of sections in the table view.

     - parameter tableView: An object representing the table view requesting this information.

     - returns: The number of sections in `tableView`. The default value is 1.
     */
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let acknowledgements = self.acknowledgements {
            return acknowledgements.count
        }

        return 0
    }

    /**
     Asks the data source for a cell to insert in a particular location of the table view.

     - parameter tableView: The table-view object requesting the cell.
     - parameter indexPath: An index path that locates a row in `tableView`.

     - returns: An object inheriting from `UITableViewCell` that the table view can use for the specified row. An assertion is raised if you return `nil`.
     */
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: AcknowCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AcknowCell

        if let acknowledgements = self.acknowledgements,
            let acknowledgement = acknowledgements[(indexPath as NSIndexPath).row] as Acknow? {
            cell.acknowledgement = acknowledgement
        }

        return cell
    }

    /**
     Asks the delegate for the estimated height of a row in a specified location.

     - parameter tableView: The table-view object requesting this information.
     - parameter indexPath: An index path that locates a row in `tableView`.

     - returns: A nonnegative floating-point value that estimates the height (in points) that `row` should be. Return `UITableViewAutomaticDimension` if you have no estimate.
     */
    open override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
