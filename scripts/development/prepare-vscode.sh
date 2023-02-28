#!/bin/bash

# This script sets up a basic vscode environment
while IFS= read -r extension || [[ -n "$extension" ]]; do
    # Install the extension using the code --install-extension command
    echo "Installing extension $extension"
    code --install-extension "$extension"
done <".vscode/extensions"
