# check if git is available
ifeq ($(shell which git),)
        $(warning "git is not available, binaries will not include git SHA")
        GIT_SHA :=
        GIT_TREE_STATE :=
        GIT_TAG :=
        VERSION_SUFFIX := unknown
else
        GIT_SHA := $(shell git rev-parse --short HEAD)
        # Tree state is "dirty" if there are uncommitted changes, untracked files are ignored
        GIT_TREE_STATE := $(shell test -n "`git status --porcelain --untracked-files=no`" && echo "dirty" || echo "clean")
        # Empty string if we are not building a tag
        GIT_TAG := $(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null)
        ifeq ($(GIT_TREE_STATE),dirty)
                VERSION_SUFFIX := $(GIT_SHA).dirty
        else
                VERSION_SUFFIX := $(GIT_SHA)
        endif
endif

# if building a tag or VERSION is set, set RELEASE_STATUS to "released"
ifdef VERSION
        RELEASE_STATUS := released
else ifneq ($(GIT_TAG),)
        RELEASE_STATUS := released
else
        RELEASE_STATUS := unreleased
endif

ifndef VERSION
        VERSION := $(shell head -n 1 VERSION)
        DEV_VERSION := $(VERSION)-$(VERSION_SUFFIX)
else
        DOCKER_IMG_VERSION := $(VERSION)
endif

GOVERSION_LDFLAGS = -X github.mthreads.com/mcc/mccflow-operator/pkg/version.Version=$(VERSION)
GOVERSION_LDFLAGS += -X github.mthreads.com/mcc/mccflow-operator/pkg/version.GitSHA=$(GIT_SHA)
GOVERSION_LDFLAGS += -X github.mthreads.com/mcc/mccflow-operator/pkg/version.GitTreeState=$(GIT_TREE_STATE)
GOVERSION_LDFLAGS += -X github.mthreads.com/mcc/mccflow-operator/pkg/version.ReleaseStatus=$(RELEASE_STATUS)

.PHONY: version-info
version-info:
	@echo "===> Version information <==="
	@echo "VERSION: $(VERSION)"
	@echo "DEV_VERSION: $(DEV_VERSION)"
	@echo "GIT_SHA: $(GIT_SHA)"
	@echo "GIT_TREE_STATE: $(GIT_TREE_STATE)"
	@echo "RELEASE_STATUS: $(RELEASE_STATUS)"

.PHONY: version-image
version-image:
	@echo $(DEV_VERSION)