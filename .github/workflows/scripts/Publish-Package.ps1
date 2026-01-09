<#
.SYNOPSIS
    Publishes PowerShell module to GitHub Packages via K.PSGallery.PackageRepoProvider.

.DESCRIPTION
    Installs K.PSGallery.PackageRepoProvider from GitHub Packages and uses it for
    intelligent package publishing. Falls back to built-in Publish-PSResource
    if provider module installation fails.

.PARAMETER ModuleName
    Name of the PowerShell module to publish.

.PARAMETER NewVersion
    Version to publish (used for verification).

.PARAMETER GitHubToken
    GitHub token for package publishing authentication.

.PARAMETER RepositoryOwner
    GitHub repository owner (e.g., 'GrexyLoco').

.OUTPUTS
    Writes publish summary to GITHUB_STEP_SUMMARY.
    Sets GITHUB_OUTPUT variable: package-published (true/false)

.EXAMPLE
    ./Publish-Package.ps1 -ModuleName "MyModule" -NewVersion "1.2.3" -GitHubToken $env:GITHUB_TOKEN -RepositoryOwner "GrexyLoco"

.NOTES
    Platform-independent script for GitHub Actions workflows.
    Installs K.PSGallery.PackageRepoProvider from GitHub Packages, then uses it to publish.
    Handles repository registration, package publishing, and cleanup.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,

    [Parameter(Mandatory = $true)]
    [string]$NewVersion,

    [Parameter(Mandatory = $true)]
    [string]$GitHubToken,

    [Parameter(Mandatory = $true)]
    [string]$RepositoryOwner
)

# ═══════════════════════════════════════════════════════════════════════════
# 📋 Summary Header
# ═══════════════════════════════════════════════════════════════════════════
Write-Output "<details open><summary>📦 Package Publishing</summary>" >> $env:GITHUB_STEP_SUMMARY
Write-Output "" >> $env:GITHUB_STEP_SUMMARY
Write-Output "| Property | Value |" >> $env:GITHUB_STEP_SUMMARY
Write-Output "|----------|-------|" >> $env:GITHUB_STEP_SUMMARY
Write-Output "| **Module** | ``$ModuleName`` |" >> $env:GITHUB_STEP_SUMMARY
Write-Output "| **Version** | ``$NewVersion`` |" >> $env:GITHUB_STEP_SUMMARY
Write-Output "| **Target** | GitHub Packages |" >> $env:GITHUB_STEP_SUMMARY

# ═══════════════════════════════════════════════════════════════════════════
# 🔧 Configuration
# ═══════════════════════════════════════════════════════════════════════════
$registryUri = "https://nuget.pkg.github.com/$RepositoryOwner/index.json"
$repoName = 'GitHubPackages'

# ═══════════════════════════════════════════════════════════════════════════
# 📦 Install K.PSGallery.PackageRepoProvider from GitHub Packages
# ═══════════════════════════════════════════════════════════════════════════
function Install-PackageRepoProvider {
    param([string]$Token, [string]$Owner)

    Write-Output "📦 Installing K.PSGallery.PackageRepoProvider from GitHub Packages..."

    # Create credential for GitHub Packages
    $secureToken = ConvertTo-SecureString $Token -AsPlainText -Force
    $credential = New-Object PSCredential($Owner, $secureToken)

    # Register GitHub Packages as PSResource repository (for installation)
    $tempRepoName = 'GHPackages-Temp'
    $uri = "https://nuget.pkg.github.com/$Owner/index.json"

    Write-Output "🔍 Registry URI: $uri"
    Write-Output "🔍 Owner: $Owner"

    # Remove if exists
    Unregister-PSResourceRepository -Name $tempRepoName -ErrorAction SilentlyContinue

    # Register
    Write-Output "📝 Registering temporary repository: $tempRepoName"
    Register-PSResourceRepository -Name $tempRepoName -Uri $uri -Trusted -ErrorAction Stop

    # Install the provider module
    Write-Output "📥 Installing K.PSGallery.PackageRepoProvider..."
    $moduleName = 'K.PSGallery.PackageRepoProvider'
    Install-PSResource -Name $moduleName `
        -Repository $tempRepoName `
        -Credential $credential `
        -Scope CurrentUser `
        -TrustRepository `
        -Verbose `
        -ErrorAction Stop

    # ═══════════════════════════════════════════════════════════════════════
    # 🔧 PSResourceGet Issue #1402 Workaround: Lowercase Folder Bug on Linux
    # On Linux/macOS, Install-PSResource creates module folders in lowercase
    # which causes Import-Module to fail due to case-sensitive filesystem
    # See: https://github.com/PowerShell/PSResourceGet/issues/1402
    # ═══════════════════════════════════════════════════════════════════════
    if ($IsLinux -or $IsMacOS) {
        $modulesPath = Join-Path $HOME '.local/share/powershell/Modules'
        $lowercasePath = Join-Path $modulesPath $moduleName.ToLower()
        $correctPath = Join-Path $modulesPath $moduleName

        if ((Test-Path $lowercasePath) -and -not (Test-Path $correctPath)) {
            Write-Output "🔧 Fixing PSResourceGet #1402: Renaming lowercase module folder..."
            Write-Output "   From: $lowercasePath"
            Write-Output "   To:   $correctPath"
            Rename-Item -Path $lowercasePath -NewName $moduleName -Force
        }
    }

    # Import the module
    Write-Output "📦 Importing $moduleName..."
    Import-Module $moduleName -Force -ErrorAction Stop

    Write-Output "✅ $moduleName installed and imported"

    # Cleanup temp repository
    Unregister-PSResourceRepository -Name $tempRepoName -ErrorAction SilentlyContinue
}

# ═══════════════════════════════════════════════════════════════════════════
# 🚀 Main Publishing Logic
# ═══════════════════════════════════════════════════════════════════════════
try {
    # Step 1: Install PackageRepoProvider from GitHub Packages
    Install-PackageRepoProvider -Token $GitHubToken -Owner $RepositoryOwner

    Write-Output "📝 Registering repository: $repoName"

    # Step 2: Register the target repository using PackageRepoProvider
    Register-PackageRepo `
        -RepositoryName $repoName `
        -RegistryUri $registryUri `
        -Token $GitHubToken `
        -Trusted

    Write-Output "🚀 Publishing module: $ModuleName"

    # Step 3: Publish the module
    Publish-Package `
        -RepositoryName $repoName `
        -Token $GitHubToken

    # Success summary
    Write-Output "" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "### ✅ Published via K.PSGallery.PackageRepoProvider" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "- **Registry:** ``$registryUri``" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "- **Package:** ``$ModuleName@$NewVersion``" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "- **View Package:** [GitHub Packages](https://github.com/$RepositoryOwner?tab=packages)" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "</details>" >> $env:GITHUB_STEP_SUMMARY

    "package-published=true" >> $env:GITHUB_OUTPUT

    Write-Output "✅ Successfully published $ModuleName@$NewVersion to GitHub Packages"
}
catch {
    Write-Output "⚠️ PackageRepoProvider failed: $($_.Exception.Message)"
    Write-Output "🔄 Falling back to Publish-PSResource..."
    Write-Output "" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "### ⚠️ Fallback: Publish-PSResource" >> $env:GITHUB_STEP_SUMMARY
    Write-Output "" >> $env:GITHUB_STEP_SUMMARY

    # ═══════════════════════════════════════════════════════════════════════
    # 🔄 Fallback: Built-in Publish-PSResource
    # ═══════════════════════════════════════════════════════════════════════
    try {
        # Create credential
        $secureToken = ConvertTo-SecureString $GitHubToken -AsPlainText -Force
        $credential = New-Object PSCredential($RepositoryOwner, $secureToken)

        # Register repository
        Unregister-PSResourceRepository -Name $repoName -ErrorAction SilentlyContinue
        Register-PSResourceRepository -Name $repoName -Uri $registryUri -Trusted -ErrorAction Stop

        # Find module manifest using robust discovery
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $findManifestScript = Join-Path $scriptDir 'Find-ModuleManifest.ps1'

        if (-not (Test-Path $findManifestScript)) {
            Write-Warning "Find-ModuleManifest.ps1 not found, using legacy discovery"
            $moduleSubPath = Join-Path -Path '.' -ChildPath $ModuleName
            $modulePath = if (Test-Path $moduleSubPath) { $moduleSubPath } else { '.' }
        } else {
            $manifestResult = & $findManifestScript -ModuleName $ModuleName -SearchPath '.' -Verbose

            if (-not $manifestResult.IsValid) {
                $errorMsg = "Manifest validation failed:`n" + ($manifestResult.Errors -join "`n")
                throw $errorMsg
            }

            if ($manifestResult.Warnings.Count -gt 0) {
                foreach ($warning in $manifestResult.Warnings) {
                    Write-Warning $warning
                }
            }

            # Use directory containing the manifest
            $modulePath = Split-Path -Parent $manifestResult.ManifestPath
            Write-Output "✅ Using manifest: $($manifestResult.ManifestPath) (Method: $($manifestResult.ValidationMethod))"
        }

        # Publish module
        Publish-PSResource `
            -Path $modulePath `
            -Repository $repoName `
            -ApiKey $GitHubToken `
            -ErrorAction Stop

        Write-Output "- ✅ Published via Publish-PSResource" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "- **Package:** ``$ModuleName@$NewVersion``" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "- **View Package:** [GitHub Packages](https://github.com/$RepositoryOwner?tab=packages)" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "</details>" >> $env:GITHUB_STEP_SUMMARY

        "package-published=true" >> $env:GITHUB_OUTPUT

        Write-Output "✅ Successfully published $ModuleName@$NewVersion via fallback"
    }
    catch {
        Write-Error "❌ Package publishing failed: $($_.Exception.Message)"
        Write-Output "" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "### ❌ Publishing Failed" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "``````" >> $env:GITHUB_STEP_SUMMARY
        Write-Output $_.Exception.Message >> $env:GITHUB_STEP_SUMMARY
        Write-Output "``````" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "" >> $env:GITHUB_STEP_SUMMARY
        Write-Output "</details>" >> $env:GITHUB_STEP_SUMMARY

        "package-published=false" >> $env:GITHUB_OUTPUT
        exit 1
    }
    finally {
        # Cleanup
        Unregister-PSResourceRepository -Name $repoName -ErrorAction SilentlyContinue
    }
}
finally {
    # Final cleanup - only if PackageRepoProvider was loaded
    if (Get-Command Remove-PackageRepo -ErrorAction SilentlyContinue) {
        Remove-PackageRepo -RepositoryName $repoName -ErrorAction SilentlyContinue
    }
}
