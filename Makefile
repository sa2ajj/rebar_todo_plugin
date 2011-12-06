DEST_DIR=~/.rebar/plugins/ebin/
REBAR := $(shell which rebar || echo $(PWD)/tools/rebar)

all: compile

compile:
	$(REBAR) compile

install: $(DEST_DIR)
	cp ebin/*.beam ~/.rebar/plugins/ebin/

$(DEST_DIR):
	mkdir -p $(DEST_DIR)
