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
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
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
            
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
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
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
                    let invalidJSON = Data(bytes: "invalid json".utf8)
                    client.complete(withStatusCode: 200, data: invalidJSON)
                })
        }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
            let (sut, client) = makeSUT()

            var capturedResults = [RemoteFeedLoader.Result]()
            sut.load { capturedResults.append($0) }

            let emptyListJSON = Data(bytes: "{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)

            XCTAssertEqual(capturedResults, [.success([])])
        }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
            let (sut, client) = makeSUT()

//            let item1 = FeedItem(
//                id: UUID(),
//                description: nil,
//                location: nil,
//                image: URL(string: "http://a-url.com")!)
//
        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            image: URL(string: "http://a-url.com")!)


//            let item1JSON = [
//                "id": item1.id.uuidString,
//                "image": item1.image.absoluteString
//            ]

//            let item2 = FeedItem(
//                id: UUID(),
//                description: "a description",
//                location: "a location",
//                image: URL(string: "http://another-url.com")!)
//
        let item2 = makeItem(
                    id: UUID(),
                    description: "a description",
                    location: "a location",
                    image: URL(string: "http://another-url.com")!)


//            let item2JSON = [
//                "id": item2.id.uuidString,
//                "description": item2.description,
//                "location": item2.location,
//                "image": item2.image.absoluteString
//            ]
//
//            let itemsJSON = [
//                "items": [item1JSON, item2JSON]
//            ]
        
        let items = [item1.model, item2.model]
        

//            expect(sut, toCompleteWith: .success([item1, item2]), when: {
//                let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
//                client.complete(withStatusCode: 200, data: json)
//            })
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
        }
    //MARK : Helper
    
    private func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader , client: HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, image: URL) -> (model: FeedItem, json: [String: Any]) {
            let item = FeedItem(id: id, description: description, location: location, image: image)

            let json = [
                "id": id.uuidString,
                "description": description,
                "location": location,
                "image": image.absoluteString
            ].reduce(into: [String: Any]()) { (acc, e) in
                if let value = e.value { acc[e.key] = value }
            }

            return (item, json)
        }

        private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
            let json = ["items": items]
            return try! JSONSerialization.data(withJSONObject: json)
        }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        // XCTAssertEqual(capturedErrors, [error], file: file, line: line)
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
        
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
