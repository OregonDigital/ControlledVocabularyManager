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

**Requires Ruby 2.0**

	git clone https://github.com/OregonDigital/ControlledVocabularyManager.git
	cd ControlledVocabularyManager
	bundle install
	rake db:create && rake db:migrate
	rake triplestore_adapter:blazegraph:reset

Start the servers:

	rails server


Vagrant Setup
-----

Requires [Git](http://www.git-scm.com/),
[VirtualBox](https://www.virtualbox.org/), and
[Vagrant](http://www.vagrantup.com/).  Also requires 2 gigs of RAM to be
available for the VM which vagrant creates.

`git clone https://github.com/OregonDigital/ControlledVocabularyManager.git`

Tell vagrant to download and start the virtual machine:

    vagrant up
    vagrant ssh

After `vagrant ssh` you'll be logged into the VM.  From there, you'll want to
start the Rails server:

    cd /vagrant
    rails server

You can browse the app via `http://localhost:3000`, and check on the blazegraph
server at `http://localhost:9999/blazegraph`
