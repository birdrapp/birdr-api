# Birdr API

## Setup

This API is built using Ruby on Rails (5.1). To get setup you will first need to ensure you have the latest version of Ruby installed (2.4.1+), as well as the [bundler gem](http://bundler.io/):

```bash
brew install ruby@2.3
```

Follow the instructions to put Ruby 2.3 in your PATH. You then need to install bundler and all the dependencies:

```bash
gem install bundler
bundle install
```

The API uses Postgres as a database. If you're on Mac you can use [Postgres.app](https://postgresapp.com/). You will need to crete a role in postgres:

```
psql
psql # CREATE ROLE birdr LOGIN SUPERUSER PASSWORD 'birdr';
psql # \q
```

To bring the database inline with production:

```
rails db:create
rails db:migrate
```

Test everything is working:

```
rails server
```

Or, run the tests:

```
rspec
```

## API Documentation

### Users
#### `POST /users`

Create a new user account

##### Example request
```http
POST /users HTTP/1.1
Content-Type: application/json

{
  "first_name": "Matthew",
  "last_name": "Williams",
  "email": "matt@williams.com",
  "password": "secret"
}
```

##### Example response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "2397c038-fd20-11e6-a33e-784f43502296",
  "first_name": "Matthew",
  "last_name": "Williams",
  "email": "matt@williams.com"
}
```

#### `GET /user`

Return the user profile

##### Example request
```http
GET /user HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json
```

##### Example response
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "2397c038-fd20-11e6-a33e-784f43502296",
  "first_name": "Matthew",
  "last_name": "Williams",
  "email": "matt@williams.com"
}
```

#### `PATCH /user`

Update user details

##### Example request
```http
PATCH /user HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json

{
  "first_name": "John"
}
```

##### Example response
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "2397c038-fd20-11e6-a33e-784f43502296",
  "first_name": "John",
  "last_name": "Williams",
  "email": "matt@williams.com"
}
```

#### `DELETE /user`

Delete the user account

##### Example request
```http
DELETE /user HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json
```

##### Example response
```http
HTTP/1.1 204 No Content
```

### Authentication tokens
#### `POST /tokens`

Request an access token

##### Example request
```http
POST /tokens HTTP/1.1
Content-Type: application/json

{
  "email": "matt@williams.com",
  "password": "secret"
}
```

##### Example response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "token": "07630030-a00d-4d0a-a360-efccaf95a172"
}
```

### Password reset
#### `POST /password_resets`

Generate a password reset token for a user. This will send an email to the user with a link to reset their password via the generated token.

##### Example request
```http
POST /password_resets HTTP/1.1
Content-Type: application/json

{
  "email": "bob@falcon.com"
}
```

##### Example response
```http
HTTP/1.1 201 Created
```

### Birds
#### `POST /birds`

Create a new bird

##### Example request
```http
POST /birds HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json

{
  "common_name": "Robin",
  "scientific_name": "Erithacus rubecula"
}
```

##### Example response
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "07630030-a00d-4d0a-a360-efccaf95a172",
  "common_name": "Robin",
  "scientific_name": "Erithacus rubecula"
}
