//
//  DataRequest.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Combine

class DataRequest: Request, Publishable {
    var publisher: URLSession.DataTaskPublisher?
    var cancellable: AnyCancellable?
    
    func didCreatePublisher(_ publisher: URLSession.DataTaskPublisher) {
        self.publisher = publisher
    }
    
    @discardableResult
    func resume() -> Self {
        cancellable = publisher?
            .mapError({ urlError in
                NetworkError(urlError)
            })
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    self?.cancel()
                    return
                }
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    return
                }
            },
                  receiveValue: { [weak self] (data, urlResponse) in
                guard let self = self, let httpResponse = urlResponse as? HTTPURLResponse else {
                    self?.cancel()
                    return
                }
                self.data = data
                self.responseCallback?.perform(value: httpResponse)
            })
        return self
    }
}

// MARK: - Response Data
extension DataRequest {
    @discardableResult
    func responseData(completionHandler: @escaping (AsyncDataResponse<Data?>) -> Void) -> Self {
        responseCallback = Command { [weak self] urlResponse in
            guard let self = self else { return }
            let result = Result<Data?, NetworkError>(value: self.data, error: self.error)
            let response = DataResponse(request: self.urlRequest,
                                        response: urlResponse,
                                        data: self.data,
                                        result: result)
            completionHandler(response)
        }
        return self
    }
}
