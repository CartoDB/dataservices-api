# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_dataservices_server
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
# The new version to be generated from templates
SED = sed
ERB = erb
REPLACEMENTS = -i 's/$(EXTVERSION)/$(NEW_VERSION)/g'
NEW_EXTENSION_ARTIFACT = $(EXTENSION)--$(EXTVERSION).sql
AWK = awk

# Parallel support macros
PG_CONFIG         = pg_config
PG_PARALLEL      := $(shell $(PG_CONFIG) --version | ($(AWK) '{$$2*=1000; if ($$2 >= 9600) print 1; else print 0;}' 2> /dev/null || echo 0))

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
ifeq ($(PG_PARALLEL), 0)
# Remove PARALLEL in aggregates and functions
	$(eval TMPFILE := $(shell mktemp /tmp/$(basename $0).XXXXXXXX))
	$(SED) -e 's/PARALLEL \= [A-Z]*,/''/g' \
		-e 's/PARALLEL [A-Z]*/''/g' $@ > $(TMPFILE)
	mv $(TMPFILE) $@
endif

.PHONY: all
all: $(DATA)

.PHONY: release
release: $(EXTENSION).control $(SOURCES_DATA)
	test -n "$(NEW_VERSION)"  # $$NEW_VERSION VARIABLE MISSING. Eg. make release NEW_VERSION=0.x.0
	git mv *.sql old_versions
	$(SED) $(REPLACEMENTS) $(EXTENSION).control
	git add $(EXTENSION).control
	cat $(SOURCES_DATA_DIR)/*.sql > $(EXTENSION)--$(NEW_VERSION).sql
	$(ERB) version=$(NEW_VERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql
	$(ERB) version=$(EXTVERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql
	cat $(EXTENSION)--$(NEW_VERSION).sql >> $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql
	git add $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql $(EXTENSION)--$(NEW_VERSION).sql

# Only meant for development time, do not use once a version is released
.PHONY: devclean
devclean:
	rm -f $(NEW_EXTENSION_ARTIFACT)

# If needed remove PARALLEL tags from the release files
release_remove_parallel_deploy:
ifeq ($(PG_PARALLEL), 1)
	for n in $(wildcard old_versions/*.sql *.sql); do \
		$(eval TMPFILE := $(shell mktemp /tmp/XXXXXXXXXX)) \
		$(SED) -e 's/PARALLEL \= [A-Z]*,/''/g' -e 's/PARALLEL [A-Z]*/''/g' $$n > $(TMPFILE); \
		mv $(TMPFILE) $$n; \
	done
endif

# Install the current release into the PostgreSQL extensions directory
deploy: release_remove_parallel_deploy
	$(INSTALL_DATA) $(EXTENSION).control '$(DESTDIR)$(datadir)/extension/'
	$(INSTALL_DATA) old_versions/*.sql *.sql '$(DESTDIR)$(datadir)/extension/'
