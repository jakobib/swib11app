This repository contains a sample linked data application for a workshop
at the 'Semantic Web in Bibliotheken' (SWIB11): http://swib.org/swib11/

# MANIFEST

The master branch contains at least the following files:

    swib11app/
     |-- dotcloud.yml             dotCloud configuration
     |-- README                   this file
     |-- app/                     application root
          |--- app.psgi           core startup file as PSGI application
          |--- Makefile.PL        CPAN dependencies
          |--- nginx.conf         nginx proxy configuration
          |--- lib/               additional non-CPAN libraries
                |-- SWIB11App.pm  the core application
          |--- htdocs/            static files and templates
                |-- htdocs        HTML and other files to serve via HTTP
                     |-- rdf/     Static RDF data files

# REQUIREMENTS

## INSTALLING REQUIREMENTS ON LINUX

First, install a C compiler, git (optional), and cpanminus:

    sudo apt-get install build-essential git-core
    wget -O - http://cpanmin.us | sudo perl - --self-upgrade

Second, install this repository either by git:

    git clone git://github.com/gbv/swib11app.git

or as snapshot zipfile (if you don't have git):
  
    wget http://github.com/gbv/swib11app/zipball/master
    unzip master
    mv gbv-swib11app-* swib11app

Third, install required CPAN modules with cpanminus:

    cd swib11app
    sudo cpanm --installdeps ./app

## INSTALLING REQUIREMENTS ON WINDOWS

First, install Strawberry Perl or Cygwin with Perl and cpanminus.

Second, install this repository either by git from

  git://github.com/gbv/swib11app.git

or as snapshot zipfile from

  http://github.com/gbv/swib11app/zipball/master

Third, start a command line in the 'swib11app' directory
and install required CPAN modules with cpanminus:

    sudo cpanm --installdeps ./app

# TESTING

Just start the application from the application root directory with

    cd app
    plackup -r

It should now be accesible at http://localhost:5000/ and logging output is
sent to the console.

# DEPLOYMENT AT DOTCLOUD

To publish your application, you can use a free account at dotCloud. 
Register and install the dotCloud command line client as described at

  http://docs.dotcloud.com/firststeps/install/

On a fresh Ubuntu Linux, it is two commands:

    sudo apt-get install python-pip
    sudo pip install dotcloud

Given a dotCloud account, you can deploy your application as following.
First, create an application

    dotcloud create swib11app

Second, push the application into the cloud

    dotcloud push swib11app

If you work with git, this will only push the latest master revision,
so you may need to do a commit first. You can also push branches:

    dotcloud push -b mybranch swib11app

The first push will take some time to install all CPAN modules at dotCloud.
A demo is running live at http://swib11app-nichtich.dotcloud.com/
