# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_geocoder_server
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
SED = sed

UPGRADABLE = \
	0.0.1 \
	$(END)

UPGRADES = \
	$(shell echo $(UPGRADABLE) | \
		$(SED) 's/^/$(EXTENSION)--/' | \
		$(SED) 's/$$/--$(EXTVERSION).sql/' | \
		$(SED) 's/ /--$(EXTVERSION).sql $(EXTENSION)--/g')

DATA = $(EXTENSION)--$(EXTVERSION).sql \
	$(UPGRADES)

REGRESS = $(notdir $(basename $(wildcard sql/*test.sql)))

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

SOURCES_DATA = $(wildcard sql/$(EXTVERSION)/*.sql)

$(DATA): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA) >> $@

$(EXTENSION)--%--$(EXTVERSION).sql: $(EXTENSION)--$(EXTVERSION).sql
		cp $< $@

all: $(DATA)

# Only meant for development time, do not use once a version is released
devclean:
	rm -f $(DATA)
