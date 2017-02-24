#!/usr/bin/env bash

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

heroku maintenance:on
heroku apps # passively check to see if logged in; if not will prompt user
git push heroku master

heroku run rails db:migrate
heroku run rails db:schema:cache:clear
heroku restart
heroku maintenance:off

