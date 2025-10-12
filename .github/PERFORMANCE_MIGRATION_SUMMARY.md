# Performance Test Migration Summary

## Overview

Performance tests have been migrated from pass/fail assertions to metric tracking. This change ensures that:
- Performance variations don't fail builds
- CI infrastructure differences don't cause false failures
- Performance trends are tracked over time
- Regressions are detected but don't block merges

## What Changed

### 1. Workflow Separation

**Before:** Single test workflow that could fail on performance issues
**After:** Two separate workflows:

- **`.github/workflows/tests.yml`** - Functional tests only, must pass
- **`.github/workflows/performance.yml`** - Performance metrics only, never fails

### 2. Test Modifications

All performance assertions have been removed and replaced with metric reporting:

**Modified Tests:**
- `IntegrationTests.testLargeDocumentPerformance` (/Tests/SwiftGuionTests/IntegrationTests.swift:158-235)
- `IntegrationTests.testRapidSaveLoad` (/Tests/SwiftGuionTests/IntegrationTests.swift:379-430)
- `IntegrationTests.testSceneLocationCachingPerformance` (/Tests/SwiftGuionTests/IntegrationTests.swift:432-483)
- `DocumentExportTests.testExportPerformance` (/Tests/SwiftGuionTests/DocumentExportTests.swift:451-484)
- `DocumentImportTests.testImportVsNativePerformance` (/Tests/SwiftGuionTests/DocumentImportTests.swift:217-254)
- `GuionSerializationTests.testLargeDocumentPerformance` (/Tests/SwiftGuionTests/GuionSerializationTests.swift:202-255)
- `SceneBrowserUITests.testLargeScriptPerformance` (/Tests/SwiftGuionTests/SceneBrowserUITests.swift:454-472)

**Before:**
```swift
XCTAssertLessThan(saveTime, 60.0, "Save time should be < 60 seconds")
```

**After:**
```swift
print("📊 PERFORMANCE METRICS:")
print("   Save time: \(String(format: "%.3f", saveTime))s")
```

### 3. GitHub Actions Integration

Performance metrics are now:
- Extracted from test output as JSON
- Tracked over time using `github-action-benchmark`
- Visualized on GitHub Pages
- Compared against historical baseline
- Alert on >50% regression (but don't fail)

### 4. Metrics Tracked

The following performance benchmarks are now tracked:

| Metric | Test | Description |
|--------|------|-------------|
| Large Document Save | IntegrationTests | Time to save 5000 elements |
| Large Document Load | IntegrationTests | Time to load 5000 elements |
| Rapid Save/Load Cycle | IntegrationTests | Average cycle time |
| Scene Location Cache Load | IntegrationTests | Load with 200 cached scenes |
| Fountain Export | DocumentExportTests | Export 1000 elements to Fountain |
| FDX Export | DocumentExportTests | Export 1000 elements to FDX |
| Native .guion Load | DocumentImportTests | Load 500 elements |
| Serialization Save | GuionSerializationTests | Save 1000 elements |
| Serialization Load | GuionSerializationTests | Load 1000 elements |
| BigFish Scene Browser | SceneBrowserUITests | Extract scene browser data |

## How to Use

### Running Locally

Performance tests still work locally:

```bash
# Run all tests (including performance)
swift test

# Run specific performance test
swift test --filter IntegrationTests.testLargeDocumentPerformance
```

Metrics are printed to console but not tracked historically.

### In CI

Performance tests run automatically:
- On push to main/master
- On pull requests
- Can be triggered manually via workflow_dispatch

### Viewing Results

Performance trends are visualized at:
```
https://intrusive-memory.github.io/SwiftGuion/dev/bench/
```

Results are also shown in:
- GitHub Actions workflow summary
- PR comments (if regression detected)

## Benefits

1. **No False Failures:** CI infrastructure variations don't fail builds
2. **Historical Tracking:** See performance trends over time
3. **Regression Detection:** Automatic alerts on >50% degradation
4. **Better Visibility:** Performance data accessible to all contributors
5. **Informed Decisions:** Make architectural changes with performance data
6. **Separate Concerns:** Functional correctness vs. performance optimization

## Migration Checklist

- [x] Create separate performance workflow
- [x] Remove performance assertions from tests
- [x] Add metric reporting to tests
- [x] Configure github-action-benchmark
- [x] Update main test workflow to skip performance tests
- [x] Document new approach
- [x] Create gh-pages branch (happens automatically on first run)

## Future Enhancements

Potential improvements to consider:

1. **Baseline Adjustment:** Mechanism to update baseline after intentional changes
2. **Environment Tagging:** Track different CI environments separately
3. **Custom Thresholds:** Per-metric regression thresholds
4. **Comparison View:** Side-by-side PR vs. main comparison
5. **Performance Budget:** Define acceptable ranges for each metric

## References

- Performance testing guide: `.github/PERFORMANCE.md`
- GitHub Action Benchmark: https://github.com/benchmark-action/github-action-benchmark
- Workflow files:
  - `.github/workflows/tests.yml`
  - `.github/workflows/performance.yml`
