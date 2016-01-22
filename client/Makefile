# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_geocoder_client
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

DATA = $(EXTENSION)--$(EXTVERSION).sql

REGRESS = $(notdir $(basename $(wildcard test/$(EXTVERSION)/sql/*test.sql)))

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

SOURCES_DATA_DIR = sql/$(EXTVERSION)

# The interface definition is used along with some templates to automatically generate code
RENDERER = ../sql-template-renderer
INTERFACE_FILE = ../interface_$(EXTVERSION).yaml
TEMPLATE_DIR = templates
TEMPLATE_FILES = $(wildcard $(TEMPLATE_DIR)/*.erb)
GENERATED_SQL_FILES = $(patsubst $(TEMPLATE_DIR)/%.erb, $(SOURCES_DATA_DIR)/%.sql, $(TEMPLATE_FILES))

$(GENERATED_SQL_FILES): $(SOURCES_DATA_DIR)/%.sql: $(TEMPLATE_DIR)/%.erb $(INTERFACE_FILE) $(RENDERER)
	$(RENDERER) $(INTERFACE_FILE) $< > $@

SOURCES_DATA = $(wildcard $(SOURCES_DATA_DIR)/*.sql) $(GENERATED_SQL_FILES)

$(DATA): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA_DIR)/*.sql >> $@

$(EXTENSION)--%--$(EXTVERSION).sql: $(EXTENSION)--$(EXTVERSION).sql
		cp $< $@

all: $(DATA)

# Only meant for development time, do not use once a version is released
devclean:
	rm -f $(DATA)
	rm -f $(GENERATED_SQL_FILES)
