#!/usr/bin/env python3
"""Extract selected XLSX sheets to plain CSV files.

The input manifest is a CSV with these required columns:

    workbook,sheet,out_csv

Paths are resolved relative to the repository directory unless absolute paths
are supplied. Formula cells are exported as the cached values stored in the
workbook. Formatting, formulas, charts, merged-cell semantics, and styles are
not preserved.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from posixpath import normpath
from typing import Iterable
from xml.etree import ElementTree as ET
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]

NS = {
    "a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
}


def column_number(cell_ref: str) -> int:
    letters = "".join(ch for ch in cell_ref if ch.isalpha())
    n = 0
    for ch in letters:
        n = n * 26 + ord(ch.upper()) - 64
    return n


def row_number(cell_ref: str, fallback: int) -> int:
    digits = "".join(ch for ch in cell_ref if ch.isdigit())
    return int(digits) if digits else fallback


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def shared_strings(zf: ZipFile) -> list[str]:
    if "xl/sharedStrings.xml" not in zf.namelist():
        return []
    root = ET.fromstring(zf.read("xl/sharedStrings.xml"))
    return ["".join(t.text or "" for t in si.findall(".//a:t", NS)) for si in root.findall("a:si", NS)]


def workbook_sheet_map(zf: ZipFile) -> dict[str, str]:
    workbook = ET.fromstring(zf.read("xl/workbook.xml"))
    rels = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
    relmap = {rel.attrib["Id"]: rel.attrib["Target"] for rel in rels}

    sheet_map: dict[str, str] = {}
    sheets = workbook.find("a:sheets", NS)
    if sheets is None:
        return sheet_map

    for sheet in sheets:
        rid = sheet.attrib[f"{{{NS['r']}}}id"]
        target = relmap[rid]
        if not target.startswith("/"):
            target = "xl/" + target
        target = normpath(target.lstrip("/"))
        sheet_map[sheet.attrib["name"]] = target
    return sheet_map


def sheet_names(xlsx_path: Path) -> list[str]:
    with ZipFile(xlsx_path) as zf:
        return list(workbook_sheet_map(zf))


def cell_value(cell: ET.Element, strings: list[str]) -> str:
    cell_type = cell.attrib.get("t")
    value_node = cell.find("a:v", NS)

    if cell_type == "s" and value_node is not None:
        return strings[int(value_node.text or "0")]
    if cell_type == "inlineStr":
        return "".join(t.text or "" for t in cell.findall(".//a:t", NS))
    if value_node is not None:
        return value_node.text or ""
    return ""


def sheet_rows(xlsx_path: Path, sheet_name: str) -> list[list[str]]:
    with ZipFile(xlsx_path) as zf:
        strings = shared_strings(zf)
        sheets = workbook_sheet_map(zf)
        if sheet_name not in sheets:
            available = ", ".join(sheets)
            raise ValueError(f"Sheet {sheet_name!r} not found in {xlsx_path}. Available: {available}")

        root = ET.fromstring(zf.read(sheets[sheet_name]))
        sparse_rows: dict[int, dict[int, str]] = {}
        max_row = 0
        max_col = 0

        for row_i, row in enumerate(root.findall(".//a:sheetData/a:row", NS), start=1):
            cells: dict[int, str] = {}
            logical_row = int(row.attrib.get("r", row_i))
            for cell in row.findall("a:c", NS):
                ref = cell.attrib.get("r", f"A{logical_row}")
                col = column_number(ref)
                logical_row = row_number(ref, logical_row)
                cells[col] = cell_value(cell, strings)
                max_col = max(max_col, col)
            if cells:
                sparse_rows[logical_row] = cells
                max_row = max(max_row, logical_row)

        return [[sparse_rows.get(r, {}).get(c, "") for c in range(1, max_col + 1)] for r in range(1, max_row + 1)]


def write_sheet_csv(xlsx_path: Path, sheet_name: str, out_path: Path) -> tuple[int, int]:
    rows = sheet_rows(xlsx_path, sheet_name)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerows(rows)
    return len(rows), max((len(row) for row in rows), default=0)


def read_manifest(path: Path) -> Iterable[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required = {"workbook", "sheet", "out_csv"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path} is missing required columns: {', '.join(sorted(missing))}")
        yield from reader


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest",
        default="manifests/xlsx_sheet_exports.csv",
        help="CSV file with workbook,sheet,out_csv columns.",
    )
    parser.add_argument(
        "--root",
        default=str(ROOT),
        help="Base directory for relative paths in the manifest.",
    )
    parser.add_argument(
        "--list-sheets",
        metavar="XLSX",
        help="List sheet names in one workbook and exit.",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if args.list_sheets:
        for name in sheet_names(resolve_path(root, args.list_sheets)):
            print(name)
        return

    manifest = resolve_path(root, args.manifest)
    for entry in read_manifest(manifest):
        workbook = resolve_path(root, entry["workbook"])
        out_csv = resolve_path(root, entry["out_csv"])
        sheet = entry["sheet"]
        row_count, col_count = write_sheet_csv(workbook, sheet, out_csv)
        print(f"{workbook.name}: {sheet!r} -> {out_csv.relative_to(root)} ({row_count} rows, {col_count} cols)")


if __name__ == "__main__":
    main()
