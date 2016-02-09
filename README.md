# Chopin

Generate a static web site using a combination of ERb templates, Markdown, and SASS/SCSS.

## Installation

    gem install chopin

## How to use

    chopin <source-directory> <destination-directory>

There are six rules to determine what Chopin does with each file in the source directory:

1. A file beginning with `.` is ignored.
2. A file named `layout.erb` is used as a template for sibling and child directories.
3. Any `.erb` or `.md` file is parsed and rendered inside the closest `layout.erb` template, within `<%= yield %>`.
4. Any `.sass` or `.scss` file that does *not* begin with `_` is converted into CSS
5. A directory is copied over to the destination, then its contents are parsed recursively.
6. Any other file is copied over as-is.
