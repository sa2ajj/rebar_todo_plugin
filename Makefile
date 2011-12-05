DEST_DIR=~/.rebar/plugins/ebin/

all: compile

compile:
	rebar compile

install: $(DEST_DIR)
	cp ebin/*.beam ~/.rebar/plugins/ebin/

$(DEST_DIR):
	mkdir -p $(DEST_DIR)

update_todo:
	rebar todo
