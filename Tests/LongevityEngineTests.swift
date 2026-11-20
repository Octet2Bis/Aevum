import XCTest
// Paquet SwiftPM : le code vit dans AevumAppCore. Cible XcodeGen AevumTests :
// les sources de Core sont compilées dans le bundle de test, rien à importer.
#if canImport(AevumAppCore)
@testable import AevumAppCore
#endif

final class LongevityEngineTests: XCTestCase {
    
    func testCatalogIntegrity() {
        let protocols = LongevityCatalog.allProtocols
        XCTAssertFalse(protocols.isEmpty, "Le catalogue ne doit pas être vide.")
        XCTAssertEqual(Set(protocols.map(\.id)).count, protocols.count, "Identifiants en double dans le catalogue.")
        
        // Vérification du Soupir Physiologique
        let sigh = LongevityCatalog.getProtocol(by: "RESP-01")
        XCTAssertNotNil(sigh)
        XCTAssertEqual(sigh?.durationSeconds, 26)
        XCTAssertEqual(sigh?.category, .nervousSystem)
    }
    
    func testBiologicalAgeCalculation() {
        var profile = UserProfile(
            chronologicalAge: 30,
            dailyScreenHours: 9.0,         // +2.5 ans
            dailyUnconsciousUnlocks: 70,   // +1.8 ans
            hasJointStiffness: true,       // +1.5 ans
            afternoonBrainFog: true        // +1.0 ans
        )
        
        profile.recalculateBiologicalAge()
        
        // 30 + 2.5 + 1.8 + 1.5 + 1.0 = 36.8 ans
        XCTAssertEqual(profile.estimatedBiologicalAge, 36.8, accuracy: 0.1)
        XCTAssertLessThan(profile.currentVitalityScore, 70)
        
        // Test après complétion de 20 défis
        profile.completedChallengesCount = 20
        profile.recalculateBiologicalAge()
        XCTAssertLessThan(profile.estimatedBiologicalAge, 36.8, "Les défis validés doivent rajeunir l'âge biologique estimé.")
    }
    
    // Chaque créneau, avec et sans raideur articulaire : l'après-midi sans raideur
    // indexait allProtocols[4] dans un catalogue de 4 entrées.
    func testCircadianRecommendationCoversEverySlot() throws {
        let engine = ProtocolRecommendationEngine.shared
        for hour in [8, 14, 21] {
            let date = try XCTUnwrap(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: hour)))
            for stiffness in [true, false] {
                let profile = UserProfile(hasJointStiffness: stiffness)
                let recommendation = engine.recommendPriorityProtocol(for: profile, date: date)
                XCTAssertNotNil(LongevityCatalog.getProtocol(by: recommendation.id))
            }
        }
    }
}
