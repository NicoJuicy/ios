//
//  RegionsTVC.swift
//  OwnTracks
//
//  Created by Christoph Krey on 24.02.26.
//  Copyright © 2026 OwnTracks. All rights reserved.
//

import Foundation
import UIKit

@objc(RegionsTVC)

class RegionsTVC: OwnTracksEditTVC, NSFetchedResultsControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController<Region>!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
            self?.reset();
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        reset();
    }
    
    func reset() {
        self.fetchedResultsController = nil;
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setRegion:" {
            let region = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!);
            seque.destination.performsel
            
        }
    }
}
