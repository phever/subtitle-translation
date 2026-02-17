#!/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting setup for Subtitle Translation tool..."

# 1. Create/Activate venv
echo "Creating virtual environment..."
if ! python3 -m venv venv; then
    echo "Error: Failed to create virtual environment. Make sure python3-venv is installed."
    exit 1
fi

echo "Activating virtual environment..."
# Note: We use '.' instead of 'source' for better POSIX compatibility in scripts
. venv/bin/activate

# 2. Install dependencies
echo "Installing dependencies from requirements.txt..."
if ! pip install --upgrade pip && pip install -r requirements.txt; then
    echo "Error: Failed to install dependencies."
    exit 1
fi

# 3. Build executable
echo "Building standalone executable with PyInstaller..."
if ! pyinstaller --onefile translate_subs.py; then
    echo "Error: PyInstaller build failed."
    exit 1
fi

# 4. Success message and instructions
echo "------------------------------------------------"
echo "Setup complete!"
echo "The standalone executable is located at: dist/translate_subs"
echo ""
echo "To use the environment manually:"
echo "  source venv/bin/activate"
echo "  python translate_subs.py"
echo "------------------------------------------------"
