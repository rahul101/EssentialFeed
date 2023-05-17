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
        sut.load{_ in }
       // XCTAssertEqual(client.requestedUrl , url)
        XCTAssertEqual(client.requestedURLs , [url])
    }
    
    func test_load_requestsDataFromUrlTwice() {
        let url = URL(string: "https://abcd.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load{_ in }
        sut.load{_ in }
       // XCTAssertEqual(client.requestedUrl , url)
        XCTAssertEqual(client.requestedURLs , [url ,url])
    }
    
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
       // client.error = NSError(domain: "Test", code: 0)
        
//        var capturedErrors = [RemoteFeedLoader.Error]()
//        sut.load { capturedErrors.append($0) }
//        let clientError = NSError(domain: "Test", code: 0)
//        //client.completions[0](clientError)
//        client.complete(with: clientError)
//        XCTAssertEqual(capturedErrors, [.connectivity])
        
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        //        var capturedErrors = [RemoteFeedLoader.Error]()
        //        sut.load { capturedErrors.append($0) }
        
        let samples = [199, 201, 300, 400, 500]
        //   client.complete(withStatusCode: 400)
        
        //  XCTAssertEqual(capturedErrors, [.invalidData])
        samples.enumerated().forEach { index, code in
//            var capturedErrors = [RemoteFeedLoader.Error]()
//            sut.load { capturedErrors.append($0) }
//
//            client.complete(withStatusCode: code, at: index)
//
//            XCTAssertEqual(capturedErrors, [.invalidData])
            
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }


    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
            let (sut, client) = makeSUT()
//            var capturedErrors = [RemoteFeedLoader.Error]()
//            sut.load { capturedErrors.append($0) }
//
//            let invalidJSON = Data(bytes: "invalid json".utf8)
//            client.complete(withStatusCode: 200, data: invalidJSON)
//
//            XCTAssertEqual(capturedErrors, [.invalidData])
        expect(sut, toCompleteWithError: .invalidData, when: {
                    let invalidJSON = Data(bytes: "invalid json".utf8)
                    client.complete(withStatusCode: 200, data: invalidJSON)
                })
        }

    //MARK : Helper
    
    private func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader , client: HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        // XCTAssertEqual(capturedErrors, [error], file: file, line: line)
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
        
    }


    // Spy Class from the HTTPClient
    private class HTTPClientSpy: HTTPClient {
        
        //var requestedUrl: URL?
       // var requestedURLs = [URL]()
        //var error: Error? // replaceing stubbing by capature values instead
       // var completions = [(Error) -> Void]()
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
//        func get(from url: URL) {
//            //requestedUrl = url
//
//        }
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
//            if let error = error {
//                completion(error)
//            }
//            completions.append(completion)
//            requestedURLs.append(url)
            messages.append((url, completion))
        }
        func complete(with error: Error, at index: Int = 0) {
            //completions[index](error)
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data,response))
        }
    }

}
