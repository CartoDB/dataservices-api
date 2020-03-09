# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_dataservices_server
EXTVERSION = $(shell grep default_version $(EXTENSION).control.in | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
# The new version to be generated from templates
SED = sed
ERB = erb
NEW_EXTENSION_ARTIFACT = $(EXTENSION)--$(EXTVERSION).sql
AWK = awk

# Parallel support macros
PG_CONFIG         = pg_config
PG_PARALLEL      := $(shell $(PG_CONFIG) --version | ($(AWK) '{$$2*=1000; if ($$2 >= 9600) print 1; else print 0;}' 2> /dev/null || echo 0))

REGRESS = $(notdir $(basename $(sort $(wildcard test/sql/*test.sql))))
REGRESS_EXPEC = $(notdir $(basename $(sort $(wildcard test/expected/*test.out))))
TEST_DIR = test_out
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
SOURCES_DATA_DIR_OUT = sql_out/

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# PG12 compatibility
PG_VERSION := $(shell $(PG_CONFIG) --version | $(AWK) '{split($$2,a,"."); print a[1]}')
PG_12_GE := $(shell [ $(PG_VERSION) -ge 12 ] && echo true)
PLPYTHONU := plpythonu
ifeq ($(PG_12_GE), true)
PLPYTHONU := plpython3u
endif

REPLACEMENTS = -e 's/@@plpythonu@@/$(PLPYTHONU)/g'
ifneq ($(NEW_VERSION),)
REPLACEMENTS += -e 's/$(EXTVERSION)/$(NEW_VERSION)/g'
endif

$(NEW_EXTENSION_ARTIFACT): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA_DIR_OUT)/*.sql >> $@
ifeq ($(PG_PARALLEL), 0)
# Remove PARALLEL in aggregates and functions
	$(eval TMPFILE := $(shell mktemp /tmp/$(basename $0).XXXXXXXX))
	$(SED) -e 's/PARALLEL \= [A-Z]*,/''/g' \
		-e 's/PARALLEL [A-Z]*/''/g' $@ > $(TMPFILE)
	mv $(TMPFILE) $@
endif

$(EXTENSION).control: $(EXTENSION).control.in Makefile
	$(SED) $(REPLACEMENTS)  $< > $@

.PHONY: all
all: replace_variables $(DATA)

.PHONY: release
release: replace_variables $(EXTENSION).control $(SOURCES_DATA)
	test -n "$(NEW_VERSION)"  # $$NEW_VERSION VARIABLE MISSING. Eg. make release NEW_VERSION=0.x.0
	git mv *.sql old_versions
	$(SED) $(REPLACEMENTS) $(EXTENSION).control.in > $(EXTENSION).control
	git add $(EXTENSION).control
	cat $(SOURCES_DATA_DIR)/*.sql > $(EXTENSION)--$(NEW_VERSION).sql
	$(ERB) version=$(NEW_VERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql
	$(ERB) version=$(EXTVERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql
	git add $(EXTENSION)--$(NEW_VERSION).sql
	@echo
	@echo "Please review the file $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql and add any code needed to upgrade $(EXTVERSION) to $(NEW_VERSION)"
	@echo "Please review the file $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql and add any code needed to downgrade $(NEW_VERSION) to $(EXTVERSION)"
	@echo

# Only meant for development time, do not use once a version is released
.PHONY: devclean
devclean:
	rm -f $(NEW_EXTENSION_ARTIFACT)
	rm -rf $(TEST_DIR)
	rm -rf $(SOURCES_DATA_DIR_OUT)
	rm -rf $(EXTENSION).control
	for f in $(basename $(wildcard old_versions/*.bak)); do \
		mv $${f}.bak $${f}; \
	done

# If needed remove PARALLEL tags from the release files
release_remove_parallel_deploy:
ifeq ($(PG_PARALLEL), 0)
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

# Replacing variables defined within test files
replace_variables:
	# tests
	mkdir -p $(TEST_DIR)
	mkdir -p $(TEST_DIR)/expected
	mkdir -p $(TEST_DIR)/sql
	for f in $(REGRESS); do \
		cat test/sql/$${f}.sql | \
		sed -e 's/@@plpythonu@@/$(PLPYTHONU)/g' \
		> $(TEST_DIR)/sql/$${f}.sql; \
	done
	for f in $(REGRESS_EXPEC); do \
		cat test/expected/$${f}.out | \
		sed -e 's/@@plpythonu@@/$(PLPYTHONU)/g' \
		> $(TEST_DIR)/expected/$${f}.out; \
	done
	# data
	mkdir -p $(SOURCES_DATA_DIR_OUT)
	for f in $(notdir $(SOURCES_DATA)); do \
		cat $(SOURCES_DATA_DIR)/$${f} | \
		sed -e 's/@@plpythonu@@/$(PLPYTHONU)/g' \
		> $(SOURCES_DATA_DIR_OUT)/$${f}; \
	done
	for f in $(basename $(wildcard old_versions/*.bak)); do \
		mv $${f}.bak $${f}; \
		sed --in-place=.bak -e 's/@@plpythonu@@/$(PLPYTHONU)/g' $${f}; \
	done

install: deploy

reinstall: install
	psql -U postgres -d dataservices_db -c "drop extension if exists cdb_dataservices_server; create extension cdb_dataservices_server;"
