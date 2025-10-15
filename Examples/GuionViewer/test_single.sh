#!/bin/bash
# Run a single test and capture detailed output

cd /Users/stovak/Projects/SwiftGuion/Examples/GuionViewer

xcodebuild test \
  -scheme GuionViewer \
  -destination 'platform=macOS' \
  -only-testing:GuionViewerTests/ExportServiceTests/testExportToFountainSuccess \
  2>&1 | tee test_output.log

# Extract error messages
echo "=== ERRORS ==="
grep -A 10 "error:" test_output.log || echo "No build errors"
echo "=== TEST FAILURES ==="
grep -A 10 "XCTAssert" test_output.log || echo "No assertion failures found"
