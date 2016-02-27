defmodule Mix.Tasks.Chaos.Generate do
  use Mix.Task

  @shortdoc "Generates chaos data for the queue"
  @moduledoc """
    A mix task that generates chaotic data with no structure
    for the realtime consultation queue.
  """

  alias Superchaos

  def run(_args) do
    Mix.shell.info "sup dude"
    Application.ensure_all_started(:superchaos)
    Superchaos.DataGenerator.reset_data
    Superchaos.DataGenerator.generate_data
  end
end
