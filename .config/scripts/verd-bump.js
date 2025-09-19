#!/usr/bin/env node
// Dead-simple version bumper + publish (always uses Verdaccio):
// - If version has no "-" -> append "-verd.0"
// - If version has "-" -> bump the last numeric suffix (alpha/beta/verd -> +1; if none, add .0)
// - Runs "npm run build" if present
// - Publishes with npm --registry http://localhost:4873 (override via VERDACCIO_REGISTRY env)

import fs from "node:fs";
import { execSync } from "node:child_process";

const REGISTRY = process.env.VERDACCIO_REGISTRY || "http://localhost:4873";
const pkgPath = "package.json";

if (!fs.existsSync(pkgPath)) {
  console.error("package.json not found");
  process.exit(1);
}

const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
const cur = String(pkg.version || "");
if (!cur) {
  console.error("No version in package.json");
  process.exit(1);
}

let next = cur;
if (!cur.includes("-")) {
  next = `${cur}-verd.0`;
} else {
  const parts = cur.split("-");
  const last = parts[parts.length - 1]; // e.g. alpha.3 | verd.9 | rc
  const segs = last.split(".");
  const lastSeg = segs[segs.length - 1];
  if (/^\d+$/.test(lastSeg)) {
    segs[segs.length - 1] = String(Number(lastSeg) + 1);
  } else {
    segs.push("0");
  }
  parts[parts.length - 1] = segs.join(".");
  next = parts.join("-");
}

if (next !== cur) {
  pkg.version = next;
  fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");
  console.log(`Version -> ${cur} => ${next}`);
} else {
  console.log(`Version unchanged -> ${cur}`);
}

// Build if script exists
if (pkg.scripts?.build) {
  execSync("npm run build", { stdio: "inherit" });
}

// Always publish to Verdaccio registry
try {
  execSync(`npm publish --registry ${REGISTRY}`, { stdio: "inherit" });
  console.log(
    "Published to Verdaccio registry and bumped version to",
    next + " from " + cur + ".",
  );
} catch (e) {
  console.error(e);
  process.exit(1);
}
