#!/bin/bash
echo "🎿 Deployer SkiIQ..."
cd ~/Desktop/skiiq
git add .
git commit -m "${1:-Auto deploy}"
git push
echo "✅ Deploy sendt til Netlify!"
