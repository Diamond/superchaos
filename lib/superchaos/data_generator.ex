defmodule Superchaos.DataGenerator do
  @base_url "http://localhost:4000/api/events"
  @headers [
    {"Accept", "application/json"},
    {"Content-Type", "application/json"}
  ]

  def generate_data do
    Faker.start
    member_task = Task.async(fn ->
      IO.puts "Generating members..."
      generate_members
      IO.puts "Done generating members..."
    end)
    provider_task = Task.async(fn ->
      IO.puts "Generating providers..."
      generate_providers
      IO.puts "Done generating providers..."
    end)
    consult_task = Task.async(fn ->
      IO.puts "Generating consults..."
      generate_consults
      IO.puts "Done generating consults..."
    end)
    Task.yield_many([member_task, provider_task, consult_task], 1000000)
  end

  def generate_providers do
    Enum.map(1..250, fn _ ->
      task = Task.async(fn ->
        generate_provider
      end)
      Task.await(task)
    end)
  end

  def generate_members do
    Enum.map(1..250, fn _ ->
      task = Task.async(fn ->
        generate_member
      end)
      Task.await(task)
    end)
  end

  def generate_consults do
    Enum.map(1..250, fn _ ->
      task = Task.async(fn ->
        generate_consult
      end)
      Task.await(task)
    end)
  end

  def reset_data do
    IO.puts "Resetting data..."
    body = %{
      event: %{
        action: "RESET",
        payload: %{
          data: ""
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def generate_member do
    body = %{
      event: %{
        action: "CREATE_MEMBER",
        payload: %{
          name: Faker.Name.En.name
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def generate_provider do
    states = ["NY", "CT", "TX"]
    specialties = ["DERM", "GM", "BH"]
    body = %{
      event: %{
        action: "CREATE_PROVIDER",
        payload: %{
          name: "Dr. #{Faker.Name.En.name}",
          state: Enum.random(states),
          specialty: Enum.random(specialties)
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def generate_consult do
    states = ["NY", "CT", "TX"]
    specialties = ["DERM", "GM", "BH"]
    body = %{
      event: %{
        action: "CREATE_CONSULT",
        payload: %{
          member_id: Enum.random(1..1000),
          state: Enum.random(states),
          specialty: Enum.random(specialties),
          status: "REQUESTED"
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def lock_consult(consult_id) do
    body = %{
      event: %{
        action: "LOCK_CONSULT",
        payload: %{
          consult_id: Integer.to_string(consult_id),
          provider_id: Integer.to_string(Enum.random(1..1000))
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def complete_consult(consult_id) do
    body = %{
      event: %{
        action: "COMPLETE_CONSULT",
        payload: %{
          consult_id: Integer.to_string(consult_id),
          provider_id: Integer.to_string(Enum.random(1..1000))
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end

  def cancel_consult(consult_id) do
    body = %{
      event: %{
        action: "CANCEL_CONSULT",
        payload: %{
          consult_id: Integer.to_string(consult_id)
        }
      }
    }
    HTTPoison.post!(@base_url, Poison.encode!(body), @headers)
  end
end
