import Alamofire

public typealias Completion<Model: Codable> = (Response<Model>) -> Void
open class NetworkManager: NSObject {
    enum ResponseDecodeError: Error, LocalizedError {
        case emptyResponse
        var errorDescription: String {
            return "Unable to get data"
        }
    }
    static public let shared = NetworkManager()
    private override init() {
        super.init()
    }
    
    public func hitApi<ModelClass: Codable>(urlRequest: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: @escaping Completion<ModelClass>, onTaskCreation: ((URLSessionTask) -> Void)? = nil) {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
#if DEBUG
//        print("🕸️request for \(urlRequest.url!)")
#endif
        AF.request(urlRequest).validate()
            .responseDecodable(decoder: decoder) { (response: DataResponse<ModelClass, AFError>) in
            
            var errorValue: [String: Any]? = [:]
            if let data = response.data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                    completion(Response.failed(APIError(error: ResponseDecodeError.emptyResponse, statusCode: -1, errorValue: nil)))
                    return
                }
                errorValue = json
#if DEBUG
                do
                {
//                    print(errorValue)
                    let model = try ModelClass.objectFrom(json: errorValue as Any, decoder: decoder)
                    //print(model)
                }
                catch {
                    print("\(String(describing: response.request?.url)): \(error)")
                }
#endif
            }
            
            switch response.result {
            case .success(let value):
                let model = Response.ResponseValue(value: value, statusCode: response.response?.statusCode)
                completion(Response.success(model))
            case .failure(let error):
                completion(Response.failed(APIError(error: error, statusCode: response.response?.statusCode, errorValue: errorValue)))
                
            }
        }
            .onURLSessionTaskCreation(perform: onTaskCreation != nil ? onTaskCreation ?? {_ in} :{_ in})
        
    }

    func errorString<Type: Codable>(from response: Response<Type>) -> String? {
        if let error = response.error as? LocalizedError {
            if response.statusCode == NSURLErrorNotConnectedToInternet {
                return "No Network Connection"
            } else {
                return error.errorDescription
            }
        } else if let error = response.error as NSError?, error.code == NSURLErrorNotConnectedToInternet {
            return "No Network Connection"
        } else {
            return response.error?.localizedDescription
        }
    }
}

public typealias APIError<Type: Codable> = Response<Type>.ResponseError
public enum Response<ResponseType> where ResponseType: Codable {
    public struct ResponseError {
        public let error: Error?
        public let statusCode: Int?
        public let errorValue: [String: Any]?
        public init(error: Error?, statusCode: Int? = nil, errorValue: [String: Any]? = nil) {
            self.error = error
            self.statusCode = statusCode
            self.errorValue = errorValue
        }
        public func errorMessage() -> String?
        {
            if let dict = errorValue
            {
                if let error = dict["error"] as? String {
                    return error
                }
                if let errors = dict["errors"] as? [String: Any], let error = errors["error"] as? String, error.count > 0
                {
                    return error
                }
                if let error = dict["status"] as? String, error.count > 0
                {
                    return error
                }
            }
            return nil
        }
    }
    public struct ResponseValue {
        public let value: ResponseType
        public let statusCode: Int?
        public init(value: ResponseType, statusCode: Int?) {
            self.value = value
            self.statusCode = statusCode
        }
    }
    case success(ResponseValue),
    failed(ResponseError)

    public var responseError: ResponseError? {
        switch self {
        case .success:
            return nil
        case .failed(let value):
            return value
        }
    }

    public var value: ResponseType? {
        switch self {
        case .success(let value):
            return value.value
        case .failed:
            return nil
        }
    }
    public var error: Error? {
        switch self {
        case .failed(let error):
            return error.error
        case .success:
            return nil
        }
    }
    public var statusCode: Int? {
        switch self {
        case .success(let response):
            return response.statusCode
        case .failed(let response):
            return response.statusCode
        }
    }
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failed:
            return false
        }
    }
}
public enum APIErrors: Error {
    case noDataRecieved,
    parserError,
    oauthTokenError,
    invalidRequest(String),
    cancelled
}
enum RequestMethod: String
{
    case GET,
    POST,
    DELETE,
    HEAD
}
protocol RequestConvertible
{
    var baseURL: String {get}
    var endpoint: String {get}
    var headers: [String: String]? {get}
    var params: [String: Any]? {get}
    var method: RequestMethod {get}
    func asURLRequest()throws -> URLRequest
}
extension RequestConvertible
{
    func asURLRequest()throws -> URLRequest
    {
        let url = baseURL + endpoint
        var urlRequest = try URLRequest(url: URL(string: url)!, method: HTTPMethod(rawValue: method.rawValue))
        let hasUrlEncodedParams = (method == .GET || method == .DELETE || method == .HEAD)
        if hasUrlEncodedParams {
            let encoding = URLEncoding()
            urlRequest = try encoding.encode(urlRequest, with: params)
        } else if let params {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        var apiHeaders = self.headers
        //check if `Content-Type` is provided
        // if `Content-Type` are not provided then add `application/json` as default
        if let headers = apiHeaders {
            if headers["Content-Type"] == nil {
                apiHeaders?["Content-Type"] = "application/json"
            }
        } else {
            apiHeaders = [:]
            apiHeaders?["Content-Type"] = "application/json"
        }
        urlRequest.allHTTPHeaderFields = apiHeaders
        return urlRequest
    }
}
