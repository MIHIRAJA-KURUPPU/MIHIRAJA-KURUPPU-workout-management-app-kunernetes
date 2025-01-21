#!/bin/bash

# Check if a value was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <value>"
  exit 1
fi

# Encode the value in base64
encoded_value=$(echo -n "$1" | base64)

# Print the encoded value
echo "Encoded value: $encoded_value"
