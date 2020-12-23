defmodule VirtualCrypto.Money.InternalAction do
  alias VirtualCrypto.Repo
  import Ecto.Query
  alias VirtualCrypto.Money

  defp get_money_by_unit(money_unit) do
    Money.Info
    |> where([m], m.unit == ^money_unit)
    |> Repo.one()
  end

  defp get_asset_with_lock(user_id, money_id) do
    Money.Asset
    |> where([a], a.user_id == ^user_id and a.money_id == ^money_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end

  defp upsert_asset_amount(user_id, money_id, amount) do
    Repo.insert(
      %Money.Asset{
        user_id: user_id,
        money_id: money_id,
        amount: amount,
        status: 0
      },
      on_conflict: [set: [inc: amount]],
      conflict_target: [:user_id, :money_id]
    )
  end

  defp update_asset_amount(asset_id, amount) do
    Money.Asset
    |> where([a], a.id == ^asset_id)
    |> update(set: [inc: ^amount])
    |> Repo.update_all([])
  end
  defp insert_user_if_not_exits(user_id) do
    Repo.insert(%Money.User{id: user_id, status: 0}, on_conflict: :nothing)
  end

  defp get_money_by_guild_id_with_lock(guild_id) do
    Money.Info
    |> where([m], m.guild_id == ^guild_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end
  defp update_pool_amount(money_id,amount) do
    Money.Info
    |> where([a], a.id == ^money_id)
    |> update(set: [inc: ^amount])
    |> Repo.update_all([])
  end
  def pay(sender_id, receiver_id, amount, money_unit) when is_integer(amount) and amount >= 1 do
    # Get money info by unit.
    with money <- get_money_by_unit(money_unit),
         # Is money exits?
         {:money, true} <- {:money, money != nil},
         # Get sender asset by sender id and money id.
         sender_asset <- get_asset_with_lock(sender_id, money.id),
         # Is sender asset exsits?
         {:sender_asset, true} <- {:sender_asset, sender_asset != nil},
         # Has sender enough amount?
         {:sender_asset_amount, true} <- {:sender_asset_amount, sender_asset.amount >= amount},
         # Insert reciver user if not exists.
         {:ok, _} <- insert_user_if_not_exits(receiver_id),
         # Upsert receiver amount.
         {:ok, _} <- upsert_asset_amount(receiver_id, money.id, amount) do
      # Update sender amount.
      {:ok,update_asset_amount(sender_asset.id, -amount)}
    else
      {:money, false} -> {:error, :not_found_money}
      {:sender_asset, false} -> {:error, :not_found_sender_asset}
      {:sender_asset_amount, false} -> {:error, :not_enough_amount}
      err -> {:error, err}
    end
  end

  def give(receiver_id, amount, guild_id) do
    # Get money info by guild.
    with money <- get_money_by_guild_id_with_lock(guild_id),
      # Is money exits?
      {:money, true} <- {:money, money != nil},
      # Check pool amount enough.
      {:pool_amount, true} <- {:pool_amount, money.pool_amount >= amount},
      # Insert reciver user if not exists.
      {:ok, _} <- insert_user_if_not_exits(receiver_id),
      # Update reciver amount.
      {:ok, _} <- upsert_asset_amount(receiver_id, money.id, amount)
    do
      # Update pool amount.
      update_pool_amount(money.id,-amount)
    else
      {:money, false} -> {:error, :not_found_money}
      {:pool_amount, false} -> {:error, :not_enough_pool_amount}
      err -> {:error, err}
    end
  end
end

defmodule VirtualCrypto.Money do
  alias VirtualCrypto.Repo
  alias Ecto.Multi

  def pay(sender_id, receiver_id, amount, money_unit) do
    Multi.new()
    |> Multi.run(:pay, fn ->
      VirtualCrypto.Money.InternalAction.pay(sender_id, receiver_id, amount, money_unit)
    end)
    |> Repo.transaction()
  end
  def give(receiver_id, amount, guild_id) do
    Multi.new()
    |> Multi.run(:pay, fn ->
      VirtualCrypto.Money.InternalAction.give(receiver_id, amount, guild_id)
    end)
    |> Repo.transaction()
  end
end
