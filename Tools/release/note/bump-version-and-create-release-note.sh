#! /bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT

# get the current version
VERSION=$(cat VERSION)
OUTPUT="docs/releases/${RELEASE_VERSION}.md"

# generate release note
docker run --rm -it -v "$(pwd)":/usr/local/src/your-app ferrarimarco/github-changelog-generator \
  --user aws-observability \
	--project aws-otel-collector \
	-t "${GITHUB_TOKEN}" \
	--since-tag "${VERSION}" \
	--future-release "${RELEASE_VERSION}" \
	--output "${OUTPUT}" \
	--exclude-labels bumpversion

# bump the version
echo "${RELEASE_VERSION}" > VERSION

git add VERSION "docs/releases/${RELEASE_VERSION}.md"
git commit -m "bump version to ${RELEASE_VERSION}"
