import Testing
@testable import MCStatsDataLayer

struct JavaMOTDTests {
    @Test func preservedAllLegacySections() {
        let sections = JavaServerStatusParser.parseJavaMOTD(
            "§6BisquitMC Network §7» [§c1.21.1–26.3§7]\n§c➥ §fЛогово Пыжа тут!"
        )

        #expect(sections.map(\.text).joined() == "BisquitMC Network » [1.21.1–26.3]\n➥ Логово Пыжа тут!")
        #expect(sections.map(\.color) == [
            MOTDColor.Gold.rawValue,
            MOTDColor.Gray.rawValue,
            MOTDColor.Red.rawValue,
            MOTDColor.Gray.rawValue,
            MOTDColor.Red.rawValue,
            MOTDColor.White.rawValue
        ])
    }

    @Test func preservedUnformattedText() {
        let sections = JavaServerStatusParser.parseJavaMOTD("First line\nSecond line")

        #expect(sections.count == 1)
        #expect(sections.first?.text == "First line\nSecond line")
    }

    @Test func handledTrailingSectionSign() {
        let sections = JavaServerStatusParser.parseJavaMOTD("§6Hello§")

        #expect(sections.first?.text == "Hello§")
        #expect(sections.first?.color == MOTDColor.Gold.rawValue)
    }

    @Test func preservedNestedJSONSections() throws {
        let status = try JavaServerStatusParser.parseServerResponse(
            stringInput: #"""
            {
                "description": {
                    "text": "BisquitMC Network ",
                    "color": "gold",
                    "bold": true,
                    "extra": [
                        {"text": "» [", "color": "gray", "bold": false},
                        {"text": "1.21.1–26.3", "color": "red"},
                        {"text": "]\n", "color": "gray"},
                        {"text": "➥ ", "color": "red", "extra": [
                            {"text": "Логово Пыжа тут!", "color": "white"}
                        ]}
                    ]
                }
            }
            """#,
            config: nil
        )

        let sections = try #require(status.description?.messageSections)
        #expect(status.description?.getRawText() == "BisquitMC Network » [1.21.1–26.3]\n➥ Логово Пыжа тут!")
        #expect(sections.count == 6)
        #expect(sections.first?.formatters.contains(.bold) == true)
        #expect(sections[1].formatters.contains(.bold) == false)
        #expect(sections.last?.color == MOTDColor.White.rawValue)
    }
}
