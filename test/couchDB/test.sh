#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests

check "{"error":"unauthorized","reason":"Authentication required."}" bash -c "curl 127.0.0.1:5984"
# Report result
reportResults