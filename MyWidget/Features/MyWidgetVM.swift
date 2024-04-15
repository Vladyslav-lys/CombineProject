//
//  MyWidgetVM.swift
//  MyWidgetExtension
//
//  Created by Vladyslav Lysenko on 12.10.2022.
//

import Services
import Combine
import WidgetKit

final class MyWidgetVM: IntentTimelineProvider, UseCasesConsumer {
    typealias UseCases = HasUserUseCase & HasTransportUseCase
    
    @Published private(set) var userName: String = ""
    @Published private(set) var isRed: Bool = false
    var subscriptions: Set<AnyCancellable> = []
    
    var text: String {
        let userDeafults = UserDefaults(suiteName: "group.com.cleveroad.CombineProject")
        return userDeafults?.value(forKey: "text") as? String ?? ""
    }
    
    init(useCases: UseCases) {
        self.useCases = useCases
        
        $userName.sink {
            print($0)
        }.store(in: &subscriptions)
        
        getUsers(params: UserParams(results: 1))
    }
    
    func getUsers(params: UserParams) {
        useCases.user
            .getUsers(params: params.parameters)
            .replaceError(with: [])
            .map(\.first)
            .sink {
                guard let user = $0 else { return }
                self.userName = "\(user.name.first) \(user.name.last)"
                WidgetCenter.shared.reloadAllTimelines()
            }
            .store(in: &subscriptions)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: text, isRed: false, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: text, isRed: false, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let text = configuration.text ?? userName
        let isRed = (configuration.isRed as? Bool) ?? false
        
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 0, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, text: text, isRed: isRed, configuration: configuration)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
