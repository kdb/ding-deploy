Build and deploy tools for the Ding project
===========================================

Installing Ding
===============

To get your own installation of the Ding project you should use the ding_build tool, which is a part of the ding-deploy package

Prerequisites
-------------

The following utilities should be accessible from the command line:

*  A working version of [Python](http://www.python.org/download/)
*  The latest version of [Drush](http://drupal.org/project/drush_make) and [Drush Make](http://drupal.org/project/drush_make)
*  A working version of Git ([Installation guide](http://book.git-scm.com/2_installing_git.html))

The required server software for running Ding:

* Apache 2.x with mod_rewrite
* PHP 5.2.X with 128 MB RAM allocated and APC or XCache
* MySQL 5.X

If the installation is to integrate with the library systems access to OpenSearch, ADDI and Alma services is a must.

Building a local installation
-----------------------------

1. Get a version of the ding-deploy package by either
  *  Cloning the repository from GitHub
  *  Downloading a tagged version which corresponds to a Ding release and unpack it
2. Open a console and navigate to the `ding-deploy/build` directory
3. Run `python ding_build [options] [installation path]`. The options include
  *  `-d`: **Debug**. Required if you want to track the build progress
  *  `-D`: **Developer copy**. Build developer copy, using authenticated Git repositories.
  *  `-m MODE`: **Build mode**. Use 'site' for full Drupal site, 'profile' for just the installation profile. Default is 'site'.
4. The build process should take ~5 minutes
5. Make your ding installation is accessible from your web server and create a corresponding database in MySQL
6. Open a browser and navigate to the web path for your Ding installation. This should display the Drupal installer with the option of using the Ding! installation profile.
7. Follow the installation instructions
  1. Select the Ding! installation profile
  2. Create a copy of `sites/default/default.settings.php` and name it `settings.php`
  3. Enter your database configuration
