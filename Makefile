run:
	bundle exec jekyll serve --livereload

update:
	bundle update

build:
	gem install jekyll bundler
	bundle install
	bundle exec jekyll build

newpost:
	@title="$(title)"; \
	slug=$$(echo "$$title" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | tr -cd '[:alnum:]-'); \
	date=$$(date +"%Y-%m-%d"); \
	datetime=$$(date +"%Y-%m-%d %H:%M"); \
	filename="blog/_posts/$$date-$$slug.markdown"; \
	echo "---" > $$filename; \
	echo "title: \"$$title\"" >> $$filename; \
	echo "layout: post" >> $$filename; \
	echo "date: $$datetime" >> $$filename; \
	echo "tag: something-cool" >> $$filename; \
	echo "image: /assets/images/banner.png" >> $$filename; \
	echo "headerImage: true" >> $$filename; \
	echo "blog: true" >> $$filename; \
	echo "hidden: false" >> $$filename; \
	echo "description: \"???\"" >> $$filename; \
	echo "category: blog" >> $$filename; \
	echo "author: belinhacbr" >> $$filename; \
	echo "externalLink: false" >> $$filename; \
	echo "---" >> $$filename; \
	echo "" >> $$filename; \
	echo "New post created: $$filename"