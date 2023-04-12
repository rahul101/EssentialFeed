//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rahul Sharma on 12/04/23.
//

import Foundation

enum LoadFeedResult{
    
    case success([FeedItem])
    case error (Error)
}

protocol FeedLoader{
    
    func load(completion:@escaping (LoadFeedResult)->  Void)
}
