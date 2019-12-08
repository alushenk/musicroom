
# Musicroom

This educational project is made for [UNIT Factory](https://unit.ua/)

"Room" is a playlist for some event where people can:
* Add their tracks and vote for them
* Add friends to the room
* Restrict room so other people can't view it
* Play tracks with [deezer](https://www.deezer.com) SDK
* Do other stuff with permissions, access management, realtime and geolocation

### Authors:

* [alushenk](https://github.com/alushenk): Architecture, dev-ops, sockets, authentication
* [v-horbachuk](https://github.com/v-horbachuk): REST API, permissions & authorization
* [bezsinnyidmytro](https://github.com/bezsinnyidmytro): React client
* [hshakula](https://github.com/hshakula): IOS client

### Python version 3.7.3

### Built with
* [DRF](https://www.django-rest-framework.org) - The web framework used
* Docker & docker-compose
* Celery
* Postgres
* Redis
* Django-channels
* Traefik
* Nginx
* Swift
* React


### Deployment options

docker-compose.local.yml - For local testing. Run "web" service manually  
docker-compose.yml - Production configuration

---

### Documentation:
/docs  
/swagger  

--- 

### Environment variables for .env file
PROJECT_NAME  
DOMAIN  
AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  
SECRET_KEY  
EMAIL_HOST_PASSWORD

---

test.http - examples of API requests  
test.js - example how to connect to the sockets  
locustfile.py - load testing  

---

