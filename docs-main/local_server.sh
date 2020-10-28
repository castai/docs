#!/usr/bin/env bash
set -ex

python3 -m pip install pipenv
python3 -m pipenv install
python3 -m pipenv run mkdocs serve