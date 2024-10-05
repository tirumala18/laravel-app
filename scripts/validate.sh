#!/bin/bash
if curl -Is http://localhost | grep "200 OK"; then
    echo "Application is running."
else
    echo "Application is not running!" >&2
    exit 1
fi
