//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rahul Sharma on 21/04/23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion:@escaping(Error)-> Void)
}

public final class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    public enum Error: Swift.Error {
        case connectivity
    }


   public init(url: URL ,  client: HTTPClient){
        self.client =  client
        self.url = url
    }
    
    public func load(completion: @escaping(Error)->Void = {_ in }) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
        // For Multiples calls we make the requestUL as Array
       //  client.get(from: url)
    }
    
}


