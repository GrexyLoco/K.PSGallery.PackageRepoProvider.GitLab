# Contributing to K.PSGallery.PackageRepoProvider.GitLab

Thank you for your interest in contributing to this project! This guide will help you get started.

## Current Status

This module is currently a **placeholder/stub** for future GitLab Package Registry implementation. All functions throw `NotImplementedException`.

## How to Contribute

### Implementation Roadmap (v2.0.0)

To implement full GitLab Package Registry support, the following areas need work:

1. **Registry Configuration**
   - Parse GitLab Package Registry URLs
   - Extract project ID from URL
   - Support both gitlab.com and self-hosted instances

2. **Authentication**
   - Support Deploy Tokens
   - Support Personal Access Tokens
   - Handle `gitlab-ci-token` in CI/CD contexts
   - Credential validation

3. **Package Operations**
   - Implement NuGet package publishing
   - Implement package installation
   - Package version resolution
   - Dependency handling

4. **PSResourceGet Integration**
   - Register repositories with PSResourceGet
   - Configure authentication for PSResourceGet
   - Handle repository metadata

5. **Testing**
   - Unit tests with mocked GitLab API
   - Integration tests (optional, with test GitLab instance)
   - Pester test coverage

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/<your-username>/K.PSGallery.PackageRepoProvider.GitLab.git
   cd K.PSGallery.PackageRepoProvider.GitLab
   ```

2. **Requirements**
   - PowerShell 7.0 or higher
   - Pester 5.0 or higher
   - PSScriptAnalyzer

3. **Install Development Dependencies**
   ```powershell
   Install-Module -Name Pester -MinimumVersion 5.0 -Scope CurrentUser
   Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
   ```

### Code Guidelines

1. **PowerShell Best Practices**
   - Follow [PowerShell Best Practices and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
   - Use approved verbs (Get-, Set-, New-, etc.)
   - Write comment-based help for all functions

2. **Code Quality**
   - Pass PSScriptAnalyzer with no warnings
   - Maintain or improve test coverage
   - Write clear, self-documenting code

3. **Testing**
   - Add Pester tests for new functionality
   - Ensure all tests pass before submitting PR
   - Mock external dependencies (GitLab API, file system, etc.)

4. **Documentation**
   - Update README.md if adding new features
   - Add inline comments for complex logic
   - Include usage examples in function help

### Reference Implementation

The [K.PSGallery.PackageRepoProvider.GitHub](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitHub) module provides a reference implementation for:
- Repository registration
- Package publishing
- Package installation
- Credential handling
- PSResourceGet integration

Use it as a guide for implementing GitLab-specific functionality.

### Pull Request Process

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Implement your feature
   - Add/update tests
   - Update documentation

3. **Run Quality Checks**
   ```powershell
   # Run PSScriptAnalyzer
   Invoke-ScriptAnalyzer -Path . -Recurse

   # Run Pester tests
   Invoke-Pester -Path ./Tests
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a Pull Request on GitHub.

6. **PR Requirements**
   - Clear description of changes
   - All tests passing
   - No PSScriptAnalyzer warnings
   - Updated documentation
   - Follows code guidelines

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `refactor:` - Code refactoring
- `chore:` - Maintenance tasks

### Need Help?

- Open an [issue](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitLab/issues) for questions
- Check the [GitHub provider implementation](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider.GitHub) for examples
- Review the [main aggregator](https://github.com/GrexyLoco/K.PSGallery.PackageRepoProvider) for context

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to foster a welcoming and inclusive community.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).
