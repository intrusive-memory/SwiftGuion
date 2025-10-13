# Performance Testing

This document describes how performance testing works in SwiftGuion.

## Overview

Performance tests are tracked as metrics over time rather than pass/fail tests. This allows you to monitor performance trends without failing builds due to minor performance variations or slower CI infrastructure.

## Architecture

### Separate Workflows

1. **Main Tests** (`.github/workflows/tests.yml`)
   - Runs all functional tests
   - Generates code coverage
   - Skips performance tests
   - Must pass for builds to succeed

2. **Performance Tests** (`.github/workflows/performance.yml`)
   - Runs only performance benchmarks
   - Never fails the build
   - Tracks metrics over time
   - Alerts on significant regressions (>50%)

### Performance Metrics Tracked

The following benchmarks are tracked:

- **Large Document Save (5000 elements)**: Time to save a document with 5000 elements
- **Large Document Load (5000 elements)**: Time to load a document with 5000 elements
- **Rapid Save/Load Cycle Average**: Average time for a save/load cycle
- **Scene Location Cache Load (200 scenes)**: Time to load a document with 200 scene headings using location caching

## Implementation Details

### Test Structure

Performance tests are in `Tests/SwiftGuionTests/IntegrationTests.swift`:
- `testLargeDocumentPerformance()` - Lines 158-235
- `testRapidSaveLoad()` - Lines 379-430
- `testSceneLocationCachingPerformance()` - Lines 432-483

These tests:
1. Measure operation timing using `Date().timeIntervalSince()`
2. Print metrics in a parseable format
3. Perform correctness assertions but NOT performance assertions
4. Always succeed (metrics are reported, not evaluated)

### Metric Collection

The performance workflow:
1. Runs performance tests
2. Extracts timing data from test output using grep/sed
3. Formats metrics as JSON for `github-action-benchmark`
4. Uploads to GitHub Pages for visualization

### Visualization

Performance trends are visualized at:
```
https://intrusive-memory.github.io/SwiftGuion/dev/bench/
```

The visualization shows:
- Historical performance data
- Commit information for each data point
- Trend lines
- Regression alerts

## Running Locally

To run performance tests locally:

```bash
# Run all integration tests (including performance)
swift test --filter IntegrationTests

# Run specific performance test
swift test --filter IntegrationTests.testLargeDocumentPerformance
```

Performance metrics will be printed to the console but not tracked in the historical database.

## Regression Detection

The workflow automatically:
- Compares current metrics against historical baseline
- Alerts if performance degrades by more than 50%
- Comments on PRs with performance comparisons
- Never fails the build

## Adding New Performance Tests

To add a new performance benchmark:

1. Add test method to `IntegrationTests.swift`:
```swift
func testMyPerformance() async throws {
    let startTime = Date()

    // ... your performance test code ...

    let elapsed = Date().timeIntervalSince(startTime)

    // Report metric (no assertions!)
    print("📊 PERFORMANCE METRICS:")
    print("   My Operation: \\(String(format: "%.3f", elapsed))s")
}
```

2. Update `.github/workflows/performance.yml` to extract your metric:
```bash
if grep -q "My Operation:" performance-output.log; then
  MY_TIME=$(grep "My Operation:" performance-output.log | grep -oE '[0-9]+\\.[0-9]+')
  echo "  {\"name\": \"My Operation Description\", \"unit\": \"seconds\", \"value\": $MY_TIME}," >> performance-results.json
fi
```

3. Run the workflow to establish a baseline

## Best Practices

1. **No Assertions**: Performance tests should never fail - they only measure
2. **Consistent Workloads**: Use fixed input sizes for reproducible results
3. **Warmup**: Consider adding warmup runs for JIT-compiled operations
4. **Multiple Runs**: Average multiple runs to reduce noise
5. **Document Changes**: When making performance improvements, document expected impact
6. **Baseline Updates**: After intentional architectural changes, expect baseline shifts

## Troubleshooting

### Tests are being skipped in main workflow

Check that `--skip` flags in `.github/workflows/tests.yml` match test names exactly.

### Metrics not appearing in GitHub Pages

1. Ensure `gh-pages` branch exists
2. Check GitHub Pages settings in repository settings
3. Verify workflow has `contents: write` permission
4. Check workflow logs for errors

### False regression alerts

If infrastructure changes cause baseline shifts:
1. Run tests multiple times to establish new baseline
2. Consider adjusting alert threshold in workflow
3. Document infrastructure changes in commit message

## Further Reading

- [github-action-benchmark](https://github.com/benchmark-action/github-action-benchmark)
- [XCTest Performance Testing](https://developer.apple.com/documentation/xctest/performance_tests)
