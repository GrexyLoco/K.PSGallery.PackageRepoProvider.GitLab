<#
.SYNOPSIS
    Determines the final release version from manual input or auto-detection.

.DESCRIPTION
    Evaluates if a manual version override is provided, otherwise uses the
    auto-detected version from K.Actions.NextVersion.

    SIMPLIFIED LOGIC: Every push to main results in a release. If no version
    bump is detected (bumpType=none), we default to a patch bump to ensure
    the package is always published with the latest code.

.PARAMETER ManualVersion
    Optional manual version override from workflow input.

.PARAMETER AutoBumpType
    Auto-detected bump type from K.Actions.NextVersion (major/minor/patch/none).

.PARAMETER AutoNewVersion
    Auto-detected new version from K.Actions.NextVersion.

.PARAMETER CurrentVersion
    Current version from the manifest file (needed for patch bump fallback).

.OUTPUTS
    Sets GITHUB_OUTPUT variables: final-version, should-release, bump-type
    Writes workflow summary to GITHUB_STEP_SUMMARY.

.EXAMPLE
    ./Determine-Version.ps1 -ManualVersion "1.2.3"
    ./Determine-Version.ps1 -AutoBumpType "patch" -AutoNewVersion "0.1.5" -CurrentVersion "0.1.4"
    ./Determine-Version.ps1 -AutoBumpType "none" -CurrentVersion "1.2.3"  # Will bump to 1.2.4

.NOTES
    Platform-independent script for GitHub Actions workflows.
    Handles both manual version override and automatic version detection.

    CHANGE: Removed "skip if no bump" logic. Every push = release.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ManualVersion = '',

    [Parameter(Mandatory = $false)]
    [string]$AutoBumpType = '',

    [Parameter(Mandatory = $false)]
    [string]$AutoNewVersion = '',

    [Parameter(Mandatory = $false)]
    [string]$CurrentVersion = ''
)

# Helper function to bump patch version
function Get-PatchBumpedVersion {
    param([string]$Version)

    if ([string]::IsNullOrWhiteSpace($Version)) {
        return '0.1.0'
    }

    $parts = $Version.Split('.')
    if ($parts.Count -ge 3) {
        $major = [int]$parts[0]
        $minor = [int]$parts[1]
        $patch = [int]$parts[2] + 1
        return "$major.$minor.$patch"
    }

    return '0.1.0'
}

if ($ManualVersion) {
    # Manual version override
    Write-Output "🎯 Manual version override: $ManualVersion"
    "final-version=$ManualVersion" >> $env:GITHUB_OUTPUT
    "should-release=true" >> $env:GITHUB_OUTPUT
    "bump-type=manual" >> $env:GITHUB_OUTPUT

    "<details open><summary>📌 Manual Version Override</summary>" >> $env:GITHUB_STEP_SUMMARY
    "" >> $env:GITHUB_STEP_SUMMARY
    "**Override Version:** ``$ManualVersion``" >> $env:GITHUB_STEP_SUMMARY
    "" >> $env:GITHUB_STEP_SUMMARY
    "</details>" >> $env:GITHUB_STEP_SUMMARY
} else {
    # Auto-detected version
    Write-Output "🔍 Auto-detected bump type: $AutoBumpType"
    Write-Output "🔍 Auto-detected version: $AutoNewVersion"
    Write-Output "🔍 Current version: $CurrentVersion"

    # SIMPLIFIED: Every push results in a release
    # If no bump detected, default to patch bump
    if ($AutoBumpType -eq 'none' -or [string]::IsNullOrWhiteSpace($AutoNewVersion)) {
        $finalVersion = Get-PatchBumpedVersion -Version $CurrentVersion
        $finalBumpType = 'patch'

        Write-Output "⚡ No explicit bump detected - defaulting to patch: $CurrentVersion → $finalVersion"

        "<details open><summary>⚡ Default Patch Bump</summary>" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "No explicit version bump detected from merged branches." >> $env:GITHUB_STEP_SUMMARY
        "Defaulting to **patch bump** to ensure package is published." >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "| Property | Value |" >> $env:GITHUB_STEP_SUMMARY
        "|----------|-------|" >> $env:GITHUB_STEP_SUMMARY
        "| **Current Version** | ``$CurrentVersion`` |" >> $env:GITHUB_STEP_SUMMARY
        "| **New Version** | ``$finalVersion`` |" >> $env:GITHUB_STEP_SUMMARY
        "| **Bump Type** | ``$finalBumpType`` (default) |" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "</details>" >> $env:GITHUB_STEP_SUMMARY
    } else {
        $finalVersion = $AutoNewVersion
        $finalBumpType = $AutoBumpType

        "<details open><summary>⬆️ Version Bump Detected</summary>" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "| Property | Value |" >> $env:GITHUB_STEP_SUMMARY
        "|----------|-------|" >> $env:GITHUB_STEP_SUMMARY
        "| **Bump Type** | ``$finalBumpType`` |" >> $env:GITHUB_STEP_SUMMARY
        "| **New Version** | ``$finalVersion`` |" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "</details>" >> $env:GITHUB_STEP_SUMMARY
    }

    "final-version=$finalVersion" >> $env:GITHUB_OUTPUT
    "bump-type=$finalBumpType" >> $env:GITHUB_OUTPUT
    "should-release=true" >> $env:GITHUB_OUTPUT  # ALWAYS release!
}
