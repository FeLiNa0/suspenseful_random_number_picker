SHELL=bash -o pipefail
PYFILES:=$(shell find . -iname \*.py)
VERSION=src/powerflex_monitoring/VERSION
TEST_CONTAINER_NAME=powerflex_monitoring_tests

all: commitready

commitready: format-fix lint

setup: setup-with-pipenv

setup-with-pipenv:
	# Upgrade pip and install pipenv
	python -m pip install --upgrade pip
	pip install pipenv
	# Avoid stale dependencies by removing the existing Pipfile
	rm -f Pipfile
	# Avoid using the Pipfile from a higher level directory
	touch Pipfile
	# Install all dependencies with the right Python version
	# Remove the --python argument to use any Python version
	pipenv install --skip-lock \
		-r development_requirements.txt \
		--python $(shell grep python .tool-versions | cut -d' ' -f2)

lint:
	pydocstyle --add-ignore=D100,D101,D102,D103,D104,D105,D106,D107,D202,D412 ${PYFILES}
	pylint ${PYFILES}

format-fix:
	black ${PYFILES}
	isort ${PYFILES}

format-check:
	black --check ${PYFILES}
	isort --check ${PYFILES}

clean:
	# Python files
	rm -rf build/
	rm -rf dist/
	rm -rf $(shell find . -type d -iname __pycache__)
