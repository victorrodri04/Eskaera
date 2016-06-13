//: Playground - noun: a place where people can play

import Eskaera

import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let httpClient = HTTPClient()
let queue = HTTPRequestQueue(httpClient: httpClient)

enum Pictures {
    case Popular
}

extension Pictures: Task {
    var baseURL: String {
        return "https://api.500px.com/v1/"
    }
    
    var path: String {
        return "photos"
    }
    
    var parameters: Parameters {
        switch self {
        case .Popular:
            return ["feature": "popular", "consumer_key": "5j9QJ3HSdf3hyu5YLQDjiWPhLPFzbxJV0rHb7uEX"]
        }
    }
    
    func completed(withResponse response: HTTPResponse) {
        switch response {
        case .Success(let data):
            guard let data = data else { return }
            print(data)
            break
        case .Failure(let error):
            print(error)
            break
        }
    }
}

let popularPictures = Pictures.Popular
queue.executeTask(popularPictures)

enum Countries {
    case Name(name: String)
    case AlphaCodes(codes: [String])
}

extension Countries: Task {

    var baseURL: String {
        return "https://restcountries.eu/rest/v1"
    }

    var path: String {
        switch self {
        case let .Name(name):
            return "name/\(name)"
        case .AlphaCodes:
            return "alpha"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .Name:
            return ["fullText": "true"]
        case let .AlphaCodes(codes):
            return ["codes": codes.joinWithSeparator(";")]
        }
    }

    func completed(withResponse response: HTTPResponse) {
        switch response {
        case .Success(let data):
            guard let data = data else { return }
            print(data)
            break
        case .Failure(let error):
            print(error)
            break
        }
    }
}

var countries = Countries.Name(name: "Germany")
queue.executeTask(countries)
