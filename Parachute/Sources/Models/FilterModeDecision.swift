
public enum FreeReason {
    case schedule
}

public enum FilterModeDecision {
    case quiet
    case free(reason: FreeReason)
}
