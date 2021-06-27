# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Comadrepay.Repo.insert!(%Comadrepay.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Comadrepay.Accounts.create_user(%{
  email: "cinderella@fairy.com",
  cpf: "687.777.468-05",
  first_name: "Ella",
  last_name: "Gertrude",
  password: "glass.shoes",
  password_confirmation: "glass.shoes",
  balance: 1000
})

Comadrepay.Accounts.create_user(%{
  email: "snow.white@fairy.com",
  cpf: "525.091.767-49",
  first_name: "Snow",
  last_name: "White",
  password: "7dwarves",
  password_confirmation: "7dwarves",
  balance: 1000
})
