import XCTest
@testable import Mythic

final class LegendaryInterfaceTests: XCTestCase {

    func testCommandExecution() async throws {
        let expectation = XCTestExpectation(description: "Command should execute successfully")

        try await Legendary.command(arguments: ["--version"], identifier: "testCommand") { output in
            XCTAssertTrue(output.stdout.contains("legendary"))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testStopCommand() {
        let expectation = XCTestExpectation(description: "Command should be stopped successfully")

        Task {
            try await Legendary.command(arguments: ["--version"], identifier: "testStopCommand", waits: false) { _ in }
            Legendary.stopCommand(identifier: "testStopCommand")
            XCTAssertNil(Legendary.runningCommands["testStopCommand"])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testInstallGame() async throws {
        let game = Mythic.Game(source: .epic, title: "Test Game", id: "test_game_id")
        let args = GameOperation.InstallArguments(game: game, type: .install, platform: .macOS, baseURL: nil, gameFolder: nil, optionalPacks: nil)

        do {
            try await Legendary.install(args: args)
        } catch {
            XCTFail("Installation failed with error: \(error)")
        }
    }

    func testLaunchGame() async throws {
        let game = Mythic.Game(source: .epic, title: "Test Game", id: "test_game_id")

        do {
            try await Legendary.launch(game: game)
        } catch {
            XCTFail("Launch failed with error: \(error)")
        }
    }

    func testGetInstalledGames() throws {
        do {
            let games = try Legendary.getInstalledGames()
            XCTAssertFalse(games.isEmpty, "No games found")
        } catch {
            XCTFail("Failed to get installed games with error: \(error)")
        }
    }

    func testGetGameMetadata() throws {
        let game = Mythic.Game(source: .epic, title: "Test Game", id: "test_game_id")

        do {
            let metadata = try Legendary.getGameMetadata(game: game)
            XCTAssertNotNil(metadata, "Metadata should not be nil")
        } catch {
            XCTFail("Failed to get game metadata with error: \(error)")
        }
    }

    func testSignedIn() {
        XCTAssertTrue(Legendary.signedIn(), "User should be signed in")
    }

    func testWhoAmI() {
        let user = Legendary.whoAmI()
        XCTAssertNotEqual(user, "Nobody", "User should be signed in")
    }
}
