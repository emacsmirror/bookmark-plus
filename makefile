APP_NAME ?=	$(shell grep package-file Cask | sed 's/.*\"\(.*\)\.el.*/\1/')
EMACS ?=	emacs
CASK ?=		cask
LISP_DIR=	.
DOC_DIR=	doc
ELPA_FILE=	elpa
ELS=		$(wildcard $(LISP_DIR)/*.el)
OBJECTS=	$(ELS:.el=.elc)


.PHONY:		all
all:		package

.PHONY:		info
info:
		@echo "app name: $(APP_NAME)"
		@echo "compile elisp: $(OBJECTS)"

# patterns
%.elc:		%.el
		$(CASK) build

# lifecycle
$(ELPA_FILE):
		$(CASK) install || true
		$(CASK) update
		touch $@

.PHONY:		build
build:		$(ELPA_FILE) $(OBJECTS)

.PHONY:		test
test:		build cleantest
		@if [ -d test ] ; then \
			$(CASK) exec ert-runner -L $(LISP_DIR) ; \
		fi

.PHONY:		tmp
tmp:		$(DOC_DIR)

$(DOC_DIR):
		mkdir -p $(DOC_DIR)
		@if [ -f README.md ] ; then \
			pandoc README.md -s -o $(DOC_DIR)/$(APP_NAME).texi ; \
		fi

.PHONY:		mkdoc
mkdoc:		$(DOC_DIR)

.PHONY:		package
package:	test mkdoc
		$(CASK) package

# clean
.PHONY:		cleantest
cleantest:
		rm -f $(OBJECTS)

.PHONY:		clean
clean:		cleantest
		rm -rf $(ELPA_FILE) dist $(DOC_DIR)

.PHONY:		cleanall
cleanall:	clean
		rm -rf .cask $(GTAGUTIL)
