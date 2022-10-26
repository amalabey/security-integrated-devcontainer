#!/bin/bash
echo "GitLeaks: Running secret scan"
gitleaks detect . --no-git -v
echo "GitLeaks: Done. Completed secret scan"