django-closure-capistrano
=========================

A simple Capistrano module for building Closure Javascript projects and deploying the django app to a server using rsync.

The system uses plovr to compile your Closure Javascript. There are a few
useful tasks built in to manage the building of the javascript, collecting
of static files before deploying to the server.

##How used getplaceholders
Add this file ```extra_cms_tags.py``` into folder ```templatetags``` and this should be in our project folder, 

ie: ```our-website/templatetags/extra_cms_tags.py```,

then run this tags in template head ````{% load extra_cms_tags %}```. *Probably you need to restart server
