import DI
import OSLog


public struct RegisterActivityRefreshRequest: Codable {
    let activityId: String
    let refreshDate: Date
}

public struct RegisterActivityRefreshResponse: Codable {
    let taskName: String
}

public class QueueService: ObservableObject {
    public struct Provider: Dep {
        public func create(r: Registry) -> QueueService {
            return .shared
        }
        public init() {}
    }

    public static let shared = QueueService()

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QueueService") 


    public func registerActivityRefresh(activityId: String, refreshDate: Date) {
        let url = "https://us-central1-slowdown-375014.cloudfunctions.net/register_activity_refresh"
        let body = RegisterActivityRefreshRequest(activityId: activityId, refreshDate: refreshDate)
        let encoder = JSONEncoder()
        // milliseconds since epoch
        encoder.dateEncodingStrategy =  .millisecondsSince1970
        let data = try! encoder.encode(body)
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error {
                self.logger.error("error: \(error)")
                return
            }
            guard let data = data else {
                self.logger.error("no data")
                return
            }
            do {
                let response = try JSONDecoder().decode(RegisterActivityRefreshResponse.self, from: data)
                self.logger.info("response: \(response.taskName)")
            } catch {
                self.logger.error("error: \(error)")
            }
        }
        task.resume()
    }

    //TODO: implement
    public func cancelActivityRefresh(activityId: String) {
    }
}
