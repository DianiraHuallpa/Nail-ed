module.exports = {
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'import', 'promise', 'jsdoc'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'plugin:promise/recommended',
    'plugin:jsdoc/recommended',
    'prettier',
  ],
  rules: {
    // General Rules
    curly: ['error', 'all'],
    'brace-style': ['error', '1tbs', { allowSingleLine: false }],
    'no-console': 'warn',
    'no-debugger': 'error',
    'no-unused-vars': 'off', // Use TypeScript's rule instead
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-multiple-empty-lines': ['error', { max: 1 }],
    'eol-last': ['error', 'always'],
    quotes: ['error', 'single', { avoidEscape: true }],
    semi: ['error', 'always'],
    'comma-dangle': ['error', 'always-multiline'],
    'object-curly-spacing': ['error', 'always'],
    'arrow-spacing': ['error', { before: true, after: true }],
    'max-len': ['error', { code: 120, ignoreComments: true }],

    // TypeScript-Specific Rules
    '@typescript-eslint/no-explicit-any': ['error'],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-non-null-assertion': 'warn',
    '@typescript-eslint/consistent-type-imports': 'error',

    // Import Rules
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
      },
    ],
    'import/no-unresolved': 'off',
    'import/newline-after-import': 'error',

    // Promise Rules
    'promise/always-return': 'off',
    'promise/catch-or-return': 'error',
    'promise/no-nesting': 'warn',

    // JSDoc Rules
    'jsdoc/check-alignment': 'error',
    'jsdoc/check-indentation': 'error',
  },
};
