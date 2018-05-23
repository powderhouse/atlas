import SwiftCLI
import AtlasCore
import AtlasCommands

let cli = CLI(name: "Atlas", version: "0.0.1", description: "Powderhouse Studios Atlas")

let atlasCore: AtlasCore = AtlasCore()

cli.commands = [
    CommitCommand(atlasCore),
    CommitMessageCommand(atlasCore),
    ImportCommand(atlasCore),
    InfoCommand(atlasCore),
    LogCommand(atlasCore),
    LoginCommand(atlasCore),
    LogoutCommand(atlasCore),
    ProjectsCommand(atlasCore),
    PurgeCommand(atlasCore),
    SearchCommand(atlasCore),
    StageCommand(atlasCore),
    StagedCommand(atlasCore),
    StartProjectCommand(atlasCore),
    StatusCommand(atlasCore),
    UnstageCommand(atlasCore),
    UnstagedCommand(atlasCore),
]

_ = cli.go()


