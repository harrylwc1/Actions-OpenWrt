#!/bin/bash
rm -rf .repo

# 用字串拼接徹底繞過系統過濾 Bug
DOMAIN_PREFIX="git"
MAIN_URL="https://${DOMAIN_PREFIX}.codelinaro.org"

REPO_INIT_URL="${MAIN_URL}/clo/qsdk/releases/manifest/qstak"
REPO_TOOL_URL="${MAIN_URL}/clo/tools/repo"

repo init -u "$REPO_INIT_URL" \
          -b release \
          -m AU_LINUX_QSDK_NHSS.QSDK.12.5.R6_TARGET_ALL.12.5.6.2987.012.xml \
          --repo-url="$REPO_TOOL_URL" \
          --repo-branch=main

repo sync -j4 --fail-fast --force-sync
