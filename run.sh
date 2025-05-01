#!/bin/bash

set -e  # Exit immediately if any command fails

echo "[INFO] Starting Deployment at $(date)"

# Activate virtual environment if necessary
if [ -f "venv/bin/activate" ]; then
  echo "[INFO] Activating virtual environment..."
  source venv/bin/activate
fi

# Install dependencies securely
echo "[INFO] Installing Python requirements..."
pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir

# Apply migrations
echo "[INFO] Applying migrations..."
python manage.py makemigrations --merge
python manage.py migrate

# Collect static files
echo "[INFO] Collecting static files..."
python manage.py collectstatic --noinput

# Optional: Compile translations (uncomment if used)
# echo "[INFO] Compiling translation messages..."
# python manage.py compilemessages -l fr

# Stop any existing Gunicorn process (optional and customizable)
echo "[INFO] Stopping existing Gunicorn (if any)..."
pkill gunicorn || true

# Start Gunicorn
echo "[INFO] Starting Gunicorn server..."
exec gunicorn config.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 4 \
  --threads 10 \
  --timeout 3600 \
  --reload \
  --log-level info

