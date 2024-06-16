import UIKit

class SectionedList: UIView {
    @IBOutlet var tableView: UITableView! {
        didSet {
//            tableView.register(UINib(nibName: "HomeSectionCell", bundle: nil), forCellReuseIdentifier: "HomeSectionCell")
        }
    }
    private(set) var sections: [any ListCollectionSection] = []
    var delegate: ItemSelctionDelegate?
    func display(sections: [any ListCollectionSection]) {
        self.sections = sections
        tableView.reloadData()
        setUpAppearance()
        if sections.isEmpty {
            let label = UILabel()
            label.text = "Nothing to display for now.\nPlease pull down from top to refresh again."
            label.numberOfLines = 0
            label.textColor = .lightGray.withAlphaComponent(0.5)
            label.sizeToFit()
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func setUpAppearance() {
        tableView.showsVerticalScrollIndicator = false
        addPadding()
    }
    
    func addPadding() {
        // Set the desired extra space value
        let topSpace: CGFloat = 0.0
        let bottomSpace: CGFloat = 60.0

        // Create an UIEdgeInsets with the desired top inset
        let insets = UIEdgeInsets(top: topSpace, left: 0, bottom: bottomSpace, right: 0)

        // Set the content inset of the table view
        tableView.contentInset = insets
    }
    func reloadData() {
        tableView.reloadData()
    }
}
extension SectionedList: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSectionCell") as! HomeSectionCell
        let section = sections[indexPath.row]
        cell.load(section: section)
        cell.delegate = delegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
}
extension SectionedList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }    
}
