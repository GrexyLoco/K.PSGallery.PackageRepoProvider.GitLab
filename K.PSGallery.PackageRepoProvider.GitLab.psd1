@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'K.PSGallery.PackageRepoProvider.GitLab.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID = '3f8a5c6d-9e2b-4a1c-8f7d-6b4e9a2c1d5f'

    # Author of this module
    Author = 'GrexyLoco'

    # Company or vendor of this module
    CompanyName = 'GrexyLoco'

    # Copyright statement for this module
    Copyright = '(c) 2025 GrexyLoco. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'GitLab Package Registry provider backend for K.PSGallery.PackageRepoProvider. Currently a placeholder/stub for future implementation (v2.0.0+).'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Nested modules to import as part of this module
    NestedModules = @(
        'Private/Invoke-RegisterRepo.ps1',
        'Private/Invoke-Publish.ps1',
        'Private/Invoke-Install.ps1',
        'Private/Invoke-Import.ps1',
        'Private/Invoke-RemoveRepo.ps1'
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Invoke-RegisterRepo',
        'Invoke-Publish',
        'Invoke-Install',
        'Invoke-Import',
        'Invoke-RemoveRepo'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('GitLab', 'Package', 'Registry', 'Provider', 'NuGet', 'Placeholder', 'Stub')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitLab/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitLab'

            # ReleaseNotes of this module
            ReleaseNotes = 'v1.0.0 - Initial placeholder/stub release. All functions throw NotImplementedException. Planned for full implementation in v2.0.0.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
