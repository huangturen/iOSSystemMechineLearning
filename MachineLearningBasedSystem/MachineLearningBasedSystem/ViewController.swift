//
//  ViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/24.
//

import UIKit
import Vision



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    static let typesArray = ["classify","objectDetect"];

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.typesArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MLCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "MLCell")
            cell?.textLabel?.text = ViewController.typesArray[indexPath.row]
            cell?.selectionStyle = .none
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let typestr = ViewController.typesArray[indexPath.row]
        var vc:SystemMLBaseViewController? = nil;
        switch typestr {
            case "classify":
                vc = ImageClassifyViewController()
                break
            case "objectDetect":
                vc = ObjectDetectViewController()
                break
            default:
                break
        }
        
        guard let _ = vc else {
            return
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableView = UITableView.init(frame: view.frame, style:.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        view.backgroundColor = .white
        
    }
}

