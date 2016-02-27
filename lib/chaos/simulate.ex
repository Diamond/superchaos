defmodule Mix.Tasks.Chaos.Simulate do
  use Mix.Task
  @operations 1_000_000

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
    IO.puts "Generating consults"
    consult_ids = Repo.all(from c in Consult, select: [:id])
      |> Enum.map(fn consult -> consult.id end)
    tasks = Enum.map(1..@operations, fn _ ->
      consult_ids
      |> Enum.random
      |> take_random_action
    end)
    Task.yield_many(tasks, @operations)
  end

  #defp decode_body(%{body: body}), do: Poison.decode!(body)

  #defp get_created_consult_id(%{"data" => %{"payload" => %{"id" => consult_id}}}), do: consult_id
  #defp get_created_consult_id(_), do: nil

  defp take_random_action(nil), do: nil
  defp take_random_action(consult_id) do
    Task.async(fn ->
      action = Enum.random(["lock", "complete", "cancel"])
      case action do
        "lock" ->
          IO.puts "Locking consult #{consult_id}"
          Superchaos.DataGenerator.lock_consult(consult_id)
        "complete" ->
          IO.puts "Completing consult #{consult_id}"
          Superchaos.DataGenerator.complete_consult(consult_id)
        "cancel" ->
          IO.puts "Cancelling consult #{consult_id}"
          Superchaos.DataGenerator.cancel_consult(consult_id)
      end
    end)
  end
end
