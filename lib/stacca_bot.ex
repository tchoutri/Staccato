defmodule StaccaBot do
  use Application
  alias StaccaBot.RATPWorker

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(StaccaBot.Poller, []),
      worker(StaccaBot.Matcher, []),
      worker(RATPWorker, [])
    ]

    opts = [strategy: :one_for_one, name: StaccaBot.Supervisor]
    Supervisor.start_link children, opts
  end
end
