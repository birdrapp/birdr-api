# Birdr API

## Setup

This API is built using Ruby on Rails (5.1). To get setup you will first need to ensure you have the latest version of Ruby installed (2.4.1+), as well as the [bundler gem](http://bundler.io/):

```bash
brew install ruby
gem install bundler
```

Once installed you can install the API dependencies by running `bundle install`:

```bash
cd birdr-api
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
