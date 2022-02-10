#!/usr/bin/env python3

import sys

input_file = sys.argv[1]
all_input = open(input_file).read().split('\n')
header_content = all_input[0]
body_content = all_input[1:]

lines = []
lines.append("<main>")
lines.append("<table>")
lines.append("  <thead><tr>")
for col in header_content.split('\t'):
    lines.append(f"    <th>{col}</th>")
lines.append("  </tr></thead>")

for row in body_content:
    lines.append('  <tr>')
    for col in row.split('\t'):
        lines.append(f"    <td>{col}</td>")
    lines.append('  </tr>')
lines.append("</table>")
lines.append("</main>")

print("\n".join(lines))
