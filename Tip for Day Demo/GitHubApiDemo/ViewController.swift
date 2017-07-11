//
//  ViewController.swift
//  GitHubApiDemo
//
//  Created by alexiuce  on 2017/6/23.
//  Copyright © 2017年 com.Alexiuce. All rights reserved.
//

import Cocoa
import WebKit
import Alamofire
import SwiftyJSON


class ViewController: NSViewController {

     @IBOutlet weak var topBox: NSView!
    @IBOutlet weak var webView: WebView!
    
    @IBOutlet weak var leftTable: NSTableView!
    
    @IBOutlet weak var searchBar : NSSearchField!
    @IBOutlet weak var languagePopButton : NSPopUpButton!
    @IBOutlet weak var sortPopButton : NSPopUpButton!
    
    
    @IBOutlet weak var outlineView : NSOutlineView!
    
    var cellModels : [RespositoryModel]?
    var caculateCell : RespositoryCell?
    
    lazy var topModel : [RootModel] = {
        var temp = [RootModel]()
        let  rm = RootModel()
        rm.name = "Language"
        rm.childeren = ["OC","Swifit"]
        temp.append(rm)
        
        let rm1 = RootModel()
        rm1.name = "Favorite"
        rm1.childeren = ["AFNetworking","Kingfisher","SwiftyJson"]
        temp.append(rm1)
        
        let rm2 = RootModel()
        rm2.name = "My Respository"
        temp.append(rm2)
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      let server = "https://github.com"
        let url = URL(string: server)!
        let requet = URLRequest(url: url)
        webView.mainFrame.load(requet)
    
        let cellNib = NSNib(nibNamed:"RespositoryCell", bundle: nil)
        leftTable.register(cellNib, forIdentifier: "respositoryCell")
        outlineView.rowHeight = 35
        cellModels = []
        
       
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            XCPrint("dlefaeladsf")
        }
    }
    
    
    @IBAction func beginSearch(_ sender : NSButton){
        self.searchRespositories(searchBar.stringValue)
    }
    
}

extension ViewController : WebPolicyDelegate{
    func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        let host = request.url!.host! as NSString
        if host .isEqual(to: "alexiuce.github.io") {
            XCPrint("alexicuce")
            listener.ignore()
        }else{
            listener.use()
        }
    }
}

extension ViewController : NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cellModels == nil ? 0 : cellModels!.count
    }
}

extension ViewController : NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "respositoryCell", owner: self) as! RespositoryCell
        cell.cellModel = cellModels?[row]
       
        return cell
    }
   
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if caculateCell == nil {
            caculateCell = (tableView.make(withIdentifier: "respositoryCell", owner: self) as! RespositoryCell)
        }
        let model = cellModels?[row]
        caculateCell?.cellModel = model
        return (model?.cellHeight)!
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let model = cellModels![leftTable.selectedRow]
        let url = URL(string: model.homeUrl)!
        let requet = URLRequest(url: url)
        webView.mainFrame.load(requet)
    }
}
// MARK: NSOutlineViewDataSource & NSOutlineViewDelegate
extension ViewController : NSOutlineViewDataSource{
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? RootModel {
            return item.childeren.count
        }
        return topModel.count
      }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? RootModel {
            return item.childeren[index]       // 这里返回的是String类型
        }
        return topModel[index]                // 这里返回的是RootModel类型
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? RootModel {
            return item.childeren.count > 0
        }

        return false
    }
    
    
}
extension ViewController : NSOutlineViewDelegate{
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell : NSTableCellView?
        if item is RootModel {
            cell = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! RootModel).name
        }else{
            cell = outlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
            cell?.textField?.stringValue = item as! String
        }
        
        return cell
    }
    
}


extension ViewController{
    fileprivate func searchRespositories(_ keywork: String){
        let baseURL = "https://api.github.com"
        let apiName = "/search/repositories"
        let para = ["q":keywork + "language:\(languagePopButton.selectedItem!.title)"]
    
     Alamofire.request(baseURL + apiName, method: .get, parameters: para).responseJSON { (response) in
            if let data = response.data {
                let json = JSON.init(data: data)
                let repos = json["items"].arrayValue
                self.cellModels?.removeAll()
                for item in repos {
                    let repoModel = RespositoryModel()
                    repoModel.title =  item["name"].stringValue
                    repoModel.language = item["language"].stringValue
                    repoModel.desc = item["description"].stringValue
                    repoModel.imageUrl = item["owner"]["avatar_url"].stringValue
                    repoModel.homeUrl = item["html_url"].stringValue
                    self.cellModels?.append(repoModel)
                }
               self.leftTable.reloadData()
            }
        }
    }
}

