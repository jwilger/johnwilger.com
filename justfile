# Development: run Zola serve (Sass is compiled automatically by Zola)
dev:
	@echo "Starting development server..."
	zola serve

# Build for production
build:
	@echo "Fetching projects..."
	bash scripts/fetch-projects.sh
	@echo "Building site with Zola..."
	zola build

# Clean build artifacts
clean:
	rm -rf public/
	rm -f data/projects.json
