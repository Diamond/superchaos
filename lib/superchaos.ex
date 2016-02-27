defmodule Superchaos do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Superchaos.Repo, [])
    ]
    opts = [name: Superchaos.Supervisor, strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

defmodule Superchaos.Repo do
  use Ecto.Repo, otp_app: :superchaos
end
