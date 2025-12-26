//
//  LogsTVC.swift
//  OwnTracks
//
//  Created by Christoph Krey on 18.12.25.
//  Copyright © 2025 OwnTracks. All rights reserved.
//

import Foundation
import UIKit

@objc(LogsTVC)
class LogsTVC: UITableViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var actionButton: UIBarButtonItem!
    var dic: UIDocumentInteractionController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        actionButton.isEnabled = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ad = UIApplication.shared.delegate as! OwnTracksAppDelegate
        return ad.fl?.logFileManager.sortedLogFilePaths.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! UITableViewCell;
        
        let ad = UIApplication.shared.delegate as! OwnTracksAppDelegate;
        let logFilePath = ad.fl?.logFileManager.sortedLogFilePaths[indexPath.row] ?? "";
        cell.textLabel?.text = URL(fileURLWithPath: logFilePath).lastPathComponent;
        
        let logFileInfo = ad.fl?.logFileManager.sortedLogFileInfos[indexPath.row];
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .short;
        dateFormatter.timeStyle = .short;
        
        let sizeFormatter = ByteCountFormatter();
        sizeFormatter.countStyle = .file;
        
        let size = logFileInfo?.fileSize ?? 0;
        let creationDate = logFileInfo?.creationDate ?? Date(timeIntervalSince1970: 0);
        
        cell.detailTextLabel?.text = "Size: \(sizeFormatter.string(fromByteCount: Int64(size))) - Created \(dateFormatter.string(from: creationDate))";
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actionButton.isEnabled = true;
    }
    
    @IBAction func actionPressed(_ sender: UIBarButtonItem) {
        let indexPath = tableView.indexPathForSelectedRow

        if (indexPath == nil) {
            return;
        }
        
        let ad = UIApplication.shared.delegate as! OwnTracksAppDelegate;
        let fileURL = NSURL.fileURL(withPath:ad.fl?.logFileManager.sortedLogFilePaths[indexPath!.row] ?? "");

        dic = UIDocumentInteractionController(url:fileURL as URL) ;
        dic?.delegate = self;
        dic?.presentOptionsMenu(from: self.navigationController!.navigationBar.frame, in: self.tableView, animated: true);
    }
}
