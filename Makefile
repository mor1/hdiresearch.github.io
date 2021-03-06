# Copyright (C) 2012 Richard Mortier <mort@cantab.net>.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
# USA.

.PHONY: site clean css test

PORT ?= 8080

help: # list targets
	@egrep "^\S+:" Makefile \
	  | grep -v "^.PHONY" \
	  | awk -F"\s*#\s*" '{ if (length($2) != 0) printf("%s\n--%s\n", $$1, $$2) }'

DOCKER = docker run -ti -v $$(pwd -P):/cwd -w /cwd
JEKYLL = $(DOCKER) mor1/jekyll
JEKYLLS= $(DOCKER) -p $(PORT):$(PORT) mor1/jekyll
LESSC  = $(DOCKER) mor1/alpine-lessc \
  --clean-css="--s1 --advanced --compatibility=ie8"

LESSES = $(filter-out _less/variables.less,$(wildcard _less/*.less))
CSSES  = $(patsubst _less/%.less,css/%.css,$(LESSES))

site: css # build the site
	$(JEKYLL) build --trace

clean: # remove all generated outputs
	$(RM) -r _site
	$(RM) $(CSSES)

css: $(CSSES) # build the site's CSS
css/%.css: _less/%.less
	$(LESSC) $< >| $@

test: css js # run the site at http://localhost
	$(JEKYLLS) serve -H 0.0.0.0 -P $(PORT) --watch --trace --incremental
