build:
	python -m mkdocs build

serve:
	python -m mkdocs serve -a 0.0.0.0:8000

deploy:
	python -m mkdocs gh-deploy

clean:
	find . -name "*~" -exec rm {} \;

.PHONY: build serve deploy clean
