<#
.SYNOPSIS
    Creates a complete GitHub release using K.PSGallery.Smartagr.

.DESCRIPTION
    Creates a complete semantic release with smart tags using the proven
    Draft → Smart Tags → Publish strategy from K.PSGallery.Smartagr.
    
    Falls back to gh CLI if Smartagr is not available.

.PARAMETER Version
    Semantic version without 'v' prefix (e.g., "1.2.3").

.PARAMETER BumpType
    Type of version bump (major/minor/patch/manual).

.PARAMETER ModuleName
    Name of the PowerShell module.

.PARAMETER Repository
    GitHub repository in format "owner/repo".

.OUTPUTS
    Sets GITHUB_OUTPUT variables: release-created, release-tag, release-url

.EXAMPLE
    ./Create-GitHubRelease.ps1 -Version "1.2.3" -BumpType "patch" -ModuleName "MyModule" -Repository "owner/repo"

.NOTES
    Platform-independent PowerShell script for GitHub Actions workflows.
    Uses K.PSGallery.Smartagr for release management.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $true)]
    [string]$BumpType,
    
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,
    
    [Parameter(Mandatory = $true)]
    [string]$Repository
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$releaseTag = "v$Version"

Write-Output "Creating release $releaseTag for $ModuleName"

# ═══════════════════════════════════════════════════════════════════════════
# 📦 Install K.PSGallery.Smartagr via PackageRepoProvider
# ═══════════════════════════════════════════════════════════════════════════
function Install-SmartagrModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Token,
        
        [Parameter(Mandatory = $true)]
        [string]$Owner
    )
    
    Write-Output "📦 Installing K.PSGallery.Smartagr via PackageRepoProvider..."
    
    # Step 1: Install PackageRepoProvider (if not already available)
    if (-not (Get-Module -ListAvailable -Name 'K.PSGallery.PackageRepoProvider')) {
        Write-Output "📥 Installing K.PSGallery.PackageRepoProvider..."
        
        try {
            $secureToken = ConvertTo-SecureString $Token -AsPlainText -Force
            $credential = New-Object PSCredential($Owner, $secureToken)
            
            $tempRepoName = 'GHPackages-Temp'
            $uri = "https://nuget.pkg.github.com/$Owner/index.json"
            
            Unregister-PSResourceRepository -Name $tempRepoName -ErrorAction SilentlyContinue
            Register-PSResourceRepository -Name $tempRepoName -Uri $uri -Trusted -ErrorAction Stop
            
            Install-PSResource -Name 'K.PSGallery.PackageRepoProvider' `
                -Repository $tempRepoName `
                -Credential $credential `
                -Scope CurrentUser `
                -TrustRepository `
                -ErrorAction Stop
            
            # PSResourceGet #1402 Workaround
            if ($IsLinux -or $IsMacOS) {
                $moduleName = 'K.PSGallery.PackageRepoProvider'
                $modulesPath = Join-Path $HOME '.local/share/powershell/Modules'
                $lowercasePath = Join-Path $modulesPath $moduleName.ToLower()
                $correctPath = Join-Path $modulesPath $moduleName
                
                if ((Test-Path $lowercasePath) -and -not (Test-Path $correctPath)) {
                    Rename-Item -Path $lowercasePath -NewName $moduleName -Force
                }
            }
            
            Unregister-PSResourceRepository -Name $tempRepoName -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Failed to install PackageRepoProvider: $($_.Exception.Message)"
            throw
        }
    }
    
    # Step 2: Import PackageRepoProvider
    try {
        Import-Module K.PSGallery.PackageRepoProvider -Force -ErrorAction Stop
        Write-Output "✅ PackageRepoProvider loaded"
    }
    catch {
        Write-Error "Failed to import PackageRepoProvider: $($_.Exception.Message)"
        throw
    }
    
    # Step 3: Install Smartagr via PackageRepoProvider
    try {
        Write-Output "📦 Installing K.PSGallery.Smartagr..."
        
        $repoName = 'GitHubPackages'
        $registryUri = "https://nuget.pkg.github.com/$Owner/index.json"
        
        Register-PackageRepo `
            -RepositoryName $repoName `
            -RegistryUri $registryUri `
            -Token $Token `
            -Trusted
        
        Install-Package `
            -RepositoryName $repoName `
            -PackageName 'K.PSGallery.Smartagr' `
            -Token $Token
        
        Import-Package -PackageName 'K.PSGallery.Smartagr'
        
        Remove-PackageRepo -RepositoryName $repoName -ErrorAction SilentlyContinue
        
        Write-Output "✅ K.PSGallery.Smartagr installed and imported"
    }
    catch {
        Write-Error "Failed to install Smartagr via PackageRepoProvider: $($_.Exception.Message)"
        Write-Output "📋 Error details:"
        Write-Output "  - Repository: $registryUri"
        Write-Output "  - Package: K.PSGallery.Smartagr"
        Write-Output "  - Error: $($_.Exception.Message)"
        throw
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# Install Smartagr (required for release management)
# ─────────────────────────────────────────────────────────────────────────────
$githubToken = $env:GITHUB_TOKEN
if (-not $githubToken) {
    Write-Error "❌ GITHUB_TOKEN environment variable is required but not set"
    exit 1
}

$owner = $Repository -split '/' | Select-Object -First 1

try {
    Install-SmartagrModule -Token $githubToken -Owner $owner
}
catch {
    Write-Error "❌ Failed to install Smartagr module"
    Write-Output "This is a critical error - release creation cannot proceed without Smartagr"
    exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Try Smartagr first (preferred method)
# ─────────────────────────────────────────────────────────────────────────────
$smartagrAvailable = $false
try {
    if (Get-Command -Name 'New-SmartRelease' -ErrorAction SilentlyContinue) {
        $smartagrAvailable = $true
    }
} catch {
    # Smartagr not available
}

if ($smartagrAvailable) {
    Write-Output "Using K.PSGallery.Smartagr for release creation"
    
    # Generate release notes for PowerShell module
    $timestamp = (Get-Date).ToUniversalTime().ToString('MMMM dd, yyyy \a\t HH:mm UTC')
    $releaseNotes = @"
## 🎉 Release $releaseTag

> **$BumpType** release • Released on $timestamp

### 📦 Quick Access
- 📁 [Source Code](https://github.com/$Repository)
- 🏷️ [This Release](https://github.com/$Repository/releases/tag/$releaseTag)

### 🚀 Installation
``````powershell
Install-Module -Name $ModuleName -RequiredVersion $Version
``````

---
*Auto-generated release*
"@

    # New-SmartRelease handles: Draft → Smart Tags → Publish
    $result = New-SmartRelease -TargetVersion $releaseTag -ReleaseNotes $releaseNotes -PushToRemote -Force
    
    if ($result.Success) {
        $releaseUrl = $result.ReleaseUrl
        
        # Set outputs
        "release-created=true" >> $env:GITHUB_OUTPUT
        "release-tag=$releaseTag" >> $env:GITHUB_OUTPUT
        "release-url=$releaseUrl" >> $env:GITHUB_OUTPUT
        
        Write-Output "✅ Release created successfully via Smartagr"
        Write-Output "   Tags created: $($result.TagsCreated -join ', ')"
        Write-Output "   URL: $releaseUrl"
    } else {
        throw "Smartagr release failed: $($result.GitHubReleaseResult.ErrorMessage)"
    }
} else {
    # ─────────────────────────────────────────────────────────────────────────────
    # Fallback: gh CLI (when Smartagr not available)
    # ─────────────────────────────────────────────────────────────────────────────
    Write-Output "Smartagr not available, using gh CLI fallback"
    
    $timestamp = (Get-Date).ToUniversalTime().ToString('MMMM dd, yyyy \a\t HH:mm UTC')
    $releaseNotes = @"
## 🎉 Release $releaseTag

> **$BumpType** release • Released on $timestamp

### 🚀 Installation
``````powershell
Install-Module -Name $ModuleName -RequiredVersion $Version
``````

---
*Auto-generated release*
"@

    Set-Content -Path 'release_notes.md' -Value $releaseNotes -Encoding utf8NoBOM

    # Delete existing release if exists
    try {
        $null = gh release view $releaseTag 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "⚠️ Release exists - deleting and recreating"
            gh release delete $releaseTag --yes 2>$null
            git tag -d $releaseTag 2>$null
            git push origin --delete $releaseTag 2>$null
            Start-Sleep -Seconds 2
        }
    } catch {
        # Release doesn't exist, continue
    }

    # Determine if prerelease
    $isPrerelease = $Version -match '(alpha|beta|rc|preview|pre)'
    $title = if ($isPrerelease) { "🧪 Prerelease $releaseTag" } else { "🚀 $ModuleName $releaseTag" }

    # ─────────────────────────────────────────────────────────────────────────────
    # Step 1: Create base tag FIRST (required for smart tags to reference)
    # ─────────────────────────────────────────────────────────────────────────────
    Write-Output "Creating base tag $releaseTag"
    
    # Configure git
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    
    # Create and push base tag
    git tag -a $releaseTag -m "Release $releaseTag"
    git push origin $releaseTag
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create base tag $releaseTag"
    }

    # ─────────────────────────────────────────────────────────────────────────────
    # Step 2: Create GitHub Release (Draft)
    # ─────────────────────────────────────────────────────────────────────────────
    Write-Output "Creating draft release"
    
    $ghArgs = @(
        'release', 'create', $releaseTag,
        '--title', $title,
        '--notes-file', 'release_notes.md',
        '--generate-notes',
        '--draft'
    )

    if ($isPrerelease) {
        $ghArgs += '--prerelease'
    }

    & gh @ghArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create GitHub release via gh CLI"
    }

    # ─────────────────────────────────────────────────────────────────────────────
    # Step 3: Create Smart Tags (v1, v1.2, latest)
    # ─────────────────────────────────────────────────────────────────────────────
    Write-Output "Creating smart tags"
    
    $versionParts = $Version -split '\.'
    $major = "v$($versionParts[0])"
    $minor = "v$($versionParts[0]).$($versionParts[1])"
    
    # Create/move smart tags pointing to base tag
    foreach ($smartTag in @($major, $minor, 'latest')) {
        # Delete existing tag if exists
        git tag -d $smartTag 2>$null
        git push origin --delete $smartTag 2>$null
        
        # Create new tag pointing to release tag
        git tag -f $smartTag $releaseTag
        git push origin $smartTag --force
        
        Write-Output "  Created smart tag: $smartTag -> $releaseTag"
    }

    # ─────────────────────────────────────────────────────────────────────────────
    # Step 4: Publish Release
    # ─────────────────────────────────────────────────────────────────────────────
    Write-Output "Publishing release"
    
    if ($isPrerelease) {
        gh release edit $releaseTag --draft=false
    } else {
        gh release edit $releaseTag --draft=false --latest
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to publish GitHub release"
    }

    $releaseUrl = "https://github.com/$Repository/releases/tag/$releaseTag"

    # Set outputs
    "release-created=true" >> $env:GITHUB_OUTPUT
    "release-tag=$releaseTag" >> $env:GITHUB_OUTPUT
    "release-url=$releaseUrl" >> $env:GITHUB_OUTPUT
    
    Write-Output "✅ Release created via gh CLI fallback"
    Write-Output "   Base tag: $releaseTag"
    Write-Output "   Smart tags: $major, $minor, latest"
    Write-Output "   URL: $releaseUrl"
}
