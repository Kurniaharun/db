#!/bin/bash

echo "Starting Reseller System..."
echo

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
    echo
fi

# Start the server
echo "Starting server on port 3000..."
echo
echo "Admin Panel: http://localhost:3000/admin"
echo "User Login: http://localhost:3000"
echo
echo "Press Ctrl+C to stop the server"
echo

npm start
