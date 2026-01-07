#!/bin/bash

# Log tag for journal identification
TAG="UpdateMonitor"

# Check for security updates using DNF
# -q : quiet mode (suppress unnecessary output)
# security : filter only for security advisories
OUTPUT=$(sudo dnf updateinfo security -q)

# Check if the output variable is empty
if [ -z "$OUTPUT" ]; then
    # Variable is empty -> No updates found
    # Log with 'info' priority
    logger -t $TAG -p user.info "OK: System is secure. No security updates found."
    echo "Check result: SECURE"
else
    # Variable is not empty -> Updates exist
    # Log with 'crit' (critical) priority
    logger -t $TAG -p user.crit "CRITICAL: Security updates available! Please patch immediately."
    echo "Check result: CRITICAL UPDATES AVAILABLE"
fi
