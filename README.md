# Birdr API

## Setup

This API is built using Ruby on Rails (5.2). We use Docker for our development environment. To get up and running:

```
docker-compose build
docker-compose up
```

To bring the database inline with production:

```
docker-compose run app rails db:create db:migrate
```

To run the tests:

```
docker-compose run app rspec
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
  "firstName": "Bob",
  "lastName": "Falcon",
  "email": "bob@falcon.com",
  "password": "secret"
}
```

##### Example response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "2397c038-fd20-11e6-a33e-784f43502296",
  "firstName": "Bob",
  "lastName": "Falcon",
  "email": "bob@falcon.com"
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
  "firstName": "Bob",
  "lastName": "Falcon",
  "email": "bob@falcon.com"
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
  "firstName": "John"
}
```

##### Example response
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "2397c038-fd20-11e6-a33e-784f43502296",
  "firstName": "John",
  "lastName": "Falcon",
  "email": "bob@falcon.com"
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
  "email": "bob@falcon.com",
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
HTTP/1.1 204 No content
```

#### `PATCH /password_resets/:password_reset_token`

Update a user's password provided the password reset token is valid.

##### Example request

```http
PATCH /password_resets/d41d8cd98f00b204e9800998ecf8427e HTTP/1.1
Content-Type: application/json

{
  "email": "bob@falcon.com",
  "password": "new_password"
}
```

##### Example response

```http
HTTP/1.1 204 No content
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
  "commonName": "Robin",
  "scientificName": "Erithacus rubecula"
}
```

##### Example response
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "07630030-a00d-4d0a-a360-efccaf95a172",
  "commonName": "Robin",
  "scientificName": "Erithacus rubecula"
}

### Sightings

#### `POST /sightings`

Record seeing a particular bird

##### Example request
```http
POST /sightings HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json

{
  "bird_id": "07630030-a00d-4d0a-a360-efccaf95a172"
}
```

##### Example response

```http
HTTP/1.1 201 Created
Content-Type application/json

{
  "id": "a0918001-6c5d-4cce-95bc-bac08fc24f91",
  "bird": {
    "id": "07630030-a00d-4d0a-a360-efccaf95a172",
    "commonName": "Robin",
    "scientificName": "Erithacus rubecula"
  },
  "user": {
    "id": "2397c038-fd20-11e6-a33e-784f43502296",
    "firstName": "Bob",
    "lastName": "Falcon",
    "email": "bob@falcon.com"
  }
}
```

#### `DELETE /sightings/:id`

Remove a sighting from your bird list

##### Example request

```http
DELETE /sightings/a0918001-6c5d-4cce-95bc-bac08fc24f91 HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json
```

##### Example response

```http
HTTP/1.1 204 No content
```

### Bird Lists

#### `GET /user/bird_list`

View your bird list. The list includes all birds and whether you have seen them or not.

##### Example request
```http
GET /user/bird_list HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/json
```

##### Example response

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "bird": {
      "id": "07630030-a00d-4d0a-a360-efccaf95a172",
      "commonName": "Robin",
      "scientificName": "Erithacus rubecula"
    },
    "seen": true
  }
  ...
]
```
