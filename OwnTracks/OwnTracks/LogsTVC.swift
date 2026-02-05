//
//  LogsTVC.swift
//  OwnTracks
//
//  Created by Christoph Krey on 18.12.25.
//  Copyright © 2025-2026 OwnTracks. All rights reserved.
//

import Foundation
import UIKit
import OSLog

extension OSLogEntryLog.Level {
  fileprivate var description: String {
    switch self {
    case .undefined: "undefined"
    case .debug: "debug"
    case .info: "info"
    case .notice: "notice"
    case .error: "error"
    case .fault: "fault"
    @unknown default: "default"
    }
  }
}

@objc(LogsTVC)
class LogsTVC: UITableViewController, UIDocumentInteractionControllerDelegate {
    var dic: UIDocumentInteractionController?
    var lines: [String] = [];
    var dates: [Date] = [];

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let store: OSLogStore?
        do {
            store = try OSLogStore(scope: .currentProcessIdentifier)
        } catch {
            store = nil
        }

        let position = store?.position(date: Date())
        //let predicate = NSPredicate(format: "(subsystem == %@) && (messageType IN %@)",
        //  "de.ckrey", ["info", "default", "error", "fault"])
        let predicate = NSPredicate(format: "(subsystem == %@) && ((messageType == info) || (messageType == default) || (messageType == error) || (messageType == fault))",
                                    "org.mqttitude")

        let entries: AnySequence<OSLogEntry>?
        do {
            entries = try store?.getEntries(at: position,
                                            matching: predicate)

        } catch {
            entries = nil
        }
        
        lines = [];
        dates = [];
        
        entries?.forEach { entry in
            if lines.count == 10 {
                dates.append(Date());
                lines.append("...");
            }
            if lines.count < 10 {
                if let log = entry as? OSLogEntryLog {
                    dates.append(entry.date);
                    lines.append("""
                \(log.level.description): \
                \(entry.composedMessage)\n
                """)
                } else {
                    lines.append("\(entry.composedMessage)\n")
                }
            }
        }
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath);
        cell.textLabel?.text = lines[indexPath.row];
        let isoFormatter = ISO8601DateFormatter();
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds];
        cell.detailTextLabel?.text = ("\(isoFormatter.string(from:dates[indexPath.row]))");
        return cell;
    }
        
    @IBAction func actionPressed(_ sender: UIBarButtonItem) {
        let store: OSLogStore?
        do {
            store = try OSLogStore(scope: .currentProcessIdentifier)
        } catch {
            store = nil
        }

        let position = store?.position(date: Date())
        let predicate = NSPredicate(format: "(subsystem == %@) && ((messageType == info) || (messageType == default) || (messageType == error) || (messageType == fault))",
                                    "org.mqttitude")

        let entries: AnySequence<OSLogEntry>?
        do {
            entries = try store?.getEntries(at: position,
                                            matching: predicate)

        } catch {
            entries = nil
        }
        
        do {
            let directoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true);
            let fileName = ("owntracks.log");
            let fileURL = directoryURL.appendingPathComponent(fileName);
            let output = OutputStream(url: fileURL, append: false)!;
            output.open();
            let isoFormatter = ISO8601DateFormatter();
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds];

            entries?.forEach { entry in
                let line: String;
                if let log = entry as? OSLogEntryLog {
                    line = ("""
                    \(isoFormatter.string(from:entry.date)):\
                    \(log.level.description): \
                    \(entry.composedMessage)\n
                    """)
                } else {
                    line = ("\(isoFormatter.string(from:entry.date)): \(entry.composedMessage)\n")
                }
                output.write(line, maxLength: line.utf8.count);
            }
            output.close();

            dic = UIDocumentInteractionController(url:fileURL as URL) ;
            dic?.delegate = self;
            //dic?.presentOptionsMenu(from: self.navigationController!.navigationBar.frame, in: self.tableView, animated: true);
            dic?.presentPreview(animated: true)

        } catch {
        }
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        do {
            try FileManager.default.removeItem(at: controller.url!);
        } catch {
            
        }
    }
        
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self;
    }
    
}
