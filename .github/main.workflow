workflow "New workflow" {
    on = "push"
    resolves = ["action a"]
}

action "action a" {
    uses = "./.github/action-a/"
}
