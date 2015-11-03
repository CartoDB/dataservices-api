# cdb_geocoder/Makefile

EXTENSION = cdb_geocoder
EXTVERSION = 0.1.0

SED = sed

CDBSCRIPTS = \
  scripts-available/*.sql \
  $(END)

UPGRADABLE = \
  unpackaged \
  0.1.0 \
  $(EXTVERSION)dev \
  $(EXTVERSION)next \
  $(END)

UPGRADES = \
  $(shell echo $(UPGRADABLE) | \
     $(SED) 's/^/$(EXTENSION)--/' | \
     $(SED) 's/$$/--$(EXTVERSION).sql/' | \
     $(SED) 's/ /--$(EXTVERSION).sql $(EXTENSION)--/g')

GITDIR=$(shell test -d .git && echo '.git' || cat .git | $(SED) 's/^gitdir: //')

DATA_built = \
  $(EXTENSION)--$(EXTVERSION).sql \
  $(EXTENSION)--$(EXTVERSION)--$(EXTVERSION)next.sql \
  $(UPGRADES) \
  $(EXTENSION).control

EXTRA_CLEAN = cdb_geocoder_version.sql

DOCS = README.md
REGRESS_NEW = test_ddl_triggers
REGRESS_OLD = $(wildcard test/*.sql)
REGRESS_LEGACY = $(REGRESS_OLD:.sql=)
REGRESS = test_setup $(REGRESS_NEW) $(REGRESS_LEGACY)

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

$(EXTENSION)--$(EXTVERSION).sql: $(CDBSCRIPTS) cdb_geocoder_version.sql Makefile 
	echo '\echo Use "CREATE EXTENSION $(EXTENSION)" to load this file. \quit' > $@
	cat $(CDBSCRIPTS) | \
    $(SED) -e 's/public\./cdb_geocoder./g' \
        -e 's/:DATABASE_USERNAME/cdb_org_admin/g' >> $@
	echo "GRANT USAGE ON SCHEMA cdb_geocoder TO public;" >> $@
	cat cdb_geocoder_version.sql >> $@

$(EXTENSION)--unpackaged--$(EXTVERSION).sql: $(EXTENSION)--$(EXTVERSION).sql util/create_from_unpackaged.sh Makefile
	./util/create_from_unpackaged.sh $(EXTVERSION)

$(EXTENSION)--%--$(EXTVERSION).sql: $(EXTENSION)--$(EXTVERSION).sql
	cp $< $@

$(EXTENSION)--$(EXTVERSION)--$(EXTVERSION)next.sql: $(EXTENSION)--$(EXTVERSION).sql
	cp $< $@

$(EXTENSION).control: $(EXTENSION).control.in Makefile
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

cdb_geocoder_version.sql: cdb_geocoder_version.sql.in Makefile $(GITDIR)/index
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@
