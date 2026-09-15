#!/usr/bin/env python3
"""Apply the reviewed, narrowly scoped Vocora copy updates one stage at a time."""
from pathlib import Path
import sys


def replace(path, old, new):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if text.count(old) != 1:
        raise ValueError(f"{path}: expected exactly one match for {old[:70]!r}")
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def between(path, start, end, new):
    text = Path(path).read_text(encoding="utf-8")
    if text.count(start) != 1 or text.count(end) != 1:
        raise ValueError(f"{path}: ambiguous section boundaries")
    left, right = text.index(start), text.index(end)
    if right <= left:
        raise ValueError(f"{path}: reversed section boundaries")
    replace(path, text[left:right], new)


def supporting():
    replace("docs/research/publications-en.md",
            "Vocora is a bounded software project within this wider inquiry. Its project-specific writing is collected in",
            "Some of this writing informs the learning principles and product decisions behind Vocora, my language-learning startup focused on English learning and IELTS preparation. Related reading is collected in")
    replace("docs/research/publications-fa.md",
            "Vocora پروژه‌ای نرم‌افزاری با دامنه‌ی مشخص در دل این پرسش گسترده‌تر است. نوشته‌های اختصاصی آن در",
            "بخشی از این نوشته‌ها به اصول یادگیری و تصمیم‌های طراحی در Vocora، استارت‌آپ من برای یادگیری زبان انگلیسی و آمادگی IELTS، مرتبط‌اند. نوشته‌های مرتبط در")
    replace("docs/writing/all-writing-en.md",
            "[Vocora](/work/projects/vocora) — an open-source research-and-building project about learning, memory, language practice, and learning technology.",
            "[Vocora](/work/projects/vocora) — my language-learning startup, focused on English learning and IELTS preparation.")
    replace("docs/writing/all-writing-fa.md",
            "[Vocora](/work/projects/vocora) — پروژه‌ای متن‌باز درباره‌ی یادگیری، حافظه، تمرین زبان و فناوری یادگیری.",
            "[Vocora](/work/projects/vocora) — استارت‌آپ من برای یادگیری زبان انگلیسی و آمادگی IELTS.")
    replace("docs/projects/project-records.md",
            "because they are ongoing bodies of work rather than individual bounded projects.",
            "as the businesses I am building, rather than individual bounded projects.")
    replace("docs/leadership-learning/human-transformation/index.md",
            "and developing software such as [Vocora](/work/projects/vocora).",
            "and building [Vocora](/work/projects/vocora), my language-learning startup focused on English learning and IELTS preparation. These experiences inform the inquiry; the startup has its own product and business identity.")
    replace("docs/projects/vocora/publications.md",
            "A curated index of research notes, translations, reading, and project documentation connected to Vocora.",
            "Research notes, translations, and reading that inform the learning principles and product decisions behind the Vocora startup.")
    replace("docs/projects/vocora/publications.md",
            "This page collects work related to Vocora.",
            "This page collects reading and design notes that inform Vocora, my language-learning startup focused on English learning and IELTS preparation.")
    replace("docs/projects/vocora/publications.md",
            "the item informs the project;", "the item informs the product;")
    text = Path("docs/projects/vocora/publications.md").read_text(encoding="utf-8")
    old = text[text.index("## Project Documentation"):]
    replace("docs/projects/vocora/publications.md", old,
            "## Product\n\n[Vocora overview](/work/projects/vocora) · [Visit Vocora](https://vocora.ir)\n")
    replace("_data/publications.yml",
            "Reviews what retrieval practice can support, what it does not prove, and how the mechanism is currently used in Vocora.",
            "Reviews what retrieval practice can support, what it does not prove, and how it informs vocabulary review in Vocora.")
    replace("_data/publications.yml",
            "Distinguishes the general spacing effect from the practical but not yet optimized schedule used by Vocora.",
            "Distinguishes general spacing evidence from the design choices and limitations of Leitner-style vocabulary review in Vocora.")
    replace("_data/publications_fa.yml",
            "بررسی می‌کند تمرین بازیابی از چه چیزهایی پشتیبانی می‌کند، چه چیزی را اثبات نمی‌کند و این سازوکار اکنون چگونه در Vocora به کار می‌رود.",
            "بررسی می‌کند تمرین بازیابی از چه چیزهایی پشتیبانی می‌کند، چه چیزی را اثبات نمی‌کند و چگونه به طراحی مرور واژگان در Vocora کمک می‌کند.")
    replace("_data/publications_fa.yml",
            "اثر عمومی فاصله‌گذاری را از برنامه‌ی عملی فعلی Vocora که هنوز بهینه نشده است متمایز می‌کند.",
            "شواهد عمومی فاصله‌گذاری را از تصمیم‌های طراحی و محدودیت‌های مرور واژگان به روش لایتنر در Vocora متمایز می‌کند.")
    between("_data/publications.yml", "  - id: ethical-gamification\n", "  - id: hebbs-rule\n", "")
    p = "_data/publications_fa.yml"
    line = next(line for line in Path(p).read_text(encoding="utf-8").splitlines(True) if line.startswith("  ethical-gamification:"))
    replace(p, line, "")
    Path("docs/research/notes/ethical-gamification.md").unlink()
    p = "docs/research/notes/vocora-learning-metrics.md"
    replace(p, "sessions, answers, time, streaks, completed reviews", "sessions, answers, time, completed reviews")
    replace(p, "- words encountered or retrieved;\n- selected weekly goal completion.", "- words encountered or retrieved.")
    replace(p, "## Current Vocora Metrics\n\nThe current application can calculate several honest product measures:",
            "## Interpreting Product Metrics\n\nThe following examples show how practice measures should be labelled. They are design guidance, not a list of features available in the current release:")
    replace(p, "| Current streak | Consecutive active days | Motivation, well-being, or learning quality |\n", "")
    between(p, "## Guardrails\n", "## What Needs to Be Added\n",
            "## Measurement Boundaries\n\nPractice measures should refer to recorded answers, not merely opening the application. Low accuracy or a small sample should not become a claim about a learner's lasting ability. Any learning analysis should use only the data it needs and distinguish performance from retention.\n\n")
    replace(p, "- [Vocora Gamification and Sharing Principles](https://github.com/OkBayat/vocora/blob/main/docs/GAMIFICATION.md).\n", "")
    replace(p, "- Ryan, R. M., & Deci, E. L. (2020). [Intrinsic and Extrinsic Motivation from a Self-Determination Theory Perspective](https://doi.org/10.1016/j.cedpsych.2020.101860). *Contemporary Educational Psychology, 61*, 101860.\n", "")
    for path in [p, "docs/research/notes/retrieval-practice.md", "docs/research/notes/spaced-practice-and-leitner.md"]:
        replace(path, "last_modified_date: 2026-07-17", "last_modified_date: 2026-09-15\ndate_modified: 2026-09-15\nseo:\n  type: Article")
        replace(path, "> **Last revised:** July 17, 2026", "> **Last revised:** September 15, 2026")
        replace(path, "## The Question\n",
                "This note discusses the vocabulary-review design documented in July 2026, not the full current product. For the startup's current direction, see [Vocora](/work/projects/vocora).\n\n<details open markdown=\"block\">\n  <summary>Table of contents</summary>\n  {: .text-delta }\n1. TOC\n{:toc}\n</details>\n\n## The Question\n")
        replace(path, "## Revision History\n", "## Revision History\n\n- **September 15, 2026:** Clarified the scope of the earlier product examples and linked to the current startup overview.\n")


def editorial():
    replace("README.md", "agent systems, K2Quant, company-building", "agent systems, K2Quant, Vocora, language-learning products, company-building")
    replace("README.md", "- **K2Quant** is the main company-building and quantitative-systems work.\n- **Vocora** is an independent research-and-building project about learning, memory, language practice, and learning technology.",
            "- **K2Quant** is Mohammad's quantitative-technology business.\n- **Vocora** is Mohammad's language-learning startup, focused on English learning and IELTS preparation. It is a proprietary product, not a public source-code contribution project.\n\nPresent both under **Companies & Startups** in Projects and include both founding roles in professional profiles. Research informs Vocora's design; it is not the startup's primary identity. Keep the overview short and product-focused, without a product tour or unsupported growth and IELTS-score claims.")
    replace("README.md", "- `/work/projects/vocora` — project overview and current state;", "- `/work/projects/vocora` — startup overview, product direction, founder's role, and application link;")
    replace("README.md", "- `/work/projects/vocora/publications` — curated project index;", "- `/work/projects/vocora/publications` — public reading and design notes that support the product;")
    replace("_config.yml", 'description: "Mohammad Bayat — building quantitative systems and studying human learning and transformation."',
            'description: "Mohammad Bayat — founder of K2Quant and Vocora, building quantitative technology and language-learning products."')
    replace("_includes/footer_custom.html", "Building quantitative systems and organizations; studying human learning and transformation.",
            "Building K2Quant and Vocora; exploring human learning and transformation.")


def profiles():
    p = "docs/about/resume.md"
    replace(p, 'description: "Selected professional experience, quantitative systems work, social-impact projects, human transformation inquiry, leadership practice, and independent projects by Mohammad Bayat."',
            'description: "Mohammad Bayat’s experience as founder of K2Quant and Vocora, alongside software engineering, leadership practice, facilitation, and social-impact work."')
    replace(p, "last_modified_date: 2026-07-24", "last_modified_date: 2026-09-15")
    replace(p, "My practice-based inquiry focuses on human learning, reflective practice, leadership, and durable change. My current work is centered on [K2Quant](/work/projects/k2quant) and [Human Transformation](/work/leadership-learning/human-transformation), including [Learning Circle](/work/leadership-learning/human-transformation/field-projects/learning-circle), facilitated programs, leadership and organizational practice, and [Vocora](/work/projects/vocora).",
            "I am the founder of [K2Quant](/work/projects/k2quant) and [Vocora](/work/projects/vocora), building businesses in quantitative technology and language learning. Alongside this work, my [Human Transformation](/work/leadership-learning/human-transformation) inquiry focuses on reflective practice, leadership, and durable change through [Learning Circle](/work/leadership-learning/human-transformation/field-projects/learning-circle), facilitated programs, and organizational practice.")
    between(p, "### Vocora\n", "---\n\n## Experience\n", "")
    replace(p, "### Gruccia\n", """### Vocora

**Active**

#### Founder and Software Engineer

My language-learning startup, focused on English learning and IELTS preparation. Vocora has developed beyond its initial vocabulary-practice application into a broader self-study product.

- Lead product direction, software development, and learning-experience design.
- Connect lessons, language practice, and review in a structured self-study experience.
- Use learning research to inform product decisions without promising a particular IELTS score or claiming validated learning outcomes.

Vocora is developed as a proprietary product.

[Startup overview](/work/projects/vocora) · [Visit Vocora](https://vocora.ir)

---

### Gruccia
""")
    p = "docs/about/cv.md"
    replace(p, 'description: "Professional CV for Mohammad Bayat, covering education, coaching credentials, selected experience, leadership and facilitation, projects, independent research-related work, technical skills, and languages."',
            'description: "Professional CV for Mohammad Bayat, founder of K2Quant and Vocora, covering software engineering, leadership, facilitation, education, and selected writing."')
    replace(p, "last_modified_date: 2026-07-24", "last_modified_date: 2026-09-15")
    replace(p, "Last updated July 24, 2026", "Last updated September 15, 2026")
    replace(p, "Founded and continues to build [K2Quant](/work/projects/k2quant), combining software engineering, artificial intelligence, quantitative systems, technical operations, and company-building.",
            "Founder of [K2Quant](/work/projects/k2quant) and [Vocora](/work/projects/vocora), building businesses in quantitative technology and language learning, with Vocora focused on English learning and IELTS preparation.")
    replace(p, "### Radin Bourse — Full-Stack Developer\n", """### Vocora — Founder and Software Engineer

**Active**
{: .cv-entry-meta }

- Lead product direction, software development, and learning-experience design for a language-learning startup focused on English learning and IELTS preparation.
- Develop a structured self-study product connecting lessons, language practice, and review.

### Radin Bourse — Full-Stack Developer
""")
    replace(p, "An open-source research-and-building project that turns questions about vocabulary learning, memory, retrieval, feedback, motivation, and measurement into working software.",
            "A proprietary language-learning product focused on English learning and IELTS preparation, developed beyond its initial vocabulary-practice application.")
    p = "scripts/generate_cv_pdf.py"
    replace(p, "import re\nfrom pathlib", "import re\nfrom datetime import date\nfrom pathlib")
    replace(p, '"Mohammad Bayat | Curriculum Vitae | July 2026",', 'f"Mohammad Bayat | Curriculum Vitae | {doc.revision_label}",')
    replace(p, '    body = source_body(source)\n', '''    revision = re.search(r"^last_modified_date: (\\d{4}-\\d{2}-\\d{2})$", source, re.MULTILINE)
    if revision is None:
        raise ValueError("CV source is missing last_modified_date")
    revision_label = date.fromisoformat(revision.group(1)).strftime("%B %Y")
    body = source_body(source)
''')
    replace(p, '    story = [\n', '    document.revision_label = revision_label\n\n    story = [\n')


def guards():
    p = "scripts/validate_content_architecture.js"
    needle = 'const footer = fs.readFileSync(\n'
    content = r'''// Keep the startup identity and public links consistent across current pages.
for (const page of pages) {
  if (/https:\/\/github\.com\/OkBayat\/vocora(?:[\s/\)"#]|$)/i.test(page.body)) {
    errors.add(`${page.file}: link to the Vocora application, not its private source`)
  }
  for (const paragraph of page.body.split(/\n\s*\n/)) {
    if (
      /vocora/i.test(paragraph) &&
      /open[ -]source|research-and-building|متن[‌ -]باز/i.test(paragraph)
    ) {
      errors.add(`${page.file}: stale Vocora positioning`)
    }
  }
}

const vocora = pagesByFile.get("docs/projects/vocora/index.md")
if (
  !vocora ||
  !/language-learning startup/i.test(vocora.body) ||
  !/IELTS/.test(vocora.body) ||
  !/https:\/\/vocora\.ir/.test(vocora.body)
) {
  errors.add("Vocora must be introduced as an IELTS-focused startup with an app link")
}

for (const [file, section, nextSection] of [
  ["docs/about/cv.md", "Selected Professional Experience", "Leadership and Facilitation Experience"],
  ["docs/about/resume.md", "Experience", "Education"],
]) {
  const body = pagesByFile.get(file)?.body || ""
  const experience = body.split(`## ${section}\n`)[1]?.split(`## ${nextSection}\n`)[0] || ""
  if (!/### Vocora(?: — Founder|\n[\s\S]*?#### Founder)/.test(experience)) {
    errors.add(`${file}: Vocora founding role must appear in professional experience`)
  }
}

'''
    replace(p, needle, content + needle)


if __name__ == "__main__":
    stages = {"supporting": supporting, "editorial": editorial, "profiles": profiles, "guards": guards}
    stages[sys.argv[1]]()
