# Shell parameters
SHELL=/bin/bash -o pipefail

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean

# App parameters
NAME := c2-drop
APP_MAIN_PATH := ./cmd/$(NAME)
BINARY_NAME := falco-$(NAME).so

# Go debug
ifeq ($(DEBUG), 1)
    GODEBUGFLAGS= GODEBUG=cgocheck=2
else
    GODEBUGFLAGS= GODEBUG=cgocheck=0
endif

all: build

build:
	@$(GODEBUGFLAGS) $(GOBUILD) -v -o $(BINARY_NAME) $(APP_MAIN_PATH)

clean:
	@rm -f *.so *.h