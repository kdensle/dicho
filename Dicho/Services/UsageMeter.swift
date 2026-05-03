import Foundation

@MainActor
final class UsageMeter: ObservableObject {
    static let freeMonthlyLimit = 30

    @Published private(set) var usedThisPeriod: Int
    @Published private(set) var periodKey: String

    private let defaults: UserDefaults
    private let usageKey = "freeTranslationUsageCount"
    private let usagePeriodKey = "freeTranslationUsagePeriod"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let currentPeriod = Self.currentPeriodKey()
        let savedPeriod = defaults.string(forKey: usagePeriodKey) ?? currentPeriod

        if savedPeriod == currentPeriod {
            periodKey = savedPeriod
            usedThisPeriod = defaults.integer(forKey: usageKey)
        } else {
            periodKey = currentPeriod
            usedThisPeriod = 0
            defaults.set(currentPeriod, forKey: usagePeriodKey)
            defaults.set(0, forKey: usageKey)
        }
    }

    var remainingFreeUses: Int {
        max(0, Self.freeMonthlyLimit - usedThisPeriod)
    }

    func canTranslate(hasActiveSubscription: Bool) -> Bool {
        resetIfNeeded()
        return hasActiveSubscription || remainingFreeUses > 0
    }

    func recordSuccessfulTranslation(hasActiveSubscription: Bool) {
        guard !hasActiveSubscription else {
            return
        }

        resetIfNeeded()
        usedThisPeriod += 1
        defaults.set(usedThisPeriod, forKey: usageKey)
    }

    func resetIfNeeded() {
        let currentPeriod = Self.currentPeriodKey()
        guard periodKey != currentPeriod else {
            return
        }

        periodKey = currentPeriod
        usedThisPeriod = 0
        defaults.set(currentPeriod, forKey: usagePeriodKey)
        defaults.set(0, forKey: usageKey)
    }

    private static func currentPeriodKey(date: Date = Date()) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        return String(format: "%04d-%02d", year, month)
    }
}
