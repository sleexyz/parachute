import Foundation
import ProxyService

public enum Mode {
    case quiet
    case free
}

struct RuleSet {
    let schedule: Proxyservice_ScheduleSettings
}

struct RuleContext {
    let now: Date
}

class RuleEvaluator {
    static let shared = RuleEvaluator()

    private init() {}

    func determineMode(rules: RuleSet, context: RuleContext) -> Mode {
        if rules.schedule.scheduleType == .everyDay {
            // Evaluate

            let everyDay = rules.schedule.everyDay
            if matchesDay(day: everyDay, date: context.now) {
                return .free
            }

            return .quiet
        }
        return .quiet
    }

    func matchesDay(day: Proxyservice_ScheduleDay, date: Date) -> Bool {
        if day.defaultVerb == .block, day.isAllDay {
            return false
        }

        let (from, to, reversed) = day.forToday(now: date)

        // Within window
        if date >= from, date < to {
            return true
        }

        if reversed {
            let fromYesterday = Calendar.current.date(byAdding: .day, value: -1, to: from)!
            let toYesterday = Calendar.current.date(byAdding: .day, value: -1, to: to)!

            if date >= fromYesterday, date < toYesterday {
                return true
            }
        }

        return false
    }
}
