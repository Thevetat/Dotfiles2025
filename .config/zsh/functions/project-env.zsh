#!/usr/bin/env zsh
# Project environment loader for direnv integration
# Handles secret loading from pass with environment-specific configuration
#
# Usage in .envrc:
#   source ~/.config/zsh/functions/project-env.zsh
#
#   PROJECT_SECRETS=(
#     "sentry-dsn"
#     "database-url"
#     # ... more project secrets
#   )
#
#   SHARED_SECRETS=(
#     "resend-api-key"
#     # ... more shared secrets
#   )
#
#   load_project_env PROJECT_SECRETS SHARED_SECRETS
#
# Optional: Override environment with ENVIRONMENT=staging or ENVIRONMENT=prod

# Ensure pass.zsh is loaded for secret function
if ! command -v secret &>/dev/null 2>&1; then
  source ~/.config/zsh/functions/pass.zsh
fi

# Convert kebab-case to SCREAMING_SNAKE_CASE
kebab_to_screaming() {
  echo "$1" | tr '[:lower:]-' '[:upper:]_'
}

# Main environment loading function
# Usage: load_project_env <project_secrets_array_name> <shared_secrets_array_name>
function load_project_env() {
  local project_secrets_ref=$1
  local shared_secrets_ref=$2

  # Validate arguments
  if [[ -z "$project_secrets_ref" ]] || [[ -z "$shared_secrets_ref" ]]; then
    echo "Error: load_project_env requires two array references" >&2
    echo "Usage: load_project_env PROJECT_SECRETS SHARED_SECRETS" >&2
    return 1
  fi

  # Get arrays by reference (compatible with both bash and zsh)
  if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh way
    local -a project_secrets=("${(@P)project_secrets_ref}")
    local -a shared_secrets=("${(@P)shared_secrets_ref}")
  else
    # Bash way
    eval "project_secrets=(\"\${${project_secrets_ref}[@]}\")"
    eval "shared_secrets=(\"\${${shared_secrets_ref}[@]}\")"
  fi

  # Support ENVIRONMENT variable (defaults to dev)
  ENVIRONMENT=${ENVIRONMENT:-dev}

  # Get project name from package.json
  if [[ ! -f "package.json" ]]; then
    echo "Error: package.json not found in current directory" >&2
    return 1
  fi

  local PROJECT_NAME=$(jq -r '.name' package.json 2>/dev/null)
  if [[ -z "$PROJECT_NAME" ]] || [[ "$PROJECT_NAME" == "null" ]]; then
    echo "Error: Could not read project name from package.json" >&2
    return 1
  fi

  # Check if staging environment exists in pass, fallback to dev if not
  local ACTUAL_ENV=$ENVIRONMENT
  if [[ "$ENVIRONMENT" == "staging" ]]; then
    if ! pass ls "projects/$PROJECT_NAME/staging" &>/dev/null 2>&1; then
      echo "Note: staging environment not found, falling back to dev" >&2
      ACTUAL_ENV="dev"
    fi
  fi

  # Export project secrets
  for secret in "${project_secrets[@]}"; do
    local VAR_NAME=$(kebab_to_screaming "$secret")
    local SECRET_VALUE="$(secret "projects/$PROJECT_NAME/$ACTUAL_ENV/$secret" 2>/dev/null)"
    if [[ -n "$SECRET_VALUE" ]]; then
      export "$VAR_NAME=$SECRET_VALUE"
    fi
  done

  # Export shared secrets
  for secret in "${shared_secrets[@]}"; do
    local VAR_NAME=$(kebab_to_screaming "$secret")
    local SECRET_VALUE="$(secret "projects/$PROJECT_NAME/shared/$secret" 2>/dev/null)"
    if [[ -n "$SECRET_VALUE" ]]; then
      export "$VAR_NAME=$SECRET_VALUE"
    fi
  done

  # Optional: Print loaded environment info (comment out in production)
  # echo "✓ Loaded environment: $ACTUAL_ENV for project: $PROJECT_NAME" >&2
}

# Optional helper to validate all required secrets are loaded
# Usage: validate_project_env VAR1 VAR2 VAR3...
function validate_project_env() {
  local missing=()

  for var in "$@"; do
    # Check if variable is set (compatible with both bash and zsh)
    if [[ -n "$ZSH_VERSION" ]]; then
      if [[ -z "${(P)var}" ]]; then
        missing+=("$var")
      fi
    else
      if [[ -z "${!var}" ]]; then
        missing+=("$var")
      fi
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Warning: Missing environment variables:" >&2
    for var in "${missing[@]}"; do
      echo "  - $var" >&2
    done
    return 1
  fi

  return 0
}

# Optional helper to list what would be loaded (dry run)
# Usage: preview_project_env PROJECT_SECRETS SHARED_SECRETS
function preview_project_env() {
  local project_secrets_ref=$1
  local shared_secrets_ref=$2

  # Get arrays by reference (compatible with both bash and zsh)
  if [[ -n "$ZSH_VERSION" ]]; then
    local -a project_secrets=("${(@P)project_secrets_ref}")
    local -a shared_secrets=("${(@P)shared_secrets_ref}")
  else
    eval "project_secrets=(\"\${${project_secrets_ref}[@]}\")"
    eval "shared_secrets=(\"\${${shared_secrets_ref}[@]}\")"
  fi

  local ENVIRONMENT=${ENVIRONMENT:-dev}
  local PROJECT_NAME=$(jq -r '.name' package.json 2>/dev/null)

  echo "Project Environment Preview"
  echo "============================"
  echo "Project: $PROJECT_NAME"
  echo "Environment: $ENVIRONMENT"
  echo ""
  echo "Project Secrets (${#project_secrets[@]}):"
  for secret in "${project_secrets[@]}"; do
    local VAR_NAME=$(kebab_to_screaming "$secret")
    echo "  $VAR_NAME <- projects/$PROJECT_NAME/$ENVIRONMENT/$secret"
  done
  echo ""
  echo "Shared Secrets (${#shared_secrets[@]}):"
  for secret in "${shared_secrets[@]}"; do
    local VAR_NAME=$(kebab_to_screaming "$secret")
    echo "  $VAR_NAME <- projects/$PROJECT_NAME/shared/$secret"
  done
}