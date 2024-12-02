#!/bin/bash

echo "Worker Initiated"

echo "Starting ComfyUI API"
python /ComfyUI/main.py --listen &

echo "Starting RunPod Handler"
python -u /ComfyUI/handler.py