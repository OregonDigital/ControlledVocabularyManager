Controlled Vocabulary Manager
=============================
[![Circle CI](https://circleci.com/gh/OregonDigital/ControlledVocabularyManager.svg?style=svg)](https://circleci.com/gh/OregonDigital/ControlledVocabularyManager)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/ControlledVocabularyManager/badge.svg)](https://coveralls.io/r/OregonDigital/ControlledVocabularyManager)

Local Development Setup
-----

**Requires Ruby 2.0**

	git clone https://github.com/OregonDigital/ControlledVocabularyManager.git
	cd ControlledVocabularyManager
	bundle install
	rake db:create && rake db:migrate
	rake jetty:clean

Start the servers:

	rake jetty:start
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

You can browse the app via `http://localhost:3000`, and check on the jetty
container (which houses Marmotta) at `http://localhost:8983`.
