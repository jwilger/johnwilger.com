# Development: run Zola serve (Sass is compiled automatically by Zola)
dev:
	@echo "Starting development server..."
	zola serve --drafts

# Build for production
build:
	@echo "Fetching projects..."
	bash scripts/fetch-projects.sh
	@echo "Building site with Zola..."
	zola build

# Run test suite
test:
	bash tests/projects-page-repos-test.sh
	bash tests/blog-social-metadata-test.sh
	bash tests/blog-narration-test.sh
	bash tests/blog-narration-skill-test.sh
	bash tests/site-favicon-test.sh

# Clean build artifacts
clean:
	rm -rf public/
	rm -f data/projects.json
