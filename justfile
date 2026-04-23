# Development: run Sass watch and Zola serve in parallel
dev:
	@echo "Starting development server..."
	just sass-watch &
	just zola-serve

sass-watch:
	sass sass/main.scss static/css/main.css --style=expanded --watch

zola-serve:
	zola serve

# Build for production
build:
	@echo "Fetching projects..."
	bash scripts/fetch-projects.sh
	@echo "Compiling Sass..."
	sass sass/main.scss static/css/main.css --style=compressed --no-source-map
	@echo "Building site with Zola..."
	zola build

# Clean build artifacts
clean:
	rm -rf public/
	rm -f static/css/main.css
	rm -f data/projects.json
