@echo off
echo Starting Reseller System...
echo.

REM Check if node_modules exists
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    echo.
)

REM Start the server
echo Starting server on port 3000...
echo.
echo Admin Panel: http://localhost:3000/admin
echo User Login: http://localhost:3000
echo.
echo Press Ctrl+C to stop the server
echo.

npm start

pause
