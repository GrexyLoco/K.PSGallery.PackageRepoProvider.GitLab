<#
.SYNOPSIS
    Determines the final release version from manual input or auto-detection.

.DESCRIPTION
    Evaluates if a manual version override is provided, otherwise uses the
    auto-detected version from K.Actions.NextVersion. Sets appropriate outputs
    for subsequent workflow steps.

.PARAMETER ManualVersion
    Optional manual version override from workflow input.

.PARAMETER AutoBumpType
    Auto-detected bump type from K.Actions.NextVersion (major/minor/patch/none).

.PARAMETER AutoNewVersion
    Auto-detected new version from K.Actions.NextVersion.

.OUTPUTS
    Sets GITHUB_OUTPUT variables: final-version, should-release, bump-type
    Writes workflow summary to GITHUB_STEP_SUMMARY.

.EXAMPLE
    ./Determine-Version.ps1 -ManualVersion "1.2.3"
    ./Determine-Version.ps1 -AutoBumpType "patch" -AutoNewVersion "0.1.5"

.NOTES
    Platform-independent script for GitHub Actions workflows.
    Handles both manual version override and automatic version detection.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ManualVersion = '',
    
    [Parameter(Mandatory = $false)]
    [string]$AutoBumpType = '',
    
    [Parameter(Mandatory = $false)]
    [string]$AutoNewVersion = ''
)

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
    
    "final-version=$AutoNewVersion" >> $env:GITHUB_OUTPUT
    "bump-type=$AutoBumpType" >> $env:GITHUB_OUTPUT
    
    if ($AutoBumpType -eq 'none') {
        "should-release=false" >> $env:GITHUB_OUTPUT
        
        "<details open><summary>🔁 No Release Required</summary>" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "No version changes detected. Workflow will exit gracefully." >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "</details>" >> $env:GITHUB_STEP_SUMMARY
    } else {
        "should-release=true" >> $env:GITHUB_OUTPUT
        
        "<details open><summary>⬆️ Version Bump Detected</summary>" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "| Property | Value |" >> $env:GITHUB_STEP_SUMMARY
        "|----------|-------|" >> $env:GITHUB_STEP_SUMMARY
        "| **Bump Type** | ``$AutoBumpType`` |" >> $env:GITHUB_STEP_SUMMARY
        "| **New Version** | ``$AutoNewVersion`` |" >> $env:GITHUB_STEP_SUMMARY
        "" >> $env:GITHUB_STEP_SUMMARY
        "</details>" >> $env:GITHUB_STEP_SUMMARY
    }
}
