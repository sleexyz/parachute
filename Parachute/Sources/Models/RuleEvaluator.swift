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
        switch rules.schedule.scheduleType {
        case .everyDay:
            let everyDay = rules.schedule.everyDay
            if matchesDay(day: everyDay, date: context.now) {
                return .free
            }
            return .quiet
        default:
            // Get the day of the week
            let dayIndex = Calendar.current.dateComponents([.weekday], from: context.now).weekday! - 1
            let day = rules.schedule.days[Int32(dayIndex)]!

            if matchesDay(day: day, date: context.now) {
                return .free
            }

            let prevIndex = (dayIndex - 1 + 7) % 7
            let prev = rules.schedule.days[Int32(prevIndex)]!
            if prev.fromDate(now: context.now) >= prev.toDate(now: context.now), matchesDayReversed(day: prev, date: context.now) {
                return .free
            }

            return .quiet
        }
    }

    func matchesDayReversed(day: Proxyservice_ScheduleDay, date: Date) -> Bool {
        // e.g. 10pm - 2am tomorrow
        let (from, to, _) = day.forToday(now: date)

        // 10pm yesterday
        let fromYesterday = Calendar.current.date(byAdding: .day, value: -1, to: from)!
        // 2am today
        let toToday = Calendar.current.date(byAdding: .day, value: -1, to: to)!

        if date >= fromYesterday, date < toToday {
            return true
        }
        return false
    }

    func matchesDay(day: Proxyservice_ScheduleDay, date: Date) -> Bool {
        if day.isAllDay {
            return false
        }

        let (from, to, reversed) = day.forToday(now: date)

        // Within window
        if date >= from, date < to {
            return true
        }

        if reversed {
            return matchesDayReversed(day: day, date: date)
        }

        return false
    }
}
