import sys
import re
import itertools
from tempfile import NamedTemporaryFile
from fontTools.agl import toUnicode
import fontforge

font = fontforge.open(sys.argv[1])
calts = [
    x for x in font.gsub_lookups
    if any("calt" in y for y in font.getLookupInfo(x)[2])
]

if len(calts) > 1:
    for x in calts[1:]:
        font.mergeLookups(calts[0], x)

with NamedTemporaryFile() as tmp:
    font.generateFeatureFile(tmp.name, calts[0])

    with open(tmp.name, 'r') as f:
        content = f.read()
        pattern = r"sub\s+\[([^\]]+)\]'?\s+\[([^\]]+)\]'?(?:\s\[([^\]]+)\]'?)?"

        matches = re.finditer(pattern, content)

        for m in matches:
            characters = [x.split() for x in m.groups() if x]
            combinations = itertools.product(*characters)

            for item in combinations:
                perm = "".join([toUnicode(x[1:]) for x in item])
                print(perm)
