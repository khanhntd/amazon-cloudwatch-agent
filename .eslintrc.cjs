// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT

/**
 * ESLint configuration.
 *
 * @see https://eslint.org/docs/user-guide/configuring
 * @type {import("eslint").Linter.Config}
 */
module.exports = {
  root: true,

  env: { browser: true, commonjs: true, node: true, jest: true, es6: true },

  extends: [
    "eslint:recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "prettier",
  ],

  parserOptions: {
    ecmaVersion: 2022,
    sourceType: "module",
  },

  rules:{
    "import/export": 0,
    "import/prefer-default-export": "off",
    "import/no-default-export": "off",
    "import/default":"off"
  },

  overrides: [
    {
      files: ["*.ts", "*.tsx"],
      parser: "@typescript-eslint/parser",
      extends: [
        "plugin:@typescript-eslint/recommended",
        "plugin:react/recommended",
        "plugin:react-hooks/recommended",
      ],
      rules: {
        "react/no-children-prop": "off",
        "react/react-in-jsx-scope": "off",

      },
      plugins: ["@typescript-eslint"],
      parserOptions: {
      },
    },
    {
      files: ["*.test.js"],
      env: { jest: true },
    },
    {
      files: [
        ".eslintrc.cjs",
        "rollup.config.mjs",
        "scripts/**/*.js",
      ],
      env: { node: true },
    },
    {
      files: ["*.cjs"],
      parserOptions: { sourceType: "script" },
    },
  ],

  ignorePatterns: [
    "/.git",
    "/.husky",
    "/.yarn",
    "/dist",
  ],

  settings: {
    "import/resolver": {
      typescript: {
        project: ["tsconfig.json"],
      },
      node: {
        "extensions": [".js", ".jsx", ".ts", ".tsx"]
      }
    },
    "import/core-modules": ["__STATIC_CONTENT_MANIFEST"],
    react: {
      version: "detect",
    },
  },
};
