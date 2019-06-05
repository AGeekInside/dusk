.PHONY: build clean coverage dist docs help install release servedocs test
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

## Version is hardcoded and should only be modified by bumpversion.
VERSION=0.1.0

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## Remove all build, test, coverage and Python artifacts	

clean-build: ## Remove build artifacts
	rm -fr build/ rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## Remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## Remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

lint: ## Check style with flake8
	pylint helios

black: ## Runs black on the code base
	black helios

time-test: ## run tests on every Python version with tox
	pytest --durations=0

test: ## run tests on every Python version with tox
	pytest

coverage: ## check code coverage quickly with the default Python
		coverage run --source helios setup.py test
		coverage report -m
		coverage html
		$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/helios.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ helios
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: clean ## package and upload a release
	python setup.py sdist upload -r local

dist: clean ## builds source and wheel package
	python setup.py sdist
	#python setup.py bdist_whee
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install