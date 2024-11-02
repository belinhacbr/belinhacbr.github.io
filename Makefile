run:
	bundle exec jekyll serve --livereload

update:
	bundle update

build:
	gem install jekyll bundler
	bundle install
	bundle exec jekyll build