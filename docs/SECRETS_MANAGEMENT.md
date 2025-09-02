# 🔐 Secrets Management with Keeper & Chezmoi

This guide explains how to securely manage sensitive configuration using Keeper Security Manager with your chezmoi dotfiles.

## 🎯 Why Use Keeper with Chezmoi?

### Problems with Traditional Approaches:
- ❌ **Plaintext secrets** in dotfiles repositories  
- ❌ **Hard to share** secrets across team members
- ❌ **No audit trail** of secret access
- ❌ **Manual key rotation** processes
- ❌ **Scattered secret storage** across multiple tools

### Keeper + Chezmoi Benefits:
- ✅ **Centralized secret management** in your existing Keeper vault
- ✅ **No plaintext secrets** ever stored in git repositories
- ✅ **Team sharing** via Keeper's sharing features
- ✅ **Automatic audit trail** of all secret access
- ✅ **Easy key rotation** managed through Keeper
- ✅ **Cross-platform support** (macOS, Linux, Windows)

## 🚀 Quick Setup

### 1. Install Keeper CLI
```bash
# Already included in your chezmoi setup!
/path/to/chezmoi/run_once_setup_secrets.sh
```

### 2. Authenticate with Keeper
```bash
keeper shell
# Follow the prompts to log in with your Keeper credentials
```

### 3. Test the Connection
```bash
# List your Keeper records
keeper list

# Get a specific record (replace with your record name)
keeper get "your-record-name"
```

## 📝 Using Secrets in Templates

### Basic Syntax
In any `.tmpl` file, use the `keeperGet` function:
```bash
{{ keeperGet "record-name-in-keeper" }}
```

### Real Examples

**Environment Variables (`dot_env.tmpl`):**
```bash
export GITHUB_TOKEN="{{ keeperGet "github-personal-token" }}"
export OPENAI_API_KEY="{{ keeperGet "openai-api-key" }}"
export AWS_SECRET_ACCESS_KEY="{{ keeperGet "aws-secret-access-key" }}"
```

**Git Configuration (`dot_gitconfig.tmpl`):**
```ini
[github]
    user = {{ .github_username }}
    token = {{ keeperGet "github-personal-token" }}

[user]
    signingkey = {{ keeperGet "gpg-signing-key" }}
```

**SSH Configuration (`private_dot_ssh/private_config.tmpl`):**
```
Host production-server
    HostName {{ keeperGet "prod-server-hostname" }}
    User {{ keeperGet "prod-server-username" }}
    IdentityFile ~/.ssh/id_rsa_production
```

## 🏗 Organizing Secrets in Keeper

### Recommended Naming Convention:
- **Service-specific**: `github-personal-token`, `aws-access-key-id`
- **Environment-specific**: `prod-database-url`, `dev-api-key`
- **Server-specific**: `prod-server-hostname`, `bastion-username`
- **Team-specific**: `company-api-key`, `work-email`

### Example Keeper Vault Structure:
```
📁 Development/
  ├── 🔑 github-personal-token
  ├── 🔑 openai-api-key
  ├── 🔑 anthropic-api-key
  └── 🔑 docker-hub-token

📁 Cloud Providers/
  ├── 🔑 aws-access-key-id
  ├── 🔑 aws-secret-access-key
  ├── 🔑 gcp-service-account-key
  └── 🔑 azure-client-secret

📁 Servers/
  ├── 🔑 prod-server-hostname
  ├── 🔑 prod-server-username
  ├── 🔑 bastion-hostname
  └── 🔑 internal-server-username

📁 Databases/
  ├── 🔑 dev-database-url
  ├── 🔑 prod-database-url
  └── 🔑 redis-url
```

## 🛠 Common Use Cases

### 1. API Keys and Tokens
```bash
# ~/.env template
export STRIPE_SECRET_KEY="{{ keeperGet "stripe-secret-key" }}"
export SENDGRID_API_KEY="{{ keeperGet "sendgrid-api-key" }}"
export SENTRY_DSN="{{ keeperGet "sentry-dsn" }}"
```

### 2. Database Connection Strings
```bash
# Development environment
export DATABASE_URL="{{ keeperGet "dev-database-url" }}"

# Production environment (conditional)
{{- if eq .chezmoi.hostname "production-server" }}
export DATABASE_URL="{{ keeperGet "prod-database-url" }}"
{{- end }}
```

### 3. SSH Keys and Server Access
```bash
# SSH config template
Host {{ keeperGet "server-alias" }}
    HostName {{ keeperGet "server-hostname" }}
    User {{ keeperGet "server-username" }}
    Port {{ keeperGet "server-port" }}
    IdentityFile ~/.ssh/{{ keeperGet "ssh-key-filename" }}
```

### 4. Work vs Personal Configurations
```bash
# Conditional configuration based on hostname/context
{{- if eq .chezmoi.hostname "work-laptop" }}
export COMPANY_API_KEY="{{ keeperGet "company-api-key" }}"
export WORK_EMAIL="{{ keeperGet "work-email" }}"
{{- else }}
export PERSONAL_API_KEY="{{ keeperGet "personal-api-key" }}"
{{- end }}
```

## 🔄 Workflow Examples

### Adding a New Secret

1. **Add to Keeper:**
```bash
keeper shell
# Use Keeper UI or CLI to add new record "new-service-token"
```

2. **Reference in Template:**
```bash
# Edit template file
chezmoi edit ~/.env
# Add: export NEW_SERVICE_TOKEN="{{ keeperGet "new-service-token" }}"
```

3. **Apply Changes:**
```bash
chezmoi apply
```

### Rotating an Existing Secret

1. **Update in Keeper:** Change the secret value in your Keeper vault
2. **Refresh dotfiles:** Run `chezmoi apply` to pull the new value
3. **Restart services:** Restart any applications using the rotated secret

### Sharing Secrets with Team Members

1. **Share Keeper record** with team members via Keeper's sharing features
2. **Team members clone** the dotfiles repository
3. **Authenticate with Keeper** using their own credentials
4. **Apply dotfiles** - secrets automatically populate from their Keeper access

## 🔧 Advanced Configuration

### Custom Keeper Commands
You can customize the Keeper integration in `~/.config/chezmoi/chezmoi.toml`:

```toml
[keeper]
    command = "keeper"
    # Get specific fields from records
    args = ["get", "--format={{ .keeper.format | default "password" }}", "{{ .keeper.record }}"]
```

### Getting Specific Record Fields
```bash
# Get username field
{{ keeperGetField "server-record" "username" }}

# Get password field (default)
{{ keeperGet "server-record" }}

# Get custom field
{{ keeperGetField "api-record" "api-endpoint" }}
```

### Error Handling
```bash
# Provide fallback values for optional secrets
{{ keeperGet "optional-key" | default "fallback-value" }}

# Conditional inclusion based on secret existence
{{- if keeperGet "work-specific-key" }}
export WORK_MODE=true
{{- end }}
```

## 🛡 Security Best Practices

### Do's:
- ✅ **Use meaningful names** for Keeper records
- ✅ **Organize secrets** by service/environment
- ✅ **Share secrets** through Keeper's sharing features
- ✅ **Rotate secrets regularly** using Keeper
- ✅ **Use different secrets** for different environments
- ✅ **Audit secret access** through Keeper's logs

### Don'ts:
- ❌ **Never commit** secrets to git repositories
- ❌ **Don't share** Keeper credentials directly
- ❌ **Don't use** generic names like "password" or "key"
- ❌ **Don't mix** personal and work secrets in same records
- ❌ **Don't hardcode** secrets in non-template files

## 🐛 Troubleshooting

### Keeper CLI Issues
```bash
# Check Keeper CLI installation
keeper --version

# Re-authenticate
keeper logout
keeper shell

# Test connectivity
keeper list
```

### Template Issues
```bash
# Check template syntax
chezmoi execute-template < template-file.tmpl

# Debug template processing
chezmoi apply --dry-run --verbose

# Check Keeper record names
keeper search "partial-name"
```

### Common Errors

**"record not found"**
- Verify record name spelling in Keeper
- Ensure you have access to the record
- Check Keeper CLI authentication

**"template execution failed"**
- Verify template syntax
- Check that all referenced Keeper records exist
- Test with `chezmoi execute-template`

## 🚀 Getting Started Checklist

- [ ] Install and authenticate Keeper CLI
- [ ] Create test secret in Keeper vault
- [ ] Create simple template file using the secret
- [ ] Test with `chezmoi apply --dry-run`
- [ ] Apply changes with `chezmoi apply`
- [ ] Verify secret is properly injected
- [ ] Document secret naming conventions for your team

---

**Need help?** Check the [main README](../README.md) or [detailed setup guide](README_SETUP.md).
