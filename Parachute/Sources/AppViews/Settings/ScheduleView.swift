import Controllers
import ProxyService
import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        List {
            // Section {
            //     // TODO: this should be a selection
            //     Toggle(isOn: $settingsStore.settings.schedule.enabled) {
            //         Text("Enabled")
            //     }
            //     .tint(.parachuteOrange)

            // } footer: {
            //     Text("Set a time window to allow for social media use without interruption.")
            //         .font(.system(size: 12, weight: .regular, design: .rounded))
            //         .foregroundColor(.white)
            //         .opacity(0.6)
            // }

            Section {
                SelectionCell(choice: .everyDay, activeSelection: $settingsStore.settings.schedule.scheduleType) {
                    Text("Every day")
                }
                SelectionCell(choice: .customDays, activeSelection: $settingsStore.settings.schedule.scheduleType) {
                    Text("Customize days")
                }
            }
            if settingsStore.settings.schedule.scheduleType == .everyDay {
                let fromBinding = settingsStore.makeScheduleTimeBinding(
                    keyPath: \Proxyservice_Settings.schedule.everyDay.from
                )
                let toBinding = settingsStore.makeScheduleTimeBinding(
                    keyPath: \Proxyservice_Settings.schedule.everyDay.to
                )

                everyDayItem()
            } else {
                Section {
                    ForEach(0 ..< 7) { i in
                        dayItem(i)
                    }
                }
            }
        }
        .navigationTitle("Schedule")
        .tint(.parachuteOrange)
        .font(.system(size: 16, weight: .regular, design: .rounded))
    }

    @ViewBuilder
    func everyDayItem() -> some View {
        let day: WritableKeyPath<Proxyservice_Settings, Proxyservice_ScheduleDay> = \Proxyservice_Settings.schedule.everyDay
        let defaultVerbBinding = settingsStore.makeBinding(keyPath: day.appending(path: \.defaultVerb))
        let isAllDayBinding = settingsStore.makeBinding(keyPath: day.appending(path: \.isAllDay))
        let fromBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.from)
        )
        let toBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.to)
        )

        ScheduleDayView(
            defaultVerb: defaultVerbBinding,
            isAllDay: isAllDayBinding,
            from: fromBinding,
            to: toBinding,
            summary: settingsStore.settings[keyPath: day].detailSummary,
            disallowFreeDefault: true
        )
    }

    @ViewBuilder
    func dayItem(_ i: Int) -> some View {
        let maybeDay: WritableKeyPath<Proxyservice_Settings, Proxyservice_ScheduleDay?> = \Proxyservice_Settings.schedule.days[Int32(i)]
        let day = maybeDay.appending(path: \.!)
        let defaultVerbBinding = settingsStore.makeBinding(keyPath: day.appending(path: \.defaultVerb))
        let isAllDayBinding = settingsStore.makeBinding(keyPath: day.appending(path: \.isAllDay))
        let fromBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.from)
        )
        let toBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.to)
        )
        let names = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
        ]

        NavigationLink {
            List {
                ScheduleDayView(
                    defaultVerb: defaultVerbBinding,
                    isAllDay: isAllDayBinding,
                    from: fromBinding,
                    to: toBinding,
                    summary: settingsStore.settings[keyPath: day].detailSummary
                )
                .navigationTitle(names[i])
            }
        } label: {
            HStack {
                Text(names[i])
                Spacer()
                Text(
                    settingsStore.settings[keyPath: day].summary
                )
                .multilineTextAlignment(.trailing)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .opacity(0.6)
            }
        }
    }
}

struct ScheduleDayView: View {
    @Binding var defaultVerb: Proxyservice_RuleVerb
    @Binding var isAllDay: Bool
    @Binding var from: Date
    @Binding var to: Date

    var scheduleExceptions: Binding<Bool> {
        Binding<Bool>(
            get: {
                !isAllDay
            },
            set: {
                isAllDay = !$0
            }
        )
    }

    var summary: String

    // TODO: make sure we also modify the selection cells if this is true
    var disallowFreeDefault: Bool = false

    var body: some View {
        if !disallowFreeDefault {
            Section {
                Picker(selection: $defaultVerb, label: Text("Default mode")) {
                    Text("Quiet").tag(Proxyservice_RuleVerb.block)
                    Text("Free").tag(Proxyservice_RuleVerb.allow)
                }
                .pickerStyle(.menu)
            }
        }

        Section {
            let text = defaultVerb == .allow ? "Schedule Quiet time" : "Schedule Free time"
            Toggle(text, isOn: scheduleExceptions)

            if !isAllDay {
                DatePicker(
                    "From",
                    selection: $from,
                    displayedComponents: .hourAndMinute
                )
                DatePicker(
                    "To",
                    selection: $to,
                    displayedComponents: .hourAndMinute
                )
            }
        } footer: {
            Text(summary)
                .font(.system(size: 12, weight: .regular, design: .rounded))

                .padding(.top, 20)
        }
    }
}
