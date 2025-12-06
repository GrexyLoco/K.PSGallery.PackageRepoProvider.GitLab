# K.PSGallery.PackageRepoProvider.GitLab

**Status**: 🚧 Placeholder/Stub (Not Implemented)

This provider backend is a structural placeholder for future GitLab Package Registry support.

## Current State

All functions throw `NotImplementedException`. This module is **not production-ready** and serves as a placeholder for future development.

### Available Functions (Stub Only)
- `Invoke-RegisterRepo` - Registers a GitLab Package Registry repository
- `Invoke-Publish` - Publishes a PowerShell module to GitLab Package Registry
- `Invoke-Install` - Installs a PowerShell module from GitLab Package Registry
- `Invoke-Import` - Imports a PowerShell module
- `Invoke-RemoveRepo` - Removes a registered repository

All functions throw the following exception:
```
GitLab Package Registry provider is not yet implemented. Please use GitHub provider or contribute to implementation.
```

## Installation

```powershell
Install-Module -Name K.PSGallery.PackageRepoProvider.GitLab -Repository PSGallery
```

## Planned for v2.0.0

- ✅ Full GitLab Package Registry integration
- ✅ Support for self-hosted GitLab instances
- ✅ Deploy Token and Personal Access Token authentication
- ✅ NuGet-compatible package operations
- ✅ PSResourceGet integration

## GitLab Package Registry Format (Future)

### Registry URL Format
```
https://<host>/api/v4/projects/<project_id>/packages/nuget/index.json
```

**Examples:**
- GitLab.com: `https://gitlab.com/api/v4/projects/12345/packages/nuget/index.json`
- Self-hosted: `https://gitlab.example.com/api/v4/projects/67890/packages/nuget/index.json`

### Credential Format

**Username**: One of the following
- `gitlab-ci-token` (for CI/CD pipelines)
- Personal username

**Password**: One of the following
- Deploy Token (with `read_package_registry` or `write_package_registry` scope)
- Personal Access Token (with `api`, `read_api`, `read_package_registry`, or `write_package_registry` scope)

### Required Scopes

- **Read operations**: `read_api`, `read_package_registry`
- **Write operations**: `write_package_registry`

## Alternative (Production Use)

Use [K.PSGallery.PackageRepoProvider.GitHub](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitHub) for production workloads.

## Contributing

This is a placeholder/stub module for future GitLab Package Registry support. If you're interested in implementing full functionality:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/gitlab-implementation`)
3. Reference the GitHub provider implementation for guidance
4. Implement the GitLab-specific logic
5. Add comprehensive tests
6. Submit a pull request

## Related Projects

- [K.PSGallery.PackageRepoProvider](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider) - Main aggregator/facade
- [K.PSGallery.PackageRepoProvider.GitHub](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitHub) - GitHub Packages provider (production-ready)

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitLab/issues).
