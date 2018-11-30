from itertools import chain

def normalize(str_input):
    return str_input.replace('&quot;', '"') \
                    .replace(';', ',')

def options_to_dict(options):
    return dict(option.split("=") for option in options)
