import Controllers
import ProxyService
import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        List {
            Section {
                Toggle(isOn: $settingsStore.settings.schedule.enabled) {
                    Text("Enable")
                }
                .tint(.parachuteOrange)
            } footer: {
                Text("Set aside dedicated time windows to allow for social media use without Detox Mode.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(0.6)
            }

            if settingsStore.settings.schedule.enabled {
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

                    Section(header: Text("Allow social media")) {
                        DatePicker(
                            "From",
                            selection: fromBinding,
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "To",
                            selection: toBinding,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } else {
                    Section(header: Text("Allow social media")) {
                        ForEach(0 ..< 7) { i in
                            dayItem(i)
                        }
                    }
                }
            }
        }
        .navigationTitle("Schedule")
        .tint(.parachuteOrange)
        .font(.system(size: 16, weight: .regular, design: .rounded))
    }

    @ViewBuilder
    func dayItem(_ i: Int) -> some View {
        let day: WritableKeyPath<Proxyservice_Settings, Proxyservice_ScheduleDay?> = \Proxyservice_Settings.schedule.days[Int32(i)]
        let enabledBinding = settingsStore.makeBinding(keyPath: day.appending(path: \.!.enabled))
        let fromBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.!.from)
        )
        let toBinding = settingsStore.makeScheduleTimeBinding(
            keyPath: day.appending(path: \.!.to)
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
            ScheduleDayView(
                name: names[i],
                enabled: enabledBinding,
                from: fromBinding,
                to: toBinding,
                summary: settingsStore.settings.schedule.days[Int32(i)]!.detailSummary
            )
            .navigationTitle(names[i])
        } label: {
            HStack {
                Text(names[i])
                Spacer()
                Text(
                    settingsStore.settings.schedule.days[Int32(i)]!.summary
                )
                .opacity(0.6)
            }
        }
    }
}

struct ScheduleDayView: View {
    var name: String

    @Binding var enabled: Bool
    @Binding var from: Date
    @Binding var to: Date

    var summary: AttributedString

    var body: some View {
        List {
            Section {
                Toggle(isOn: $enabled) {
                    Text(name)
                }
            } footer: {
                if !enabled {
                    Text(summary)
                }
            }
            if enabled {
                Section {
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

                    Button {
                        from = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                        to = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                    } label: {
                        Text("Allow all day")
                    }
                } header: {
                    Text("Allow social media")
                } footer: {
                    Text(summary)
                }
            }
        }
    }
}
