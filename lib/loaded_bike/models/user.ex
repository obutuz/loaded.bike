defmodule LoadedBike.User do
  use LoadedBike.Web, :model
  use Arc.Ecto.Schema

  schema "users" do
    field :email,                 :string
    field :name,                  :string
    field :password_hash,         :string
    field :password,              :string, virtual: true
    field :password_reset_token,  :string

    field :avatar, LoadedBike.Web.AvatarUploader.Type

    has_many :tours, LoadedBike.Tour

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name, :password])
    |> cast_attachments(params, [:avatar])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/@/)
    |> changeset_set_password
  end

  def generate_password_reset_token!(struct) do
    struct
    |> change(password_reset_token: SecureRandom.urlsafe_base64)
    |> Repo.update!
  end

  def change_password!(struct, password) do
    struct
    |> changeset(%{password: password})
    |> put_change(:password_reset_token, nil)
    |> Repo.update()
  end

  defp changeset_set_password(changeset) do
    state = Ecto.get_meta(changeset.data, :state)
    new_password = get_change(changeset, :password)

    cond do
      state == :built or new_password ->
        changeset
        |> validate_required([:password])
        |> validate_length(:password, min: 6, max: 100)
        |> hash_password()
      true ->
        changeset
    end
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
