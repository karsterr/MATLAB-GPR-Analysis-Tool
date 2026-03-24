#!/bin/bash
# Git LFS Setup ve Push Script

cd ~/MATLAB-GPR-Analysis-Tool

echo "=========================================="
echo "GIT LFS CONFIGURATION & PUSH SCRIPT"
echo "=========================================="
echo ""

# Step 1: Git LFS status
echo "📋 Step 1: GIT LFS Status"
git lfs version
echo ""

# Step 2: Check git status
echo "📋 Step 2: Git Status (before push)"
git status --short
echo ""

# Step 3: View git log
echo "📋 Step 3: Recent Commits"
git log --oneline -3
echo ""

# Step 4: Network connectivity
echo "📋 Step 4: Testing Network..."
ping -c 2 github.com 2>&1 | head -3 || echo "⚠️  Network issue detected"
echo ""

# Step 5: Push to GitHub
echo "📋 Step 5: Pushing to GitHub..."
git push origin main --verbose
echo ""

echo "=========================================="
echo "✅ PROCESS COMPLETE"
echo "=========================================="
