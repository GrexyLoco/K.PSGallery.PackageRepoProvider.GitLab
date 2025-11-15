# K.PSGallery.PackageRepoProvider.GitLab
# GitLab Package Registry provider backend (Placeholder/Stub)

# Dot-source all Private functions
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)

foreach ($import in $Private) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}
