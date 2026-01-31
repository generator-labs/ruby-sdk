# Security Policy

## Supported Versions

We support the latest version of the Generator Labs Ruby SDK with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 2.x     | :white_check_mark: |
| < 2.0   | :x:                |

## Security Features

This SDK implements several security best practices:

- **Automatic Security Scanning**: CodeQL analyzes the codebase for security vulnerabilities
- **Dependency Management**: Dependabot monitors and updates dependencies
- **Code Quality**: RuboCop enforces Ruby style guidelines and best practices
- **Secure Defaults**: Configurable timeouts prevent hanging connections
- **Credential Validation**: Validates API credentials format before use

## Reporting a Vulnerability

If you discover a security vulnerability in the Generator Labs Ruby SDK, please report it by emailing:

**security@generatorlabs.com**

Please include:

1. Description of the vulnerability
2. Steps to reproduce the issue
3. Potential impact
4. Suggested fix (if available)

We take all security reports seriously and will respond within 48 hours.

## Best Practices

When using the Generator Labs Ruby SDK:

1. **Never commit credentials** - Use environment variables or secure credential stores
2. **Keep dependencies updated** - Regularly update the SDK and its dependencies
3. **Use HTTPS** - Always use the default HTTPS endpoint (never HTTP)
4. **Validate input** - Sanitize user input before passing to API methods
5. **Handle errors properly** - Never expose sensitive error details to end users
6. **Use timeouts** - Configure appropriate timeouts to prevent resource exhaustion
7. **Follow principle of least privilege** - Use API credentials with minimal required permissions

## Security Scanning

This project uses:

- **CodeQL**: Automated security analysis on every push and pull request
- **Dependabot**: Automatic security updates for vulnerable dependencies
- **RuboCop**: Static code analysis for Ruby best practices

## Updates

Security updates are released as soon as possible after a vulnerability is confirmed. Monitor the GitHub repository for security advisories and update promptly.
