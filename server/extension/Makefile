# Makefile to generate the extension out of separate sql source files.
# Once a version is released, it is not meant to be changed. E.g: once version 0.0.1 is out, it SHALL NOT be changed.
EXTENSION = cdb_dataservices_server
EXTVERSION = 0.39.0

# The new version to be generated from templates
SED ?= sed
ERB ?= erb
AWK ?= awk
PG_CONFIG ?= pg_config

# Parallel support macros
PG_CONFIG        ?= pg_config
PG_PARALLEL      := $(shell $(PG_CONFIG) --version | ($(AWK) '{$$2*=1000; if ($$2 >= 9600) print 1; else print 0;}' 2> /dev/null || echo 0))

# PG12 compatibility
PG_VERSION := $(shell $(PG_CONFIG) --version | $(AWK) '{split($$2,a,"."); print a[1]}')
PG_12_GE := $(shell [ $(PG_VERSION) -ge 12 ] && echo true)
PLPYTHONU := plpythonu
POSTGIS := postgis
ifeq ($(PG_12_GE), true)
PLPYTHONU := plpython3u
POSTGIS := postgis, postgis_raster
endif

REPLACEMENTS = -e 's/@@EXTVERSION@@/$(EXTVERSION)/g' -e 's/@@plpythonu@@/$(PLPYTHONU)/g' -e 's/@@postgis@@/$(POSTGIS)/g'
REPLACEMENTS_TEST_REVERSE = -e 's/$(PLPYTHONU)/@@plpythonu@@/g'
NEW_EXTENSION_ARTIFACT = $(EXTENSION)--$(EXTVERSION).sql

REGRESS = $(notdir $(basename $(sort $(wildcard test/sql/*test.sql))))
REGRESS_EXPEC = $(notdir $(basename $(sort $(wildcard test/expected/*test.out))))
TEST_DIR = test
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

# The targets listed under REGRESS_PREP are executed before regress
PYTHON_TESTS = ./test/sql/366_empty_table_test.sql
REGRESS_PREP = $(PYTHON_TESTS)

./test/sql/366_empty_table_test.sql: ./test/sql/366_empty_table_test.sql.template
	$(SED) $(REPLACEMENTS) $@.template > $@

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)


$(NEW_EXTENSION_ARTIFACT): $(SOURCES_DATA)
	rm -f $@
	cat $(SOURCES_DATA_DIR)/*.sql >> $@

.PHONY: all
all: $(DATA)

.PHONY: release
release: $(SOURCES_DATA)
	test -n "$(NEW_VERSION)"  # $$NEW_VERSION VARIABLE MISSING. Eg. make release NEW_VERSION=0.x.0
	git mv *.sql old_versions
	cat $(SOURCES_DATA_DIR)/*.sql > $(EXTENSION)--$(NEW_VERSION).sql
	$(ERB) version=$(NEW_VERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql
	$(ERB) version=$(EXTVERSION) upgrade_downgrade_template.erb > $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql
	git add $(EXTENSION)--$(NEW_VERSION).sql
	$(SED) -i -e 's/^EXTVERSION =.*/EXTVERSION = $(NEW_VERSION)/g' Makefile
	git add Makefile
	@echo
	@echo "Please review the file $(EXTENSION)--$(EXTVERSION)--$(NEW_VERSION).sql.in and add any code needed to upgrade $(EXTVERSION) to $(NEW_VERSION)"
	@echo "Please review the file $(EXTENSION)--$(NEW_VERSION)--$(EXTVERSION).sql.in and add any code needed to downgrade $(NEW_VERSION) to $(EXTVERSION)"
	@echo

# Only meant for development time, do not use once a version is released
.PHONY: devclean
devclean:
	rm -f $(NEW_EXTENSION_ARTIFACT)
	rm -f $(PYTHON_TESTS)

# Replace variables (and PARALLEL tags if necessary) and deploy files
.PHONY: replace_variables_and_deploy
replace_variables_and_deploy: $(NEW_EXTENSION_ARTIFACT)
	mkdir -p '$(DESTDIR)$(datadir)/extension/'; \
	for n in $(wildcard old_versions/*.sql *.sql); do \
		$(eval TMPFILE := $(shell mktemp /tmp/XXXXXXXXXX)) \
		if [ "$(PG_PARALLEL)" -eq "0" ]; then \
			$(SED) -e 's/PARALLEL \= [A-Z]*,/''/g' -e 's/PARALLEL [A-Z]*/''/g' $$n > $(TMPFILE); \
			mv $(TMPFILE) $$n; \
		fi; \
		$(SED) $(REPLACEMENTS) $$n > $(TMPFILE); \
		mv $(TMPFILE) '$(DESTDIR)$(datadir)/extension/'$$(basename $$n); \
	done
	

.PHONY: $(EXTENSION).control
$(EXTENSION).control:
	$(SED) $(REPLACEMENTS) $(EXTENSION).control.in > $(EXTENSION).control

# Install the current release into the PostgreSQL extensions directory
.PHONY: deploy
deploy: replace_variables_and_deploy $(EXTENSION).control
	$(INSTALL_DATA) $(EXTENSION).control '$(DESTDIR)$(datadir)/extension/'

.PHONY: install
install: deploy
	@echo "Install overriden"
