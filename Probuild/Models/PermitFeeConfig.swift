import Foundation

struct PermitFeeConfig {
    let city: String
    let baseRate: Double
    let minFee: Double
    let planReviewRate: Double
    let safetyLevyRate: Double
    let deckBase: Double
    let deckPer100SqFt: Double
    let electricalFee: Double
    let plumbingFee: Double
    let mechFee: Double
    let demoFee: Double
    let currency: String

    static let configs: [String: PermitFeeConfig] = [
        "Calgary": .init(
            city: "Calgary",
            baseRate: 0.006,
            minFee: 172,
            planReviewRate: 0.30,
            safetyLevyRate: 0.001,
            deckBase: 240,
            deckPer100SqFt: 55,
            electricalFee: 220,
            plumbingFee: 220,
            mechFee: 195,
            demoFee: 195,
            currency: "CAD"
        ),
        "Edmonton": .init(
            city: "Edmonton",
            baseRate: 0.0055,
            minFee: 155,
            planReviewRate: 0.25,
            safetyLevyRate: 0,
            deckBase: 200,
            deckPer100SqFt: 45,
            electricalFee: 195,
            plumbingFee: 195,
            mechFee: 175,
            demoFee: 175,
            currency: "CAD"
        ),
        "Vancouver": .init(
            city: "Vancouver",
            baseRate: 0.009,
            minFee: 285,
            planReviewRate: 0.35,
            safetyLevyRate: 0,
            deckBase: 300,
            deckPer100SqFt: 65,
            electricalFee: 260,
            plumbingFee: 260,
            mechFee: 230,
            demoFee: 230,
            currency: "CAD"
        ),
        "Toronto": .init(
            city: "Toronto",
            baseRate: 0.0075,
            minFee: 195,
            planReviewRate: 0.30,
            safetyLevyRate: 0,
            deckBase: 270,
            deckPer100SqFt: 58,
            electricalFee: 240,
            plumbingFee: 240,
            mechFee: 210,
            demoFee: 210,
            currency: "CAD"
        ),
        "Winnipeg": .init(
            city: "Winnipeg",
            baseRate: 0.005,
            minFee: 140,
            planReviewRate: 0.25,
            safetyLevyRate: 0,
            deckBase: 185,
            deckPer100SqFt: 40,
            electricalFee: 175,
            plumbingFee: 175,
            mechFee: 155,
            demoFee: 155,
            currency: "CAD"
        ),
        "Seattle": .init(
            city: "Seattle",
            baseRate: 0.0065,
            minFee: 200,
            planReviewRate: 0.65,
            safetyLevyRate: 0,
            deckBase: 250,
            deckPer100SqFt: 55,
            electricalFee: 210,
            plumbingFee: 210,
            mechFee: 190,
            demoFee: 190,
            currency: "USD"
        )
    ]
}
