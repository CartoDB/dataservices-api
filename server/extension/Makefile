# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_dataservices_server
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

# The new version to be generated from templates
NEW_EXTENSION_ARTIFACT = $(EXTENSION)--$(EXTVERSION).sql
OLD_VERSIONS = $(wildcard old_versions/*.sql)

# DATA is a special variable used by postgres build infrastructure
# These are the files to be installed in the server shared dir,
# for installation from scratch, upgrades and downgrades.
# @see http://www.postgresql.org/docs/current/static/extend-pgxs.html
DATA =  $(NEW_EXTENSION_ARTIFACT) \
  $(OLD_VERSIONS) \
  cdb_dataservices_server--0.6.1--0.6.0.sql \
  cdb_dataservices_server--0.6.0--0.6.1.sql

REGRESS = $(notdir $(basename $(wildcard test/sql/*test.sql)))
TEST_DIR = test/
REGRESS_OPTS = --inputdir='$(TEST_DIR)' --outputdir='$(TEST_DIR)'

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

SOURCES_DATA_DIR = sql/

SOURCES_DATA = $(wildcard sql/*.sql)

$(NEW_EXTENSION_ARTIFACT): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA_DIR)/*.sql >> $@

all: $(DATA)

# Only meant for development time, do not use once a version is released
devclean:
	rm -f $(NEW_EXTENSION_ARTIFACT)
