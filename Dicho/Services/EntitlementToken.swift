import Foundation
import StoreKit

enum EntitlementToken {
    static func currentProJWS() async -> String? {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else {
                continue
            }

            if transaction.productID == SubscriptionManager.proMonthlyProductID {
                return result.jwsRepresentation
            }
        }

        return nil
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw EntitlementTokenError.unverifiedTransaction
        }
    }
}

private enum EntitlementTokenError: Error {
    case unverifiedTransaction
}
