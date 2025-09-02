#!/bin/bash

# Start the Phoenix CMS application
echo "Starting WordPress Phoenix CMS..."

# Set database environment variables for local development
export DB_HOST=localhost
export DB_PORT=26258

# Start the Phoenix server
mix phx.server