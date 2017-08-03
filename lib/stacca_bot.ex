defmodule StaccaBot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(StaccaBot.Poller, []),
      worker(StaccaBot.Matcher, [])
    ]

    opts = [strategy: :one_for_one, name: StaccaBot.Supervisor]
    Supervisor.start_link children, opts
  end
end
