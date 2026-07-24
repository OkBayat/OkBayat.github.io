#!/usr/bin/env python3
"""Generate the downloadable CV PDF from docs/about/cv.md."""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    KeepTogether,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
)

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "docs/about/cv.md"
DEFAULT_OUTPUT = ROOT / "assets/downloads/mohammad-bayat-cv.pdf"
SITE_URL = "https://www.okbayat.com"

ACCENT = colors.HexColor("#5B43D6")
TEXT = colors.HexColor("#22242A")
MUTED = colors.HexColor("#5E6470")
RULE = colors.HexColor("#D9DCE3")
FONT_DIRECTORY = Path("/usr/share/fonts/truetype/dejavu")
FONT_REGULAR = FONT_DIRECTORY / "DejaVuSans.ttf"
FONT_BOLD = FONT_DIRECTORY / "DejaVuSans-Bold.ttf"


def register_fonts() -> None:
    if not FONT_REGULAR.exists() or not FONT_BOLD.exists():
        raise FileNotFoundError(
            "DejaVu Sans is required to generate a portable CV PDF"
        )
    pdfmetrics.registerFont(TTFont("CVSans", FONT_REGULAR))
    pdfmetrics.registerFont(TTFont("CVSans-Bold", FONT_BOLD))
    pdfmetrics.registerFontFamily(
        "CVSans",
        normal="CVSans",
        bold="CVSans-Bold",
        italic="CVSans",
        boldItalic="CVSans-Bold",
    )


def normalize_text(value: str) -> str:
    replacements = {
        "\u2010": "-",
        "\u2011": "-",
        "\u2012": "-",
        "\u2013": "-",
        "\u2014": "-",
        "\u2212": "-",
        "\u00b7": "|",
        "\u2018": "'",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
    }
    for old, new in replacements.items():
        value = value.replace(old, new)
    return value


def absolute_url(value: str) -> str:
    if value.startswith("/"):
        return f"{SITE_URL}{value}"
    return value


def emphasis_markup(value: str) -> str:
    escaped = html.escape(normalize_text(value), quote=False)
    return re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", escaped)


def inline_markup(value: str) -> str:
    value = normalize_text(value)
    parts: list[str] = []
    cursor = 0
    link_pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")

    for match in link_pattern.finditer(value):
        parts.append(emphasis_markup(value[cursor : match.start()]))
        label = emphasis_markup(match.group(1))
        target = html.escape(absolute_url(match.group(2)), quote=True)
        parts.append(f'<link href="{target}" color="#5B43D6">{label}</link>')
        cursor = match.end()

    parts.append(emphasis_markup(value[cursor:]))
    return "".join(parts)


def source_body(source: str) -> str:
    front_matter = re.match(r"^---\s*\n[\s\S]*?\n---\s*\n", source)
    return source[front_matter.end() :] if front_matter else source


def extract_header(body: str) -> tuple[str, str]:
    title_match = re.search(r"^#\s+(.+)$", body, flags=re.MULTILINE)
    title = normalize_text(title_match.group(1)) if title_match else "Mohammad Bayat"

    tagline = "Founder, Software Engineer, and Leadership Facilitator"
    if title_match:
        for raw_line in body[title_match.end() :].splitlines():
            line = raw_line.strip()
            if not line or line.startswith(("{:", "{", "<", "#", "---")):
                continue
            tagline = normalize_text(line)
            break

    return title, tagline


def content_blocks(body: str) -> list[tuple[str, str]]:
    start = body.find("## Professional Profile")
    end = body.find("## Download PDF")
    if start == -1 or end == -1 or end <= start:
        raise ValueError("CV source is missing its required section boundaries")

    lines = body[start:end].splitlines()
    blocks: list[tuple[str, str]] = []
    paragraph_lines: list[str] = []

    def flush_paragraph() -> None:
        if paragraph_lines:
            blocks.append(("paragraph", " ".join(paragraph_lines)))
            paragraph_lines.clear()

    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            flush_paragraph()
            continue
        if line.startswith("{:"):
            continue
        if line.startswith("## "):
            flush_paragraph()
            blocks.append(("section", line[3:]))
        elif line.startswith("### "):
            flush_paragraph()
            blocks.append(("entry", line[4:]))
        elif line.startswith("- "):
            flush_paragraph()
            blocks.append(("bullet", line[2:]))
        elif line.startswith("**") and line.endswith("**"):
            flush_paragraph()
            blocks.append(("meta", line[2:-2]))
        elif line.startswith("<"):
            flush_paragraph()
        else:
            paragraph_lines.append(line)

    flush_paragraph()
    return blocks


def paragraph_styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "name": ParagraphStyle(
            "CVName",
            parent=base["Title"],
            fontName="CVSans-Bold",
            fontSize=22,
            leading=24,
            textColor=TEXT,
            alignment=TA_LEFT,
            spaceAfter=3,
        ),
        "tagline": ParagraphStyle(
            "CVTagline",
            parent=base["Normal"],
            fontName="CVSans",
            fontSize=10.5,
            leading=13,
            textColor=ACCENT,
            spaceAfter=4,
        ),
        "identity": ParagraphStyle(
            "CVIdentity",
            parent=base["Normal"],
            fontName="CVSans",
            fontSize=8.3,
            leading=10,
            textColor=MUTED,
            spaceAfter=7,
        ),
        "section": ParagraphStyle(
            "CVSection",
            parent=base["Heading2"],
            fontName="CVSans-Bold",
            fontSize=11.3,
            leading=13,
            textColor=ACCENT,
            borderColor=RULE,
            borderWidth=0,
            borderPadding=(0, 0, 2, 0),
            spaceBefore=9,
            spaceAfter=4,
            keepWithNext=True,
        ),
        "entry": ParagraphStyle(
            "CVEntry",
            parent=base["Heading3"],
            fontName="CVSans-Bold",
            fontSize=9.4,
            leading=11.2,
            textColor=TEXT,
            spaceBefore=4.5,
            spaceAfter=1,
            keepWithNext=True,
        ),
        "meta": ParagraphStyle(
            "CVMeta",
            parent=base["Normal"],
            fontName="CVSans",
            fontSize=7.8,
            leading=9.5,
            textColor=MUTED,
            spaceAfter=2,
            keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "CVBody",
            parent=base["BodyText"],
            fontName="CVSans",
            fontSize=8.2,
            leading=10.6,
            textColor=TEXT,
            spaceAfter=3,
        ),
        "bullet": ParagraphStyle(
            "CVBullet",
            parent=base["BodyText"],
            fontName="CVSans",
            fontSize=8.1,
            leading=10.4,
            leftIndent=10,
            firstLineIndent=-6,
            bulletIndent=2,
            textColor=TEXT,
            spaceAfter=1.7,
        ),
    }


def footer(canvas, doc) -> None:
    canvas.saveState()
    width, _ = A4
    canvas.setStrokeColor(RULE)
    canvas.setLineWidth(0.4)
    canvas.line(17 * mm, 13 * mm, width - 17 * mm, 13 * mm)
    canvas.setFont("CVSans", 7)
    canvas.setFillColor(MUTED)
    canvas.drawString(
        17 * mm,
        8.5 * mm,
        "Mohammad Bayat | Curriculum Vitae | July 2026",
    )
    canvas.drawRightString(width - 17 * mm, 8.5 * mm, f"Page {doc.page}")
    canvas.restoreState()


def build_pdf(source_path: Path, output_path: Path) -> None:
    register_fonts()
    source = source_path.read_text(encoding="utf-8")
    body = source_body(source)
    name, tagline = extract_header(body)
    blocks = content_blocks(body)
    styles = paragraph_styles()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    document = SimpleDocTemplate(
        str(output_path),
        pagesize=A4,
        rightMargin=17 * mm,
        leftMargin=17 * mm,
        topMargin=14 * mm,
        bottomMargin=17 * mm,
        title=f"{name} - Curriculum Vitae",
        author=name,
        subject="Professional curriculum vitae",
        creator="okbayat.com CV generator",
        pageCompression=1,
        invariant=1,
    )

    story = [
        Paragraph(html.escape(name), styles["name"]),
        Paragraph(html.escape(tagline), styles["tagline"]),
        Paragraph(
            '<link href="mailto:me@OkBayat.com" color="#5B43D6">me@OkBayat.com</link>'
            '  |  <link href="https://www.okbayat.com" color="#5B43D6">'
            "www.okbayat.com</link>"
            '  |  <link href="https://www.linkedin.com/in/okbayat/" '
            'color="#5B43D6">linkedin.com/in/okbayat</link>',
            styles["identity"],
        ),
        Spacer(1, 2),
    ]

    pending_entry: list = []

    def flush_entry() -> None:
        if pending_entry:
            story.append(KeepTogether(list(pending_entry)))
            pending_entry.clear()

    for kind, value in blocks:
        markup = inline_markup(value)
        if kind == "section":
            flush_entry()
            if value == "Selected Writing and Research-Related Work":
                story.append(PageBreak())
            story.append(Paragraph(markup, styles["section"]))
        elif kind == "entry":
            flush_entry()
            pending_entry.append(Paragraph(markup, styles["entry"]))
        elif kind == "meta":
            pending_entry.append(Paragraph(markup, styles["meta"]))
        elif kind == "bullet":
            bullet = Paragraph(markup, styles["bullet"], bulletText="\u2022")
            if pending_entry:
                pending_entry.append(bullet)
                flush_entry()
            else:
                story.append(bullet)
        else:
            paragraph = Paragraph(markup, styles["body"])
            if pending_entry:
                pending_entry.append(paragraph)
                flush_entry()
            else:
                story.append(paragraph)

    flush_entry()
    document.build(story, onFirstPage=footer, onLaterPages=footer)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    build_pdf(args.source.resolve(), args.output.resolve())
    print(f"Generated {args.output}")


if __name__ == "__main__":
    main()
