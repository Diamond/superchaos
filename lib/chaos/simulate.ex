defmodule Mix.Tasks.Chaos.Simulate do
  use Mix.Task
  @operations 1_000_000
  @batch_size 10_000

  @shortdoc "Generates chaos data for the queue"
  @moduledoc """
    A mix task that generates chaotic data with no structure
    for the realtime consultation queue.
  """

  alias Superchaos.Repo
  alias Superchaos.Consult
  import Ecto.Query

  def run(_args) do
    Application.ensure_all_started(:superchaos)
    consult_ids = Repo.all(from c in Consult, select: [:id])
      |> Enum.map(fn consult -> consult.id end)
    Enum.map(1..(div(@operations, @batch_size)), fn batch_n ->
      tasks = Enum.map(1..@batch_size, fn _ ->
        consult_ids
        |> Enum.random
        |> take_random_action
      end)
      Task.yield_many(tasks, @operations)
    end)
  end

  defp take_random_action(nil), do: nil
  defp take_random_action(consult_id) do
    Task.async(fn ->
      action = Enum.random(["lock", "complete", "cancel"])
      case action do
        "lock" ->
          Superchaos.DataGenerator.lock_consult(consult_id)
        "complete" ->
          Superchaos.DataGenerator.complete_consult(consult_id)
        "cancel" ->
          Superchaos.DataGenerator.cancel_consult(consult_id)
      end
    end)
  end
end
