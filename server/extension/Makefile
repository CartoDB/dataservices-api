# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_dataservices_server
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
# The new version to be generated from templates
SED = sed
ERB = erb
REPLACEMENTS = -i 's/$(EXTVERSION)/$(NEW_VERSION)/g'
NEW_EXTENSION_ARTIFACT = $(EXTENSION)--$(EXTVERSION).sql

REGRESS = $(notdir $(basename $(sort $(wildcard test/sql/*test.sql))))
TEST_DIR = test/
REGRESS_OPTS = --inputdir='$(TEST_DIR)' --outputdir='$(TEST_DIR)' --user='postgres'

# DATA is a special variable used by postgres build infrastructure
# These are the files to be installed in the server shared dir,
# for installation from scratch, upgrades and downgrades.
# @see http://www.postgresql.org/docs/current/static/extend-pgxs.html
OLD_VERSIONS = $(wildcard old_versions/*.sql)
DATA = $(NEW_EXTENSION_ARTIFACT) \
		 $(EXTENSION)--*--*.sql \
		 $(OLD_VERSIONS)
SOURCES_DATA_DIR = sql/
SOURCES_DATA = $(wildcard sql/*.sql)

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

$(NEW_EXTENSION_ARTIFACT): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA_DIR)/*.sql >> $@

.PHONY: all
all: $(DATA)

.PHONY: release
release: $(EXTENSION).control $(SOURCES_DATA)
	test -n "$(NEW_VERSION)"  # $$NEW_VERSION VARIABLE MISSING. Eg. make release NEW_VERSION=0.x.0
	mv *.sql old_versions
	$(SED) $(REPLACEMENTS) $(EXTENSION).control
	cat $(SOURCES_DATA_DIR)/*.sql > $(EXTENSION)--$(NEW_VERSION).sql
	$(ERB) version=$(NEW_VERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql
	$(ERB) version=$(EXTVERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql

# Only meant for development time, do not use once a version is released
.PHONY: devclean
devclean:
	rm -f $(NEW_EXTENSION_ARTIFACT)
