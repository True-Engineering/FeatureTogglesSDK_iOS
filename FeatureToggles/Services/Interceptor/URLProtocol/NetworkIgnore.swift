import Foundation

public enum Ignore {
    case disbaled
    case enabled(ignoreHandler: (RequestDataModel) -> Bool)
}
