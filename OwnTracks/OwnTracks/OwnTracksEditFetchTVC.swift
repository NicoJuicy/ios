//
//  OwnTracksEditFetchTVC.swift
//  OwnTracks
//
//  Created by Christoph Krey on 26.02.26.
//  Copyright © 2026 OwnTracks. All rights reserved.
//

import Foundation
import UIKit

@objc(OwnTracksEditFetchTVC)

class OwnTracksEditFetchTVC: OwnTracksEditTVC, NSFetchedResultsControllerDelegate {
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
}
