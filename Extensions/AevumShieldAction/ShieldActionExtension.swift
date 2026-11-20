import ManagedSettings
import UIKit

// MARK: - Extension de Gestion des Clics sur le Shield
// Le système appelle une méthode par type de cible bloquée : application ou catégorie
// (jetons opaques ApplicationToken / ActivityCategoryToken), avec la même réponse.
class ShieldActionExtension: ShieldActionDelegate {

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(response(to: action))
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(response(to: action))
    }

    private func response(to action: ShieldAction) -> ShieldActionResponse {
        switch action {
        case .primaryButtonPressed:
            // Laisse le shield en place : l'app Aevum prend le relais pour lancer le défi.
            return .defer
        case .secondaryButtonPressed:
            // L'utilisateur renonce à ouvrir l'app bloquée.
            return .close
        @unknown default:
            return .close
        }
    }
}
