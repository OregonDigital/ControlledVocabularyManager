Controlled Vocabulary Manager
=============================
[![Circle CI](https://circleci.com/gh/OregonDigital/ControlledVocabularyManager.svg?style=svg)](https://circleci.com/gh/OregonDigital/ControlledVocabularyManager)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/ControlledVocabularyManager/badge.svg)](https://coveralls.io/r/OregonDigital/ControlledVocabularyManager)
[![Code Climate](https://codeclimate.com/github/OregonDigital/ControlledVocabularyManager/badges/gpa.svg)](https://codeclimate.com/github/OregonDigital/ControlledVocabularyManager)

Overview
-----
Rails app connected to Blazegraph for managing local controlled vocabularies for [Oregon Digital](http://oregondigital.org).
Currently powering http://OpaqueNamespace.org

Local Development Setup
-----

**Requires Ruby 2.5**

	git clone https://github.com/OregonDigital/ControlledVocabularyManager.git
	cd ControlledVocabularyManager
	bundle install
	rake db:create && rake db:migrate
	rake git_dev:create_dev_repo
	rake triplestore_adapter:blazegraph:reset
	rake sunspot:solr:start

Start the servers:

	rails server

You can browse the app via `http://localhost:3000`, and check on the blazegraph
server at `http://localhost:9999/blazegraph`
