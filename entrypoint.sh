#!/bin/sh
set -e

# Make sure config directory exists
mkdir -p /app/config

# Copy config template from mounted directory to active config path
if [ -f /app/config/config.json.template ]; then
  cp /app/config/config.json.template /app/config/config.json
else
  echo "Error: /app/config/config.json.template not found. Make sure configuration templates are mounted."
  exit 1
fi

# Ensure keys directory exists
mkdir -p /app/config/keys

# Find all placeholders matching ${VAR_NAME} in the template config
# and extract the variable names
vars=$(grep -o '\${[A-Z0-9_]*}' /app/config/config.json.template | sed 's/\${//g; s/}//g' | sort -u)

for var in $vars; do
  # Get the value from the environment
  val=$(eval echo "\$$var")
  
  # Fallback to dummy local RPC for empty RPC URLs to prevent boot crash
  if [ -z "$val" ] && echo "$var" | grep -q "RPC_URL"; then
    val="http://127.0.0.1:8545"
    echo "Placeholder \${$var} is empty, using fallback: $val"
  fi

  # Escape special characters for sed (ampersand, backslash, slash)
  escaped_val=$(echo "$val" | sed 's/[&/\]/\\&/g')
  echo "Substituting placeholder \${$var}..."
  sed -i "s|\\\${${var}}|${escaped_val}|g" /app/config/config.json
done

echo "Configuration initialized successfully."

# Execute the official openzeppelin-relayer binary forwarding all args
exec /app/openzeppelin-relayer "$@"
