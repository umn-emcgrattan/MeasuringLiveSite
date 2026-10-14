"""Convert BEA's cached detailed-use XLSX sheets to plain source CSV files.

This intentionally performs no economic classification or aggregation. It is
the generic source-extraction step used because Julia's standard library does
not include an XLSX reader.
"""
from __future__ import annotations

import csv
import re
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

MAIN = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
NS = {"m": MAIN, "r": REL}
YEARS = ("2007", "2012", "2017")


def column_number(cell_reference: str) -> int:
    letters = re.match(r"[A-Z]+", cell_reference).group(0)
    value = 0
    for letter in letters:
        value = value * 26 + ord(letter) - 64
    return value


def main(workbook_name: str, output_directory: str) -> None:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(workbook_name) as book:
        shared_root = ET.fromstring(book.read("xl/sharedStrings.xml"))
        shared = [
            "".join(node.text or "" for node in item.findall(".//m:t", NS))
            for item in shared_root.findall("m:si", NS)
        ]
        workbook = ET.fromstring(book.read("xl/workbook.xml"))
        rel_root = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
        relationships = {node.attrib["Id"]: node.attrib["Target"] for node in rel_root}

        for sheet in workbook.find("m:sheets", NS):
            year = sheet.attrib["name"]
            if year not in YEARS:
                continue
            target = relationships[sheet.attrib[f"{{{REL}}}id"]]
            target = target if target.startswith("xl/") else "xl/" + target.lstrip("/")
            root = ET.fromstring(book.read(target))
            rows = {}
            for row in root.findall(".//m:sheetData/m:row", NS):
                values = {}
                for cell in row.findall("m:c", NS):
                    raw = cell.find("m:v", NS)
                    value = "" if raw is None else (raw.text or "")
                    if cell.attrib.get("t") == "s" and value:
                        value = shared[int(value)]
                    values[column_number(cell.attrib["r"])] = value
                rows[int(row.attrib["r"])] = values

            descriptions, codes = rows[5], rows[6]
            final_column = max(k for k, value in codes.items() if value == "T019")
            commodity_rows = [
                row for number, row in sorted(rows.items())
                if 7 <= number and row.get(1, "")
            ]
            path = output / f"use_detail_{year}.csv"
            with path.open("w", newline="", encoding="utf-8") as stream:
                writer = csv.writer(stream)
                writer.writerow(["RowCode", "RowDescription"] +
                                [codes.get(col, "") for col in range(3, final_column + 1)])
                writer.writerow(["", "ColumnDescription"] +
                                [descriptions.get(col, "") for col in range(3, final_column + 1)])
                for row in commodity_rows:
                    writer.writerow([row.get(1, ""), row.get(2, "")] +
                                    [row.get(col, "") for col in range(3, final_column + 1)])
            print(f"Wrote {path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: extract_bea_benchmark_xlsx.py WORKBOOK OUTPUT_DIRECTORY")
    main(sys.argv[1], sys.argv[2])

