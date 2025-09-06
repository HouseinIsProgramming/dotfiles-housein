#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Check if we're in a git repo
if (!fs.existsSync('.git')) {
    console.log('❌ Not in a git repository');
    process.exit(1);
}

console.log('📦 Setting up git hooks for prettier and eslint...');

// Create simple pre-commit hook
const preCommitHook = `#!/bin/sh
# Run prettier and eslint on staged files
npx lint-staged
`;

// Create the hooks directory if it doesn't exist
const hooksDir = '.git/hooks';
if (!fs.existsSync(hooksDir)) {
    fs.mkdirSync(hooksDir, { recursive: true });
}

// Write the pre-commit hook
fs.writeFileSync(path.join(hooksDir, 'pre-commit'), preCommitHook);
execSync('chmod +x .git/hooks/pre-commit');

// Create/update package.json lint-staged config
const packageJsonPath = 'package.json';
if (fs.existsSync(packageJsonPath)) {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    
    if (!packageJson['lint-staged']) {
        packageJson['lint-staged'] = {
            "*.{ts,tsx,js,jsx}": ["prettier --write", "eslint --fix"],
            "*.{json,md,css,scss}": ["prettier --write"]
        };
        fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2) + '\n');
        console.log('✅ Added lint-staged config to package.json');
    }
}

console.log('✅ Pre-commit hook installed');
console.log('💡 Make sure you have prettier and eslint installed:');
console.log('   npm install --save-dev prettier eslint lint-staged');