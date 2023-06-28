# Minimal makefile for Sphinx documentation
#

# check that requirements are fulfilled
requirements_warnings := $(shell pip freeze -r requirements.txt 2>&1 >/dev/null | grep WARNING)
ifneq ($(requirements_warnings), )
$(info $(requirements_warnings))
$(info Requirements can be installed with pip:)
$(info $$ pip install -r $(shell readlink -f requirements.txt))
$(error Missing python packages for building the documentation.)
endif

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
