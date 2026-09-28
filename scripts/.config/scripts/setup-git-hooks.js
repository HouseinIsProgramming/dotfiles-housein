#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Check if we're in a git repo
if (!fs.existsSync('.git')) {
    console.log('❌ Not in a git repository');
    process.exit(1);
}

// Check if package.json exists
if (!fs.existsSync('package.json')) {
    console.log('❌ No package.json found. Run "npm init" first.');
    process.exit(1);
}

console.log('📦 Setting up git hooks for prettier and eslint...');

// Read current package.json
const packageJsonPath = 'package.json';
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Determine project type
const isTypeScript = fs.existsSync('tsconfig.json') || 
                     Object.keys({...packageJson.dependencies, ...packageJson.devDependencies}).some(dep => 
                         dep.includes('typescript') || dep.includes('@types/'));

const isReact = Object.keys({...packageJson.dependencies, ...packageJson.devDependencies}).some(dep => 
                   dep.includes('react'));

console.log(`🔍 Detected: ${isTypeScript ? 'TypeScript' : 'JavaScript'}${isReact ? ' + React' : ''} project`);

// Initialize dev dependencies if not exists
if (!packageJson.devDependencies) {
    packageJson.devDependencies = {};
}

// Add required dependencies
const baseDeps = {
    'prettier': '^3.2.5',
    'lint-staged': '^15.0.0',
    'husky': '^9.0.0'
};

const eslintDeps = isTypeScript ? {
    'eslint': '^9.0.0',
    '@eslint/js': '^9.0.0',
    'typescript-eslint': '^8.0.0',
    'globals': '^15.0.0'
} : {
    'eslint': '^9.0.0',
    '@eslint/js': '^9.0.0'
};

const reactDeps = isReact ? {
    'eslint-plugin-react': '^7.0.0',
    'eslint-plugin-react-hooks': '^4.0.0'
} : {};

const allDeps = { ...baseDeps, ...eslintDeps, ...reactDeps };

// Add missing dependencies
let needsInstall = false;
for (const [dep, version] of Object.entries(allDeps)) {
    if (!packageJson.devDependencies[dep] && !packageJson.dependencies?.[dep]) {
        packageJson.devDependencies[dep] = version;
        needsInstall = true;
    }
}

// Add scripts if they don't exist
if (!packageJson.scripts) {
    packageJson.scripts = {};
}

if (!packageJson.scripts.lint) {
    packageJson.scripts.lint = 'eslint . --fix';
}
if (!packageJson.scripts.format) {
    packageJson.scripts.format = 'prettier --write .';
}
if (!packageJson.scripts.prepare) {
    packageJson.scripts.prepare = 'husky';
}

// Configure lint-staged
if (!packageJson['lint-staged']) {
    packageJson['lint-staged'] = isReact ? {
        "*.{ts,tsx,js,jsx}": ["prettier --write", "eslint --fix"],
        "*.{json,md,css,scss}": ["prettier --write"]
    } : {
        "*.{ts,tsx,js,jsx}": ["prettier --write", "eslint --fix"],
        "*.{json,md,css,scss}": ["prettier --write"]
    };
}

// Write updated package.json
if (needsInstall) {
    fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2) + '\n');
    console.log('✅ Added required dev dependencies to package.json');
}

// Create ESLint config
const eslintConfigPath = 'eslint.config.js';
if (!fs.existsSync(eslintConfigPath) && !fs.existsSync('.eslintrc.js') && !fs.existsSync('.eslintrc.json')) {
    let eslintConfig;
    
    if (isTypeScript && isReact) {
        eslintConfig = `import js from '@eslint/js';
import globals from 'globals';
import tseslint from 'typescript-eslint';
import reactPlugin from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  reactPlugin.configs.flat.recommended,
  {
    plugins: {
      'react-hooks': reactHooks,
    },
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
      'no-console': 'warn',
      'react/react-in-jsx-scope': 'off',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**', '*.config.js'],
  }
];`;
    } else if (isTypeScript) {
        eslintConfig = `import js from '@eslint/js';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
    rules: {
      '@typescript-eslint/no-unused-vars': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
      'no-console': 'warn',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**', '*.config.js'],
  }
];`;
    } else {
        eslintConfig = `import js from '@eslint/js';
import globals from 'globals';

export default [
  js.configs.recommended,
  {
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
      },
    },
    rules: {
      'prefer-const': 'error',
      'no-var': 'error',
      'no-console': 'warn',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**', '*.config.js'],
  }
];`;
    }
    
    fs.writeFileSync(eslintConfigPath, eslintConfig);
    console.log('✅ Created eslint.config.js');
}

// Create Prettier config
const prettierConfigPath = '.prettierrc';
if (!fs.existsSync(prettierConfigPath)) {
    const prettierConfig = {
        "semi": true,
        "trailingComma": "es5",
        "singleQuote": true,
        "printWidth": 100,
        "tabWidth": 2,
        "useTabs": false
    };
    fs.writeFileSync(prettierConfigPath, JSON.stringify(prettierConfig, null, 2) + '\n');
    console.log('✅ Created .prettierrc');
}

// Install dependencies
if (needsInstall) {
    console.log('📥 Installing dependencies...');
    try {
        execSync('npm install', { stdio: 'inherit' });
        console.log('✅ Dependencies installed');
    } catch (error) {
        console.log('⚠️  Please run "npm install" manually');
    }
}

// Initialize Husky
try {
    execSync('npx husky init', { stdio: 'inherit' });
    console.log('✅ Husky initialized');
} catch (error) {
    console.log('⚠️  Husky initialization failed. Run "npx husky init" manually');
}

// Create pre-commit hook
const preCommitPath = '.husky/pre-commit';
if (fs.existsSync('.husky')) {
    const preCommitContent = `npx lint-staged\n`;
    fs.writeFileSync(preCommitPath, preCommitContent);
    execSync(`chmod +x ${preCommitPath}`);
    console.log('✅ Pre-commit hook created');
}

console.log('\n🎉 Setup complete!');
console.log('💡 Next steps:');
console.log('   • Test linting: npm run lint');
console.log('   • Test formatting: npm run format');
console.log('   • Make a test commit to verify hooks work');
console.log('\n🔧 Configured tools:');
console.log('   • ESLint with modern flat config');
console.log('   • Prettier for code formatting');
console.log('   • Husky for git hooks');
console.log('   • lint-staged for pre-commit checks');