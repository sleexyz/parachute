import FilterCommon
import NetworkExtension

public extension NEFilterDataVerdict {
    static func needRulesBlocking() -> NEFilterDataVerdict {
        let verdict = NEFilterDataVerdict.needRules()
        verdict.setValue(0, forKey: "_passBytes")
        return verdict
    }

    func passBytesIsZero() -> Bool {
        return value(forKey: "_passBytes") as! Int == 0
    }
}
