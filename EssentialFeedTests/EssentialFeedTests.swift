//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Rahul Sharma on 12/04/23.
//

import XCTest
import EssentialFeed

final class EssentialFeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //Nameing - test funcname(init) behaviour (doseNotRequiredDataFromUrl)
    func test_init_doseNotRequiredDataFromUrl(){
        
        let (_ , client) = makeSUT()

        //XCTAssertNil(client.requestedUrl)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://abcd.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
       // XCTAssertEqual(client.requestedUrl , url)
        XCTAssertEqual(client.requestedURLs , [url ,url])
    }
    
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
       // client.error = NSError(domain: "Test", code: 0)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        //client.completions[0](clientError)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
        
    }
    
    //MARK : Helper
    
    private func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader , client: HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    // Spy Class from the HTTPClient
    private class HTTPClientSpy: HTTPClient {
        
        //var requestedUrl: URL?
       // var requestedURLs = [URL]()
        //var error: Error? // replaceing stubbing by capature values instead
       // var completions = [(Error) -> Void]()
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
//        func get(from url: URL) {
//            //requestedUrl = url
//
//        }
        func get(from url: URL, completion: @escaping (Error) -> Void) {
//            if let error = error {
//                completion(error)
//            }
//            completions.append(completion)
//            requestedURLs.append(url)
            messages.append((url, completion))
        }
        func complete(with error: Error, at index: Int = 0) {
            //completions[index](error)
            messages[index].completion(error)
        }
    }

}
