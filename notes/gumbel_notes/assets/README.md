# Assets Directory

This directory contains all templates, styles, and resources for your research diary system, including both LaTeX and HTML components with seamless integration.

## Directory Structure

```
assets/
├── styles/                     # LaTeX style files (.sty)
│   ├── diary_base.sty         # Essential diary functionality
│   ├── diary_commands.sty     # 100+ custom LaTeX commands
│   ├── diary_ctheorems.sty    # Enhanced colored theorem environments
│   └── natbibspacing.sty      # Bibliography spacing
├── templates/                  # LaTeX templates
│   ├── collection/             # Templates for compiling full diary
│   │   └── collection_template.tex
│   └── entries/               # Templates for daily entries
│       └── entry_template.tex # Modern template with placeholders
├── html_templates/             # HTML blog templates ✨ NEW!
│   ├── index_template.html    # Blog index structure
│   ├── entry_template.html    # Individual post structure
│   ├── blog_post.css          # Enhanced LaTeX-style post CSS
│   ├── blog_post_simple.css   # Clean minimal post CSS
│   ├── blog_index.css         # Modern grid blog index CSS
│   └── blog_index_compact.css # Minimalist table-of-contents CSS
├── bib/                       # Bibliography files
│   ├── reference.bib          # Primary research references
│   └── reference2.bib         # Additional references
├── figures/                   # Research figures and images
│   ├── 2025/                  # Year-organized figures
│   └── shared/                # Shared figures across entries
└── minimum_html_templates/    # Fallback HTML templates
```

## Customization

### LaTeX Style Files (`styles/`)
- **diary_base.sty**: Core diary functionality (headers, footers, basic packages)
- **diary_commands.sty**: 100+ custom LaTeX commands (\argmax, \KL, \E, etc.)
- **diary_ctheorems.sty**: Enhanced colored theorem environments
- **natbibspacing.sty**: Bibliography formatting

### LaTeX Templates (`templates/`)
- **entry_template.tex**: Template for daily entries with `<VARIABLE>` placeholders
- **collection_template.tex**: Template for compiling entries (showlabels disabled)

### HTML Templates (`html_templates/`) ✨ NEW!
- **index_template.html**: Customizable blog index structure with Mustache templating
- **entry_template.html**: Individual blog post structure
- **blog_*.css**: Multiple CSS themes (enhanced, simple, compact layouts)

### Bibliography (`bib/`)
- **reference.bib**: Primary research references in BibTeX format
- **reference2.bib**: Additional references for extended bibliography

### Figures (`figures/`)
- **Year folders**: Organized by year (2024/, 2025/, etc.)
- **shared/**: Figures used across multiple entries

## Editing Templates

Templates use `<VARIABLE>` syntax for placeholders:
- `<YEAR>`: Current year
- `<AUTHOR>`: Your name
- `<INSTITUTION>`: Your institution
- `<MONTH_NAME>`: Full month name (e.g., "September")
- `<DAY>`: Day of month
- `<FILENAME>`: Name of the file

## Adding References

Add references to `bibliography/reference.bib`:

```bibtex
@article{author2025,
  title={Your Paper Title},
  author={Author, Name},
  journal={Journal Name},
  year={2025}
}
```

Then cite in your entries with `\cite{author2025}`.

## Custom Commands

Add frequently used commands to `commands/my_newcommands.tex`:

```latex
\newcommand{\todo}[1]{\textcolor{red}{\textbf{TODO: #1}}}
\newcommand{\important}[1]{\textcolor{blue}{\textbf{#1}}}
```

## Recent Enhancements ✨

### LaTeX Command Integration
- **100+ Commands**: All LaTeX commands now work perfectly in HTML blogs
- **Seamless Conversion**: \argmax, \KL, \E, \dd, \blue{}, \vv{} automatically converted
- **MathJax Integration**: Complex mathematical notation renders correctly
- **Nested Braces**: Fixed parsing of complex definitions like \mathrm{med}

### Chronological Sorting
- **Creation Time**: Entries sorted by file creation time, not filename
- **Intuitive Order**: Same-day entries appear in the order they were created
- **Consistent Behavior**: Works for both year and tag-based compilations

### Minimalist Design
- **Grey Aesthetic**: Professional grey color palette (#6c757d, #495057)
- **Clean Typography**: Reduced font weights and subtle borders
- **Academic Focus**: Optimized for research content readability
- **Responsive Layout**: Works beautifully on all devices

All files in this directory are automatically linked into compilation directories, so your customizations will be available in all diary entries and compilations.
