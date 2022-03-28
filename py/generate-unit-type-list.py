#!python

import re
from typing import Dict, List, Set


class Category:
    unit_types: Set[str] = set()

category_names = {
    "cars": "vehicles"
}

in_file_path = "C:\\Program Files\\Eagle Dynamics\\DCS World OpenBeta\\Scripts\\Database\\db_countries.lua"

lua_out_file_path = "unit-types\\unit-types-all.txt"

categories: Dict[str, Category] = {}

input_file = open(in_file_path, "r", newline='\n', encoding="utf8")
while (True):
    line = input_file.readline()
    if not line:
        break
    match = re.search(r"cnt_unit *\( *units\.(.*?)\..*?, *\"(.*?)\" *\)", line)
    if not match:
        continue
    category_name = match.group(1)
    category_name = category_name[0].lower() + category_name[1:]
    unit_type = match.group(2)
    category = categories.get(category_name)
    if category is None:
        category = Category()
        categories[category_name] = category
    category.unit_types.add(unit_type)

output_file_lua = open(lua_out_file_path, "w", newline='\n', encoding="utf8")

lines: List[str] = []
for name, category in categories.items():
    add_comma = False
    inner_lines: List[str] = []
    if len(category.unit_types) == 0: continue
    lines.append(f"** Group \"{name}\" **")
    unit_types = sorted(category.unit_types)
    for unit_type in unit_types:
        lines.append(unit_type)
    lines.append("")
    lines.append("")

for line in lines:
    output_file_lua.write(line)
    output_file_lua.write("\n")
output_file_lua.close()
