# Running Tests

This directory contains Pester tests for the K.PSGallery.PackageRepoProvider.GitLab module.

## Prerequisites
- PowerShell 7.0 or later
- Pester 5.0 or later

## Running All Tests
```powershell
Invoke-Pester -Path ./Tests
```

## Running Specific Test File
```powershell
Invoke-Pester -Path ./Tests/SafeLogging.Tests.ps1
```

## Running with Detailed Output
```powershell
Invoke-Pester -Path ./Tests -Output Detailed
```

## Test Files
- **SafeLogging.Tests.ps1** - Tests for the SafeLogging module functions

## Important Notes
All test files use `Join-Path` for path construction to ensure cross-platform compatibility. This prevents path separator issues on Windows.

See [TESTING.md](../TESTING.md) and [ISSUE_ANALYSIS.md](../ISSUE_ANALYSIS.md) for more information about proper test file structure.
