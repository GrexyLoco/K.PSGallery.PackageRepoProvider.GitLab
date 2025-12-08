#
# SafeLogging.Tests.ps1
# Pester tests for SafeLogging module functions
#

BeforeAll {
    # Use Join-Path for cross-platform compatibility instead of string concatenation with /
    $scriptPath = Join-Path $PSScriptRoot ".." | Join-Path -ChildPath "Private" | Join-Path -ChildPath "SafeLogging.ps1"
    . $scriptPath
}

Describe "Write-SafeInfoLog" {
    Context "When LoggingModule is not available" {
        It "Should write output with INFO prefix" {
            $output = Write-SafeInfoLog -Message "Test message" 6>&1
            $output | Should -Match "\[INFO\].*Test message"
        }
        
        It "Should handle additional context" {
            $output = Write-SafeInfoLog -Message "Test" -Additional @{Key1 = "Value1"} 6>&1
            $outputString = $output -join "`n"
            $outputString | Should -Match "Key1.*Value1"
        }
    }
}

Describe "Write-SafeWarningLog" {
    Context "When LoggingModule is not available" {
        It "Should write warning message" {
            $warnings = @()
            $null = Write-SafeWarningLog -Message "Test warning" 3>&1 | ForEach-Object { $warnings += $_ }
            $warnings[0].Message | Should -Match "Test warning"
        }
        
        It "Should handle additional context" {
            $warnings = @()
            $null = Write-SafeWarningLog -Message "Test" -Additional @{Key1 = "Value1"} 3>&1 | ForEach-Object { $warnings += $_ }
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Write-SafeErrorLog" {
    Context "When LoggingModule is not available" {
        It "Should write error message" {
            $errors = @()
            try {
                Write-SafeErrorLog -Message "Test error" -ErrorAction SilentlyContinue 2>&1 | ForEach-Object { $errors += $_ }
            } catch {
                # Suppress errors for testing
            }
            $errors.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Write-SafeDebugLog" {
    Context "When LoggingModule is not available" {
        It "Should write verbose output with DEBUG prefix" {
            $VerbosePreference = 'Continue'
            $output = Write-SafeDebugLog -Message "Test debug" 4>&1
            $VerbosePreference = 'SilentlyContinue'
            $output | Should -Match "\[DEBUG\].*Test debug"
        }
        
        It "Should handle additional context" {
            $VerbosePreference = 'Continue'
            $output = Write-SafeDebugLog -Message "Test" -Additional @{Key1 = "Value1"} 4>&1
            $VerbosePreference = 'SilentlyContinue'
            $output | Should -Not -BeNullOrEmpty
        }
    }
}
