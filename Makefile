export BASE_SPACE=$(shell pwd)
export BUILD_SPACE=$(BASE_SPACE)/build

VERSION = $(shell echo `git describe --tag --dirty``git status --porcelain 2>/dev/null| grep -q "^??" &&echo '-untracked'`)
VERSION := $(shell echo ${VERSION} | sed -e "s/^v//")
nightly-release: VERSION := $(shell echo ${VERSION}-nightly-build)
# In case building outside of a git repo, use the version presented in the CWAGENT_VERSION file as a fallback
ifeq ($(VERSION),)
VERSION := `cat CWAGENT_VERSION`
endif

# Determine agent build mode, default to PIE mode
ifndef CWAGENT_BUILD_MODE
CWAGENT_BUILD_MODE=default
endif

BUILD := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS = -s -w
LDFLAGS +=  -X github.com/aws/private-amazon-cloudwatch-agent-staging/cfg/agentinfo.VersionStr=${VERSION}
LDFLAGS +=  -X github.com/aws/private-amazon-cloudwatch-agent-staging/cfg/agentinfo.BuildStr=${BUILD}
LINUX_AMD64_BUILD = CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -buildmode=${CWAGENT_BUILD_MODE} -ldflags="${LDFLAGS}" -o $(BUILD_SPACE)/bin/linux_amd64
LINUX_ARM64_BUILD = CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -buildmode=${CWAGENT_BUILD_MODE} -ldflags="${LDFLAGS}" -o $(BUILD_SPACE)/bin/linux_arm64
WIN_BUILD = GOOS=windows GOARCH=amd64 go build -buildmode=${CWAGENT_BUILD_MODE} -ldflags="${LDFLAGS}" -o $(BUILD_SPACE)/bin/windows_amd64
DARWIN_BUILD = GO111MODULE=on GOOS=darwin GOARCH=amd64 go build -ldflags="${LDFLAGS}" -o $(BUILD_SPACE)/bin/darwin_amd64

IMAGE = amazon/cloudwatch-agent:$(VERSION)
DOCKER_BUILD_FROM_SOURCE = docker build -t $(IMAGE) -f ./amazon-cloudwatch-container-insights/cloudwatch-agent-dockerfile/source/Dockerfile

CW_AGENT_IMPORT_PATH=github.com/aws/private-amazon-cloudwatch-agent-staging
ALL_SRC := $(shell find . -name '*.go' -type f | sort)
TOOLS_BIN_DIR := $(abspath ./build/tools)

GOIMPORTS_OPT?= -w -local $(CW_AGENT_IMPORT_PATH)

GOIMPORTS = $(TOOLS_BIN_DIR)/goimports
SHFMT = $(TOOLS_BIN_DIR)/shfmt
LINTER = $(TOOLS_BIN_DIR)/golangci-lint
IMPI = $(TOOLS_BIN_DIR)/impi
release: clean test build package-rpm package-deb package-win package-darwin

nightly-release: release

build: check_secrets amazon-cloudwatch-agent config-translator start-amazon-cloudwatch-agent amazon-cloudwatch-agent-config-wizard config-downloader

check_secrets::
	if grep --exclude-dir=build --exclude-dir=vendor -exclude=integration/msi/tools/amazon-cloudwatch-agent.wxs -E "(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}|(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)(\"|')?\\s*(:|=>|=)\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?" -Rn .; then echo "check_secrets failed"; exit 1; fi;

create-version-file:
	@echo Version: ${VERSION}
	@echo Building time: ${BUILD}
	echo "$(VERSION)" > CWAGENT_VERSION

copy-version-file: create-version-file
	mkdir -p build/bin/
	cp CWAGENT_VERSION $(BUILD_SPACE)/bin/CWAGENT_VERSION

amazon-cloudwatch-agent: copy-version-file
	@echo Building amazon-cloudwatch-agent
	$(LINUX_AMD64_BUILD)/amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent
	$(LINUX_ARM64_BUILD)/amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent
	$(WIN_BUILD)/amazon-cloudwatch-agent.exe github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent
	$(DARWIN_BUILD)/amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent

config-translator: copy-version-file
	@echo Building config-translator
	$(LINUX_AMD64_BUILD)/config-translator github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator
	$(LINUX_ARM64_BUILD)/config-translator github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator
	$(WIN_BUILD)/config-translator.exe github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator
	$(DARWIN_BUILD)/config-translator github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator

start-amazon-cloudwatch-agent: copy-version-file
	@echo Building start-amazon-cloudwatch-agent
	$(LINUX_AMD64_BUILD)/start-amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent
	$(LINUX_ARM64_BUILD)/start-amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent
	$(WIN_BUILD)/start-amazon-cloudwatch-agent.exe github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent
	$(DARWIN_BUILD)/start-amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent

amazon-cloudwatch-agent-config-wizard: copy-version-file
	@echo Building amazon-cloudwatch-agent-config-wizard
	$(LINUX_AMD64_BUILD)/amazon-cloudwatch-agent-config-wizard github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent-config-wizard
	$(LINUX_ARM64_BUILD)/amazon-cloudwatch-agent-config-wizard github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent-config-wizard
	$(WIN_BUILD)/amazon-cloudwatch-agent-config-wizard.exe github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent-config-wizard
	$(DARWIN_BUILD)/amazon-cloudwatch-agent-config-wizard github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent-config-wizard

config-downloader: copy-version-file
	@echo Building config-downloader
	$(LINUX_AMD64_BUILD)/config-downloader github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-downloader
	$(LINUX_ARM64_BUILD)/config-downloader github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-downloader
	$(WIN_BUILD)/config-downloader.exe github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-downloader
	$(DARWIN_BUILD)/config-downloader github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-downloader

# A fast build that only builds amd64, we don't need wizard and config downloader
build-for-docker: build-for-docker-amd64

build-for-docker-amd64:
	$(LINUX_AMD64_BUILD)/amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent
	$(LINUX_AMD64_BUILD)/start-amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent
	$(LINUX_AMD64_BUILD)/config-translator github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator

build-for-docker-arm64:
	$(LINUX_ARM64_BUILD)/amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/amazon-cloudwatch-agent
	$(LINUX_ARM64_BUILD)/start-amazon-cloudwatch-agent github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/start-amazon-cloudwatch-agent
	$(LINUX_ARM64_BUILD)/config-translator github.com/aws/private-amazon-cloudwatch-agent-staging/cmd/config-translator

#Install from source for golangci-lint is not recommended based on https://golangci-lint.run/usage/install/#install-from-source so using binary
#installation
install-tools:
	GOBIN=$(TOOLS_BIN_DIR) go install golang.org/x/tools/cmd/goimports
	GOBIN=$(TOOLS_BIN_DIR) go install mvdan.cc/sh/v3/cmd/shfmt@latest
	GOBIN=$(TOOLS_BIN_DIR) go install github.com/pavius/impi/cmd/impi@v0.0.3
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TOOLS_BIN_DIR) v1.45.2

fmt: install-tools
	go fmt ./...
	echo $(ALL_SRC) | xargs -n 10 $(GOIMPORTS) $(GOIMPORTS_OPT)

fmt-sh: install-tools
	${SHFMT} -w -d -i 5 .

impi: install-tools
	# Skip plugins/plugins.go
	echo $(ALL_SRC) | xargs -n 10 ${IMPI} --local $(CW_AGENT_IMPORT_PATH) --scheme stdThirdPartyLocal --skip plugins/plugins.go

lint: install-tools
	${LINTER} run ./...

test:
	CGO_ENABLED=0 go test -coverprofile coverage.txt -failfast ./awscsm/... ./cfg/... ./cmd/... ./handlers/... ./internal/... ./logger/... ./logs/... ./metric/... ./plugins/... ./profiler/... ./tool/... ./translator/...

clean::
	rm -rf release/ build/
	rm -f CWAGENT_VERSION

package-prepare-rpm:
	# amd64 rpm
	mkdir -p $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/linux_amd64/* $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent-ctl $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent.service $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.conf $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.spec $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json

	# arm64 rpm
	mkdir -p $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/linux_arm64/* $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent-ctl $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent.service $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.conf $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.spec $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json
	cp -rf $(BASE_SPACE)/Tools $(BUILD_SPACE)/

package-prepare-deb:
	# amd64 deb
	mkdir -p $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/linux_amd64/* $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent-ctl $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent.service $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.conf $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json

	# arm64 deb
	mkdir -p $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/linux_arm64/* $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent-ctl $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/dependencies/amazon-cloudwatch-agent.service $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/linux/amazon-cloudwatch-agent.conf $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json

	cp -rf $(BASE_SPACE)/Tools $(BUILD_SPACE)/
	cp -rf $(BASE_SPACE)/packaging $(BUILD_SPACE)/

package-prepare-win-zip:
	# amd64 win
	mkdir -p $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/windows_amd64/* $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json
	cp ${BASE_SPACE}/packaging/windows/amazon-cloudwatch-agent-ctl.ps1 $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp ${BASE_SPACE}/packaging/windows/install.ps1 $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp ${BASE_SPACE}/packaging/windows/uninstall.ps1 $(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg/
	cp -rf $(BASE_SPACE)/Tools $(BUILD_SPACE)/

package-prepare-darwin-tar:
	# amd64 darwin
	mkdir -p $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg
	cp $(BUILD_SPACE)/bin/darwin_amd64/* $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/licensing/* $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/RELEASE_NOTES $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BUILD_SPACE)/bin/CWAGENT_VERSION $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/cfg/commonconfig/common-config.toml $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/translator/config/schema.json $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/amazon-cloudwatch-agent-schema.json
	cp $(BASE_SPACE)/packaging/darwin/amazon-cloudwatch-agent-ctl $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/
	cp $(BASE_SPACE)/packaging/darwin/com.amazon.cloudwatch.agent.plist $(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg/

	cp -rf $(BASE_SPACE)/Tools $(BUILD_SPACE)/

.PHONY: package-rpm
package-rpm: package-prepare-rpm
	ARCH=amd64 TARGET_SUPPORTED_ARCH=x86_64 PREPKGPATH="$(BUILD_SPACE)/private/linux/amd64/rpm/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_rpm.sh
	ARCH=arm64 TARGET_SUPPORTED_ARCH=aarch64 PREPKGPATH="$(BUILD_SPACE)/private/linux/arm64/rpm/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_rpm.sh

.PHONY: package-deb
package-deb: package-prepare-deb
	ARCH=amd64 TARGET_SUPPORTED_ARCH=x86_64 PREPKGPATH="$(BUILD_SPACE)/private/linux/amd64/deb/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_deb.sh
	ARCH=arm64 TARGET_SUPPORTED_ARCH=aarch64 PREPKGPATH="$(BUILD_SPACE)/private/linux/arm64/deb/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_deb.sh

.PHONY: package-win
package-win: package-prepare-win-zip
	ARCH=amd64 TARGET_SUPPORTED_ARCH=x86_64 PREPKGPATH="$(BUILD_SPACE)/private/windows/amd64/zip/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_win.sh

.PHONY: package-darwin
package-darwin: package-prepare-darwin-tar
	ARCH=amd64 TARGET_SUPPORTED_ARCH=x86_64 PREPKGPATH="$(BUILD_SPACE)/private/darwin/amd64/tar/amazon-cloudwatch-agent-pre-pkg" $(BUILD_SPACE)/Tools/src/create_darwin.sh

.PHONY: fmt fmt-sh build test clean

.PHONY: dockerized-build dockerized-build-vendor
dockerized-build:
	$(DOCKER_BUILD_FROM_SOURCE) .
	@echo Built image:
	@echo $(IMAGE)

# Use vendor instead of proxy when building w/ vendor folder
dockerized-build-vendor:
	$(DOCKER_BUILD_FROM_SOURCE) --build-arg GO111MODULE=off .