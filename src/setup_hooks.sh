#!/usr/bin/env bash

# Copy the pre-commit hook to the .git/hooks directory
cp "src/hooks/pre-commit" ".git/hooks/"
chmod +x .git/hooks/pre-commit

echo -e "Pre-commit hook installed successfully!"
