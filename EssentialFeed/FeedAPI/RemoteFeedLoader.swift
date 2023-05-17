//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rahul Sharma on 21/04/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion:@escaping(HTTPClientResult)-> Void)
}

public final class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    
    public init(url: URL ,  client: HTTPClient){
        self.client =  client
        self.url = url
    }
    
    public func load(completion: @escaping(Error)->Void ) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
                
            }
            // For Multiples calls we make the requestUL as Array
            //  client.get(from: url)
        }
        
    }
}


