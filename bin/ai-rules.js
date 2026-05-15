#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const PACKAGE_ROOT = path.resolve(__dirname, "..");
const MANIFEST_PATH = path.join(PACKAGE_ROOT, ".ai", "manifest.json");
const VALID_AGENTS = new Set(["codex", "cursor", "windsurf", "claude", "copilot", "aider", "all"]);

function printHelp() {
  console.log(`AI Rules Kit

Usage:
  ai-rules <agent> [options]
  ai-rules install <agent> [options]

Agents:
  codex      Install AGENTS.md
  cursor     Install .cursorrules
  windsurf   Install .windsurfrules
  claude     Install .claude/CLAUDE.md
  copilot    Install .github/copilot-instructions.md
  aider      Install CONVENTIONS.md
  all        Install all native adapters

Options:
  --target <path>  Install into a specific project directory
  --force          Overwrite existing files
  --dry-run        Show what would be installed
  -h, --help       Show this help

Examples:
  npx github:thaitantai/coding-agent-rules codex
  npx github:thaitantai/coding-agent-rules claude --force
  npx github:thaitantai/coding-agent-rules all --target ./my-project
`);
}

function parseArgs(argv) {
  const args = [...argv];

  if (args[0] === "-h" || args[0] === "--help") {
    return {
      help: true,
      target: process.cwd(),
      force: false,
      dryRun: false,
    };
  }

  if (args[0] === "install") {
    args.shift();
  }

  const options = {
    agent: args.shift(),
    target: process.cwd(),
    force: false,
    dryRun: false,
  };

  while (args.length > 0) {
    const arg = args.shift();

    if (arg === "--force") {
      options.force = true;
      continue;
    }

    if (arg === "--dry-run") {
      options.dryRun = true;
      continue;
    }

    if (arg === "--target") {
      const target = args.shift();

      if (!target) {
        throw new Error("--target requires a path.");
      }

      options.target = target;
      continue;
    }

    if (arg === "-h" || arg === "--help") {
      options.help = true;
      continue;
    }

    throw new Error(`Unknown option: ${arg}`);
  }

  return options;
}

function readManifest() {
  const manifestContent = fs.readFileSync(MANIFEST_PATH, "utf8");
  return JSON.parse(manifestContent);
}

function normalizeRelativePath(relativePath) {
  return relativePath.split("/").join(path.sep);
}

function copyFile(relativePath, targetRoot, options) {
  const sourcePath = path.join(PACKAGE_ROOT, normalizeRelativePath(relativePath));
  const targetPath = path.join(targetRoot, normalizeRelativePath(relativePath));

  if (!fs.existsSync(sourcePath)) {
    throw new Error(`Source file is missing from package: ${relativePath}`);
  }

  if (fs.existsSync(targetPath) && !options.force) {
    console.log(`Skipped existing ${relativePath}. Use --force to overwrite.`);
    return;
  }

  if (options.dryRun) {
    console.log(`Would install ${relativePath}`);
    return;
  }

  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  fs.copyFileSync(sourcePath, targetPath);
  console.log(`Installed ${relativePath}`);
}

function getSelectedAgents(agent, manifest) {
  if (agent === "all") {
    return Object.keys(manifest.nativeAdapters);
  }

  return [agent];
}

function installRules(options) {
  if (!options.agent || options.help) {
    printHelp();
    return options.help ? 0 : 1;
  }

  if (!VALID_AGENTS.has(options.agent)) {
    throw new Error(`Invalid agent "${options.agent}". Run with --help to see supported agents.`);
  }

  const manifest = readManifest();
  const targetRoot = path.resolve(options.target);

  if (!options.dryRun) {
    fs.mkdirSync(targetRoot, { recursive: true });
  }

  for (const file of manifest.sharedFiles) {
    copyFile(file, targetRoot, options);
  }

  for (const agent of getSelectedAgents(options.agent, manifest)) {
    const adapter = manifest.nativeAdapters[agent];

    if (!adapter) {
      throw new Error(`Agent "${agent}" is not defined in .ai/manifest.json.`);
    }

    copyFile(adapter.path, targetRoot, options);
  }

  console.log("");
  console.log(`AI rules installed for: ${options.agent}`);
  console.log(`Target: ${targetRoot}`);
  return 0;
}

function main() {
  try {
    const options = parseArgs(process.argv.slice(2));
    process.exitCode = installRules(options);
  } catch (error) {
    console.error(error.message);
    console.error("Run with --help for usage.");
    process.exitCode = 1;
  }
}

main();
