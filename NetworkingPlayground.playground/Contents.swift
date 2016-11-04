//: Playground - noun: a place where people can play

import Eskaera

import XCPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

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
    
    func completed(with response: HTTPResponse) {
        switch response {
        case .success(let data):
            guard let data = data else { return }
            print(data)
            break
        case .failure(let error):
            print(error)
            break
        }
    }
}

let popularPictures = Pictures.Popular
queue.executeTask(popularPictures)

enum Countries {
    case name(_: String)
    case alphaCodes(_: [String])
}

extension Countries: Task {

    var baseURL: String {
        return "https://restcountries.eu/rest/v1"
    }

    var path: String {
        switch self {
        case let .name(name):
            return "name/\(name)"
        case .alphaCodes:
            return "alpha"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .name:
            return ["fullText": "true"]
        case let .alphaCodes(codes):
            return ["codes": codes.joined(separator: ";")]
        }
    }

    func completed(with response: HTTPResponse) {
        switch response {
        case .success(let data):
            guard let data = data else { return }
            print(data)
            break
        case .failure(let error):
            print(error)
            break
        }
    }
}

var countries = Countries.name("Germany")
queue.executeTask(countries)
