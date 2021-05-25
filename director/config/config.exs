use Mix.Config

config :kafka_ex,
  brokers: [{"localhost", 9092}]

config :director,
  pairs_to_clone: ["BTC_ETH", "USDT_BTC", "USDC_BTC"],
  from: 1_590_969_600,
  until: 1_591_500_000

config :director,
  ecto_repos: [Director.Repo]

config :director, Director.Repo,
  hostname: "localhost",
  database: "distributed_applications",
  username: "user",
  password: "t"

config :database_interaction, repo: Director.Repo