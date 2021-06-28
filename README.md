# Comadrepay

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Configure database with `docker-compose up`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

The application is run in Heroku. [Click here to access](https://comadrepay.herokuapp.com/)

* [User](#user)
  * [Create User](#create-user)
  * [List User](#list-user)
  * [Get User](#get-user)
  * [Update User](#update-user)
  * [Delete User](#delete-user)
  * [Account Balance](#account-balance)
* [Authentication](#authentication)
  * [Login](#login)
  * [Logout](#logout)
* [Transfer](#transfer)
  * [Create transfer](#create-transfer)
  * [List transfers](#list-transfers)
  * [Get transfer](#get-transfer)
  * [Reversal transfer](#reversal-transfer)

## User

### Create user

```http
POST /api/users authenticated
```

Body

```json
{
  "user": {
    "email": "cinderella@fairy.com",
    "cpf": "687.777.468-05",
    "first_name": "Ella",
    "last_name": "Gertrude",
    "password": "glass.shoes",
    "password_confirmation": "glass.shoes"
  }
}
```

### List users

```http
GET /api/users authenticated
```

### Get user

```http
GET /api/users/:id authenticated
```

### Update user

```http
PUT /api/users/:id public authenticated
```

Body

```json
{
  "user": {
    "email": "cinderella@fairy.com",
    "cpf": "687.777.468-05",
    "first_name": "Ella",
    "last_name": "Gertrude",
    "password": "glass.shoes",
    "password_confirmation": "glass.shoes"
  }
}
```

### Delete user

```http
DELETE /api/users/:id authenticated
```

### Account Balance
```http
GET /api/accounts/balance
```

## Authentication

### Login

```http
POST /api/login public
```

Body

```json
{
  "email": "cinderella@fairy.com",
  "password": "glass.shoes"
}
```

### Logout

```http
DELETE /api/logout authenticated
```

## Transfer

### Create transfer

```http
POST /api/accounts/transfers authenticated
```

Body

```json
{
  "from_account_id": "45351596-235a-48ff-be6f-2c030f82f70f",
  "to_account_id": "ba691976-64c7-4a20-8d66-caf26b6dcd09",
  "value": "42.42"
}
```

### List transfers

```http
GET /api/accounts/transfers?date_begin=YYYY-MM-DD HH:MI:SS& authenticateddate_end=YYYY-MM-DD HH:MI:SS
```

### Get transfer

```http
GET /api/accounts/transfers/:id authenticated
```

### Reversal transfer

```http
PUT /api/accounts/transfers/:id/reversal authenticated
```
