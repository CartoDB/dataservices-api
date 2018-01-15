import plpy


def country_to_iso3(country):
    """ Convert country to its iso3 code """
    if not country:
        return None

    try:
        country_plan = plpy.prepare("SELECT adm0_a3 as iso3 FROM admin0_synonyms WHERE lower(regexp_replace($1, " \
                                    "'[^a-zA-Z\u00C0-\u00ff]+', '', 'g'))::text = name_; ", ['text'])
        country_result = plpy.execute(country_plan, [country], 1)
        if country_result:
            return country_result[0]['iso3']
        else:
            return None
    except BaseException as e:
        plpy.warning("Can't get the iso3 code from {0}: {1}".format(country, e))
        return None
