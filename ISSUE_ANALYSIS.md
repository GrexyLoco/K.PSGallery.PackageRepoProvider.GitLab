# Issue Analysis: GitHub Provider Test Failures

## Executive Summary
The test failures in the GitHub provider (`Invoke-Publish.Tests.ps1` and `Invoke-Install.Tests.ps1`) are caused by **incorrect path construction in the test files**, not by issues in the system under test (SUT).

**Verdict: The test cases are wrong.**

## Detailed Error Analysis

### Error Messages
```
CommandNotFoundException: The term 'C:\Users\gkump\source\repos\1d70f\K.PSGallery\K.PSGallery.PackageRepoProvider.GitHub/Private/Invoke-Publish.ps1' is not recognized...
CommandNotFoundException: The term 'C:\Users\gkump\source\repos\1d70f\K.PSGallery\K.PSGallery.PackageRepoProvider.GitHub/Private/Invoke-Install.ps1' is not recognized...
```

### Problem Identification
Notice the path separators in the error messages:
- `C:\Users\...\GitHub` (backslashes from Windows)
- **followed by** `/Private/Invoke-Publish.ps1` (forward slashes)

This creates an invalid mixed path format that Windows cannot resolve.

### Root Cause
The test files (`Invoke-Publish.Tests.ps1` and `Invoke-Install.Tests.ps1`) are using string concatenation to build paths:

**Problematic code pattern:**
```powershell
# Line ~10 in test files
. "$PSScriptRoot/Private/Invoke-Publish.ps1"
. "$PSScriptRoot/Private/Invoke-Install.ps1"
```

**Why this fails on Windows:**
- `$PSScriptRoot` on Windows contains: `C:\Users\...\GitHub`
- String concatenation adds: `/Private/Invoke-Publish.ps1`
- Result: `C:\Users\...\GitHub/Private/Invoke-Publish.ps1` ❌
- Windows cannot locate files with mixed separators

## Solution

### Fix for GitHub Provider Tests
Replace the string concatenation with `Join-Path`:

**Current (broken) code:**
```powershell
BeforeAll {
    . "$PSScriptRoot/Private/Invoke-Publish.ps1"
}
```

**Corrected code:**
```powershell
BeforeAll {
    $scriptPath = Join-Path $PSScriptRoot "Private" | Join-Path -ChildPath "Invoke-Publish.ps1"
    . $scriptPath
}
```

Or alternatively:
```powershell
BeforeAll {
    . (Join-Path $PSScriptRoot "Private/Invoke-Publish.ps1")
}
```

### Files to Fix
In the GitHub provider repository, update these test files:
1. `Tests/Invoke-Publish.Tests.ps1` (line ~10)
2. `Tests/Invoke-Install.Tests.ps1` (line ~10)

## Why This Happens
- PowerShell's `$PSScriptRoot` uses platform-native separators (backslash on Windows)
- Hardcoded forward slashes in string concatenation don't get converted
- `Join-Path` automatically uses the correct separator for the current platform

## Testing with InModuleScope
As suggested, if testing private functions that aren't exported from a module, use `InModuleScope`:

```powershell
BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot/../K.PSGallery.PackageRepoProvider.GitHub.psd1" -Force
}

Describe "Invoke-Publish" {
    It "Should publish package" {
        InModuleScope K.PSGallery.PackageRepoProvider.GitHub {
            # Can now test private Invoke-Publish function
            # without dot-sourcing the script file directly
            $result = Invoke-Publish -PackagePath "test.nupkg"
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
```

## Benefits of Using Join-Path
1. **Cross-platform compatibility** - Works on Windows, Linux, macOS
2. **Automatic separator handling** - Uses `\` on Windows, `/` on Unix
3. **Path normalization** - Handles edge cases like double slashes
4. **Prevents this exact error** - No mixed separator issues

## Verification Steps
After fixing the test files:

1. Run the tests:
   ```powershell
   Invoke-Pester -Path ./Tests/Invoke-Publish.Tests.ps1
   Invoke-Pester -Path ./Tests/Invoke-Install.Tests.ps1
   ```

2. Verify on Windows that paths resolve correctly
3. All 9 tests in Invoke-Publish.Tests.ps1 should pass
4. All 14 tests in Invoke-Install.Tests.ps1 should pass

## Conclusion
**Who is wrong?** The test cases are wrong, not the SUT (Invoke-Publish.ps1 and Invoke-Install.ps1).

**What is the error?** String concatenation for path building causes mixed path separators on Windows.

**What is the solution?** Use `Join-Path` cmdlet for all path construction in test files.

This issue has been documented and the GitLab provider repository now includes:
- Proper test infrastructure using `Join-Path`
- TESTING.md documentation with best practices
- Working example tests that demonstrate the correct approach
