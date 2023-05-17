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
       // XCTAssertEqual(client.requestedUrl , url)
        XCTAssertEqual(client.requestedURLs , [url])
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
        var requestedURLs = [URL]()
        func get(from url: URL) {
            //requestedUrl = url
            requestedURLs.append(url)
        }
    }

}
