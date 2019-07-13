workflow "New workflow" {
    on = "push"
    resolves = ["action a"]
}

action "action a" {
    uses = "./.github/action-a/"
    secrets = ["NPM_AUTH_TOKEN", "NPM_DUMMY_TOKEN"]
}
