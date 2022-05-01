import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :max_bank, MaxBank.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "max_bank_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :max_bank, MaxBankWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JcB99i5FquM+W7hdQ/C/4reSgSSbk93x2dmkFea3gcfRcsXlt4AOAgUW+3MxLMaC",
  server: false

# In test we don't send emails.
config :max_bank, MaxBank.Mailer, adapter: Swoosh.Adapters.Test

config :pbkdf2_elixir, rounds: 1

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
