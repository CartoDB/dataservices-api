from itertools import chain

def normalize(str_input):
    return str_input.replace('&quot;', '"') \
                    .replace(';', ',')

def options_to_dict(options):
    options_list = list(chain(*[option.split('=') for option in options]))
    return dict(zip(options_list[::2],options_list[1::2]))
