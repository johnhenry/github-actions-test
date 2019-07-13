workflow "build and test" {
    on = "push"
    resolves = ["update"]
}

action "update" {
    uses = "./action-a/"
}
