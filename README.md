JFMK-Auth [![Build Status](https://travis-ci.org/jfroom/jfmk-auth.svg?branch=master)](https://travis-ci.org/jfroom/jfmk-auth)
==========

# Overview
Simple user management & authentication Rails web app to protect a JavaScript based Single-Page App (SPA) on AWS S3.
 
Utilizes:
- Rails 5, Postgres, Selenium, AWS S3, Bootstrap, SCSS, CoffeeScript.
- Docker Compose for development, test and Travis CI. :tada: 
- Simple Rails [`has_secure_password`](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html) API for authentication & cookie sessions.
- Tests with MiniTest for model units, and Capybara Selenium acceptance tests running in a docker service with Chrome standalone.
- Ability to VNC locally into the Selenium session to interact and debug.
- Authenticated users are served SPA site with a proxied index page, and expiring pre-signed URLs for sensitive S3 hosted content. (Demo content is instance of [jfroom/portfolio-web](//github.com/jfroom/portfolio-web).)
- This Rails based project was initially seeded with the tidy [nickjj/orats](nickjj/orats) template :thumbsup:

#How to use

##Getting started:

1. Install [Docker](https://www.docker.com/) 1.13.1+
2. Docker Compose 1.11.1+ is also required, but should be installed with Docker.
3. Verify docker & docker compose versions with: 
```
docker -v; docker-compose -v
```


##First run:

Build the docker images:
```
docker-compose build
```

Set up rails and the database:
```
docker-compose exec web rails r bin/setup
```

Seed the database with two users: `admin:Admin123` and `user:User123`. Use the admin login to change those immediately.
```
docker-compose exec web rails db:seed
```

###Development 

Stand up all services:
```
docker-compose up
```
And then visit `http://localhost:3000/` to see the web service.

A common call chain to stop any existing/hung containers, stand up all services in detached mode, connect to view 
web service only (to view running log and interact with byebug):
```
docker-compose down; docker-compose up -d; docker attach jfmkauth_web_1

```

After a pull or update:
```
docker-compose exec web rails r bin/update
```

If any .Gemfile has changed, docker web image needs to be rebuilt with the following (TODO: make this more dynamic, seems to be a common problem in the docker/rails community):
```
docker-compose build
```

###Test

Run tests (also importantly sets Rails.env = 'test')
```
docker-compose exec test rails test
```

To interactive with and debug Selenium sessions, use VNC to connect to the Selenium service. []VNC Viewer](https://www.realvnc.com/download/viewer/) works well, and on OS X Screen Sharing app is built-in.
```
vnc://localhost:5900  password:secret
```

The test app instance can also be see locally at `http://localhost:3001/`.

##Caveats:
 
- If you want a quick way to just password protect a static S3 website with Basic HTTP Auth, check out this [s3auth](https://github.com/yegor256/s3auth) service and [article](http://www.yegor256.com/2014/04/21/s3-http-basic-auth.html). 
- `app/controllers/pages_controller` which parses/proxies/pre-signs S3 content is tightly coupled to my personal needs. If you choose to clone/fork this project for the user management aspect, you'll probably want to yank that controller, related tests, and environment vars. Could just replace it with [orats]([https://github.com/nickjj/orats](nickjj/orats))' simpler `PagesController` for basic HTML views.

