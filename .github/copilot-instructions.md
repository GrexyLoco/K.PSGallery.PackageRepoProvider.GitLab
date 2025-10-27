# GitHub Copilot Instructions

## Project Context

This is the **GitLab Package Registry provider backend** for K.PSGallery.PackageRepoProvider.

### Current Status
- **Version**: v1.0.0 (Placeholder/Stub)
- **State**: Not Implemented
- **Purpose**: Structural placeholder for future GitLab integration

### Implementation Status
All functions currently throw `NotImplementedException` with the message:
```
GitLab Package Registry provider is not yet implemented. Please use GitHub provider or contribute to implementation.
```

## Module Structure

```
K.PSGallery.PackageRepoProvider.GitLab/
├── Private/
│   ├── Invoke-RegisterRepo.ps1    # Stub: Register GitLab repository
│   ├── Invoke-Publish.ps1         # Stub: Publish to GitLab
│   ├── Invoke-Install.ps1         # Stub: Install from GitLab
│   ├── Invoke-Import.ps1          # Stub: Import module
│   └── Invoke-RemoveRepo.ps1      # Stub: Remove repository
├── Tests/
│   └── NotImplemented.Tests.ps1   # Tests verifying stub behavior
├── K.PSGallery.PackageRepoProvider.GitLab.psd1  # Module manifest
├── K.PSGallery.PackageRepoProvider.GitLab.psm1  # Module script
├── README.md
└── CONTRIBUTING.md
```

## Provider Interface

### Function Signatures (DO NOT CHANGE)

These signatures are defined to match the interface expected by the aggregator:

1. **Invoke-RegisterRepo**
   - Parameters: `RepositoryName`, `RegistryUri`, `Credential`, `Trusted` (switch)
   - Purpose: Register GitLab Package Registry

2. **Invoke-Publish**
   - Parameters: `RepositoryName`, `ModulePath`, `ModuleName`, `Credential`
   - Purpose: Publish PowerShell module to GitLab

3. **Invoke-Install**
   - Parameters: `RepositoryName`, `ModuleName`, `Version`, `Credential`, `Scope`, `ImportAfterInstall` (switch)
   - Purpose: Install module from GitLab

4. **Invoke-Import**
   - Parameters: `ModuleName`, `ModulePath`, `Force` (switch), `PassThru` (switch)
   - Purpose: Import PowerShell module

5. **Invoke-RemoveRepo**
   - Parameters: `RepositoryName`
   - Attributes: `[CmdletBinding(SupportsShouldProcess)]`
   - Purpose: Remove registered repository

## GitLab Package Registry Details

### URL Format (Future Implementation)
```
https://<host>/api/v4/projects/<project_id>/packages/nuget/index.json
```

### Authentication (Future Implementation)
- **Username**: `gitlab-ci-token` or personal username
- **Password**: Deploy Token or Personal Access Token
- **Required Scopes**: `read_api`, `read_package_registry`, `write_package_registry`

## Coding Guidelines

### PowerShell Best Practices
- Target PowerShell 7.0+
- Use `[CmdletBinding()]` for all functions
- Include comprehensive comment-based help
- Follow approved verb naming conventions
- Pass PSScriptAnalyzer with no warnings

### Testing Requirements
- All tests must verify that functions throw exceptions
- Use Pester 5.0+ syntax
- Test coverage for all exported functions
- Mock external dependencies

### Documentation
- Keep README updated with current status
- Document all parameters in comment-based help
- Include examples in function help
- Note "Not Implemented" status in all docs

## Related Projects

- **Aggregator**: [K.PSGallery.PackageRepoProvider](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider)
- **Reference Implementation**: [K.PSGallery.PackageRepoProvider.GitHub](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitHub)

## Future Implementation (v2.0.0)

When implementing full GitLab support:
1. Reference GitHub provider for architecture
2. Implement GitLab API integration
3. Add NuGet package handling
4. Integrate with PSResourceGet
5. Add comprehensive tests with mocked GitLab API
6. Update documentation to reflect implemented status

## Do NOT Do

- ❌ Change function signatures (must match interface)
- ❌ Remove existing stub functions
- ❌ Add actual implementation before v2.0.0 planning
- ❌ Remove "Not Implemented" error messages
- ❌ Add dependencies without discussion

## Do

- ✅ Keep stub functions up to date
- ✅ Improve documentation
- ✅ Add tests for stub behavior
- ✅ Ensure PSScriptAnalyzer compliance
- ✅ Update README with clarity improvements
