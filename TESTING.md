# Testing Documentation

## Issue: Path Separator Bug in Test Files

### Problem Description
Test files in the GitHub provider repository were failing with `CommandNotFoundException` errors because they used incorrect path separators when dot-sourcing PowerShell scripts on Windows.

**Symptoms:**
```
CommandNotFoundException: The term 'C:\Users\...\GitHub/Private/Invoke-Publish.ps1' is not recognized...
```

Note the mixed path separators: backslashes (`\`) from Windows paths mixed with forward slashes (`/`) from string concatenation.

### Root Cause
Test files were using string concatenation to build file paths, like:
```powershell
. "$PSScriptRoot/Private/Invoke-Publish.ps1"
```

On Windows, `$PSScriptRoot` contains backslashes, so the result becomes:
```
C:\Users\...\GitHub\Private/Invoke-Publish.ps1  # Invalid mixed separators
```

This causes PowerShell to fail to locate the file because Windows doesn't recognize the mixed path format.

### Solution
Use `Join-Path` cmdlet for cross-platform path construction:

**Wrong (causes issues on Windows):**
```powershell
. "$PSScriptRoot/Private/Invoke-Publish.ps1"
```

**Correct (works on all platforms):**
```powershell
$scriptPath = Join-Path $PSScriptRoot "Private" | Join-Path -ChildPath "Invoke-Publish.ps1"
. $scriptPath
```

Or more concisely:
```powershell
. (Join-Path $PSScriptRoot "Private/Invoke-Publish.ps1")
```

### Best Practices for Test Files

1. **Always use `Join-Path`** for constructing file paths
2. **Use `InModuleScope`** when testing private functions that aren't exported
3. **Organize tests** to mirror the module structure (Tests/ directory)
4. **Use BeforeAll** blocks for script loading in Pester 5.x

### Example Test Structure

```powershell
BeforeAll {
    # Correct: Cross-platform path construction
    $scriptPath = Join-Path $PSScriptRoot ".." | 
                  Join-Path -ChildPath "Private" | 
                  Join-Path -ChildPath "SafeLogging.ps1"
    . $scriptPath
}

Describe "FunctionName" {
    Context "When condition" {
        It "Should behave correctly" {
            # Test implementation
        }
    }
}
```

## Running Tests

To run all tests in the Tests directory:
```powershell
Invoke-Pester -Path ./Tests
```

To run a specific test file:
```powershell
Invoke-Pester -Path ./Tests/SafeLogging.Tests.ps1
```

To run tests with detailed output:
```powershell
Invoke-Pester -Path ./Tests -Output Detailed
```

## Testing Private Functions

For testing private functions that aren't exported from the module, consider using Pester's `InModuleScope`:

```powershell
BeforeAll {
    Import-Module ./MyModule.psd1 -Force
}

Describe "Private Function Tests" {
    It "Should test private function" -TestCases @(
        @{ Input = "test"; Expected = "result" }
    ) {
        InModuleScope MyModule {
            # Can access private functions here
            PrivateFunction -Param $Input | Should -Be $Expected
        }
    }
}
```
