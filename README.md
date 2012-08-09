django-closure-capistrano
=========================

A simple Capistrano module for building Closure Javascript projects and deploying the django app to a server using rsync.

The system uses plovr to compile your Closure Javascript. There are a few
useful tasks built in to manage the building of the javascript, collecting
of static files before deploying to the server.