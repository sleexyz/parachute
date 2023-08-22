import NetworkExtension
import FilterCommon

public extension NEFilterDataVerdict {
    static func allowPeekBytes(passBytes: Int, app: App) -> NEFilterDataVerdict {
        return NEFilterDataVerdict(passBytes: passBytes, peekBytes: app.peekBytes)
    }

    static func needRulesBlocking() -> NEFilterDataVerdict {
        let verdict = NEFilterDataVerdict.needRules()
        verdict.setValue(0, forKey: "_passBytes")
        return verdict
    }

    func passBytesIsZero() -> Bool {
        return self.value(forKey: "_passBytes") as! Int == 0
    }
}
