//
//  HistoryTVC.swift
//  OwnTracks
//
//  Created by Christoph Krey on 26.02.26.
//  Copyright © 2026 OwnTracks. All rights reserved.
//

import Foundation
import UIKit

@objc(HistoryTVC)

class HistoryTVC: OwnTracksEditTVC, NSFetchedResultsControllerDelegate {
    private var frc : NSFetchedResultsController<History>?;
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { _ in
            self.reset();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.sectionIndexMinimumDisplayRowCount = 4;
        super.viewWillAppear(animated);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        reset();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if frc != nil && frc!.sections != nil {
            if frc!.sections!.count == 0 {
                empty();
                return 0;
            } else {
                nonempty();
                return frc!.sections!.count;
            }
        } else {
            empty();
            return 0;
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return frc?.sectionIndexTitles;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if frc != nil && frc!.sections != nil {
            let sectionInfo = frc!.sections![section];
            return sectionInfo.numberOfObjects;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return frc?.section(forSectionIndexTitle: title, at: index) ?? 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath);
        let history = frc?.object(at: indexPath);
        if history != nil {
            cell.textLabel?.text = "\(history!.seen?.boolValue ?? true ? " " : "*")\(history!.text ?? "no text")";
            cell.detailTextLabel?.text = history!.timestampText();
        } else {
            cell.textLabel?.text = "no history";
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = frc?.managedObjectContext;
            if context != nil {
                let history = frc?.object(at: indexPath);
                if history != nil {
                    context!.delete(history!);
                    CoreData.sharedInstance().sync(context!);
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if frc != nil && frc!.sections != nil {
            let sectionInfo = frc!.sections![section];
            return sectionInfo.name;
        }
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = frc?.object(at: indexPath);
        if history != nil {
            history!.seen = NSNumber(booleanLiteral: true);
            CoreData.sharedInstance().sync(history!.managedObjectContext!);
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        performSelector(onMainThread: #selector(beginUpdates), with: nil, waitUntilDone: true);
    }
    
    @objc func beginUpdates() -> () {
        tableView.beginUpdates();
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        performSelector(onMainThread: #selector(endUpdates), with: nil, waitUntilDone: true);
    }
    
    @objc func endUpdates() -> () {
        tableView.endUpdates();
    }

    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let d : [String: Int] = [
            "type": Int(type.rawValue),
            "sectionIndex": sectionIndex
        ];
        performSelector(onMainThread: #selector(didChangeSection(d:)), with: d, waitUntilDone: true);
    }
    
    @objc func didChangeSection(d: [String: Int]) -> () {
        let type = d["type"];
        let sectionIndex = d["sectionIndex"];

        if type != nil  && sectionIndex != nil {
            let typeU = UInt(type!);
        
            switch(typeU) {
            case NSFetchedResultsChangeType.insert.rawValue:
                tableView.insertSections(IndexSet(integer: sectionIndex!), with: .automatic);
            case NSFetchedResultsChangeType.delete.rawValue:
                tableView.deleteSections(IndexSet(integer: sectionIndex!), with: .automatic);
            default:
                print("NSFetchResultsChangeType", type as Any, typeU);
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var d : [String: Int] = [
            "type": Int(type.rawValue)
        ];
        if indexPath != nil {
            d["indexPathSection"] = indexPath!.section;
            d["indexPathRow"] = indexPath!.row;

        }
        if newIndexPath != nil {
            d["newIndexPathSection"] = newIndexPath!.section;
            d["newIndexPathRow"] = newIndexPath!.row;
        }
        performSelector(onMainThread: #selector(didChangeObject(d:)), with: d, waitUntilDone: true);

    }
    
    @objc func didChangeObject(d: [String: Int]) -> () {
        let type = d["type"];
        let indexPathSection = d["indexPathSection"];
        let indexPathRow = d["indexPathRow"];
        let newIndexPathSection = d["newIndexPathSection"];
        let newIndexPathRow = d["newIndexPathRow"];

        if type != nil {
            let typeU = UInt(type!);
        
            switch(typeU) {
            case NSFetchedResultsChangeType.insert.rawValue:
                tableView.insertRows(at: [IndexPath(row: newIndexPathRow!, section: newIndexPathSection!)], with: .automatic);
            case NSFetchedResultsChangeType.delete.rawValue:
                tableView.deleteRows(at: [IndexPath(row: indexPathRow!, section: indexPathSection!)], with: .automatic);
            case NSFetchedResultsChangeType.update.rawValue:
                tableView.reloadRows(at: [IndexPath(row: indexPathRow!, section: indexPathSection!)], with: .automatic);
            case NSFetchedResultsChangeType.move.rawValue:
                tableView.deleteRows(at: [IndexPath(row: indexPathRow!, section: indexPathSection!)], with: .automatic);
                tableView.insertRows(at: [IndexPath(row: newIndexPathRow!, section: newIndexPathSection!)], with: .automatic);
            default:
                print("NSFetchResultsChangeType", type as Any, typeU);

            }
        }
    }

    @IBAction func trashPressed(_ sender: UIBarButtonItem) {
        let histories = History.allHistories(in: CoreData.sharedInstance().mainMOC);
        for history in histories {
            CoreData.sharedInstance().mainMOC.delete(history);
        }
        CoreData.sharedInstance().sync(CoreData.sharedInstance().mainMOC);
    }
    
    private func reset() {
        let fr = NSFetchRequest<History>();
        let e = NSEntityDescription.entity(forEntityName: "History", in: CoreData.sharedInstance().mainMOC);
        fr.entity = e;
        let s1 = NSSortDescriptor(key: "group", ascending: false);
        let s2 = NSSortDescriptor(key: "timestamp", ascending: false);
        fr.sortDescriptors = [s1, s2];
        self.frc = NSFetchedResultsController(fetchRequest: fr,
                                              managedObjectContext: CoreData.sharedInstance().mainMOC,
                                              sectionNameKeyPath: "group",
                                              cacheName: nil);
        self.frc?.delegate = self;
        do {
            try self.frc?.performFetch();
        } catch {
            print("fetch failed");
        }

        if tableView != nil {
            tableView.reloadData();
        }
    }
}
