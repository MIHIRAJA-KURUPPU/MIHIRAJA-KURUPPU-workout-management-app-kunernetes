#!/bin/bash

# Ensure the database pod is running
kubectl get pods -l app=postgres

# Create the database using psql
kubectl exec -it $(kubectl get pod -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE DATABASE workout;"

# Confirm database creation
kubectl exec -it $(kubectl get pod -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "\l"
