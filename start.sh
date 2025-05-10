#!/bin/bash
DOCKERMODE=true CLEARCACHE=true BROWSER_PATH=$(which google-chrome-stable) python server.py  --headless
