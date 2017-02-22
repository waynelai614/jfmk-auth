[Docker](https://www.docker.com/)

First run:
```
docker-compose up --build
docker-compose exec web rails r bin/setup
```

Be aware this seeds two users: admin:Admin123, user:User123. Use the admin login to change those immediately.

Standard run:
```
docker-compose up
```

Common call chain to stop any existing/hung containers, stand up all services in detached mode, connect to view 
web service only (to view running log and interact with byebug):
```
docker-compose down; docker-compose up -d; docker attach jfmkauth_web_1

```

After a pull or update:
```
docker-compose exec web rails r bin/update
```

Run tests (also importantly sets Rails.env = 'test')
```
docker-compose exec test rails test
```

To connect to selenium to see what's going on when using :selenium driver with capybara:
```
VNC Viewer or OSX Screen Sharing: vnc://localhost:5900  password: secret
```

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
