# LegendaryInterface Documentation

## Overview

The `Legendary` class controls the function of the "legendary" CLI, which is the backbone of the launcher's Epic Games Store (EGS) capabilities. This class provides various methods to interact with the legendary CLI, including executing commands, installing games, launching games, and retrieving game metadata.

## Properties

- `configurationFolder`: The URL of the configuration folder for legendary.
- `configLocation`: The file location for legendary's configuration files.
- `log`: Logger instance for legendary.
- `commandCache`: Cache for storing command outputs.
- `runningCommands`: Dictionary to monitor running commands and their identifiers.

## Methods

### `command(arguments:identifier:waits:input:environment:completion:)`

Executes Legendary's command-line process with the specified arguments and handles its output and input interactions.

- **Parameters:**
  - `args`: The arguments to pass to the command-line process.
  - `identifier`: A unique identifier for the command-line process.
  - `waits`: Indicates whether the function should wait for the command-line process to complete before returning.
  - `input`: A closure that processes the output of the command-line process and provides input back to it.
  - `environment`: Additional environment variables to set for the command-line process.
  - `completion`: A closure to call with the output of the command-line process.

### `stopCommand(identifier:forced:)`

Stops the execution of a command based on its identifier.

- **Parameters:**
  - `identifier`: The unique identifier of the command to be stopped.
  - `forced`: Indicates whether the command should be forcibly stopped.

### `stopAllCommands(forced:)`

Stops the execution of all commands.

- **Parameters:**
  - `forced`: Indicates whether all commands should be forcibly stopped.

### `install(args:priority:)`

Installs, updates, or repairs games using legendary.

- **Parameters:**
  - `args`: Specific installation arguments.
  - `priority`: Whether the game should interrupt currently queued game installations.

### `move(game:newPath:)`

Moves a game to a new path.

- **Parameters:**
  - `game`: The game to be moved.
  - `newPath`: The new path for the game.

### `signIn(authKey:)`

Signs in to Epic Games using an authentication key.

- **Parameters:**
  - `authKey`: The authentication key.

### `launch(game:)`

Launches a game.

- **Parameters:**
  - `game`: The game to be launched.

### `getGamePlatform(game:)`

Determines the platform of the game.

- **Parameters:**
  - `game`: The game whose platform is to be determined.

### `needsUpdate(game:)`

Determines if the game needs an update.

- **Parameters:**
  - `game`: The game to check for updates.

### `clearCommandCache()`

Wipes legendary's command cache.

### `whoAmI()`

Queries the user that is currently signed into Epic Games.

### `signedIn()`

Checks if the user is signed in to Epic Games.

### `getInstalledGames()`

Retrieves installed games from Epic Games services.

### `getGamePath(game:)`

Retrieves the installation path of a game.

- **Parameters:**
  - `game`: The game whose installation path is to be retrieved.

### `getInstallable()`

Retrieves installable games from Epic Games services.

### `getGameMetadata(game:)`

Retrieves game metadata as a JSON.

- **Parameters:**
  - `game`: The game whose metadata is to be retrieved.

### `getGameLaunchArguments(game:)`

Retrieves a game's launch arguments from Legendary's `installed.json` file.

- **Parameters:**
  - `game`: The game whose launch arguments are to be retrieved.

### `updateMetadata(forced:)`

Creates an asynchronous task to update Legendary's stored metadata.

- **Parameters:**
  - `forced`: Indicates whether the metadata update should be forced.

### `getImage(of:type:)`

Retrieves game thumbnail image from legendary's downloaded metadata.

- **Parameters:**
  - `of`: The game to fetch the thumbnail of.
  - `type`: The aspect ratio of the image to fetch the thumbnail of.

### `isAlias(game:)`

Checks if an alias of a game exists.

- **Parameters:**
  - `game`: Any string that may return an aliased output.

## Extensions

### `Legendary.ImageType`

Enumeration to specify image types.

- **Cases:**
  - `normal`
  - `tall`

### `Legendary.RetrievalType`

Enumeration to specify retrieval types.

- **Cases:**
  - `platform`
  - `launchArguments`

### `Legendary.UnableToRetrieveError`

Error indicating that Mythic is unable to retrieve the requested metadata for a game.

### `Legendary.IsNotLegendaryError`

Error indicating that the game is not an Epic game.

### `Legendary.OutputHandler`

Struct to hold closures for handling stdout and stderr output.

- **Properties:**
  - `stdout`: A closure to handle stdout output.
  - `stderr`: A closure to handle stderr output.

### `Legendary.NotSignedInError`

Error indicating that the user is not signed in to Epic Games.

### `Legendary.InstallationError`

Error indicating that the game installation failed.

- **Properties:**
  - `errorDescription`: A description of the installation error.
