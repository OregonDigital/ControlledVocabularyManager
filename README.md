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

**Requires: Ruby 2.5, Java 8 for Blazegraph**

	git clone https://github.com/OregonDigital/ControlledVocabularyManager.git
	cd ControlledVocabularyManager
	bundle install
	bundle exec rake triplestore_adapter:blazegraph:reset
	bundle exec rake db:create && bundle exec rake db:migrate
	bundle exec rake git_dev:create_dev_repo
	bundle exec rake sunspot:solr:start

Start the servers:

	bundle exec rails server

You can browse the app via `http://localhost:3000`, and check on the blazegraph
server at `http://localhost:9999/blazegraph`

### Create admin user

In order to do anything, you'll need to create a user with admin privileges.

With the application loaded, click the 'Login' link in the top-right.
Then click 'Sign up' and fill out the form.

Once the user is created, open a new terminal window and run:

```
bundle exec rails console
me = User.first
# You should see a User object returned with the name and email you created
me.role = 'admin reviewer editor'
me.save
```

Now refresh the application in the browser. You should see an Admin Dashboard link in the top-right 'profile' menu to manage users, a Review link in the top navigation, and on the Vocabularies page you should see a button to create a new one.
