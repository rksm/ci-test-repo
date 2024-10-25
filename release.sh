name: CI
on:
    push:
        branches:
            - main
            - release
    pull_request:
        branches: ['**']
defaults:
    run:
        shell: bash

jobs:
    deploy-release:
        name: Deploy release
        runs-on: ubuntu-latest
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        environment:
            name: FOOO
            url: https://foo.example.com
        steps:
            - run: "echo 'The kubernetes cluster watches this workflow'"
