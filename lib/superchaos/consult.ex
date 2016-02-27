defmodule Superchaos.Consult do
  use Ecto.Schema

  schema "consults" do
    field :state, :string
    field :status, :string
    field :specialty, :string
    field :member_id, :integer
    field :provider_id, :integer
  end
end
