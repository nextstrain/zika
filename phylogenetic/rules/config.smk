"""
Shared functions used to parse the config.
"""
from textwrap import dedent, indent
from typing import Union


def as_list(config_param: Union[list,str]) -> list:
    if isinstance(config_param, list):
        return config_param

    if isinstance(config_param, str):
        return config_param.split()

    raise TypeError(indent(dedent(f"""\
        'config_param' must be a list or a string.
        Provided {config_param}, which is {type(config_param)}.
        """),"    "))


