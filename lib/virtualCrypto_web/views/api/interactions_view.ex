defmodule VirtualCryptoWeb.Api.InteractionsView do
  use VirtualCryptoWeb, :view
  alias VirtualCryptoWeb.Api.InteractionsView, as: InteractionsView

  def render("pong.json", _) do
    %{
      type: 1
    }
  end

  def render("bal.json", %{params: params}) do
    InteractionsView.Bal.render(params)
  end

  def render("pay.json", %{
        params: {res, v}
      }) do
    InteractionsView.Pay.render(res, v)
  end

  def render("give.json", %{params: {res, v}}) do
    InteractionsView.Give.render(res, v)
  end

  def render("create.json", %{params: {response, reason, options}}) do
    InteractionsView.Create.render(response, reason, options)
  end

  def render("info.json", %{params: {response, data, user_amount, guild}}) do
    InteractionsView.Info.render(response, data, user_amount, guild)
  end

  def render("help.json", %{params: {bot_invite_url, guild_invite_url, site_url}}) do
    %{
      type: 3,
      data: %{
        flags: 64,
        content:
          ~s/**VirtualCrypto**\n/ <>
            ~s/VirtualCryptoはDiscord上でサーバーに独自の通貨を作成できるBotです。\n/ <>
            ~s/公式サイト: #{site_url}}\n/ <>
            ~s/コマンドの使い方の詳細: #{site_url}\/document\/commands\n/ <>
            ~s/サポートサーバー: #{guild_invite_url}\n/ <>
            ~s/Botの招待: #{bot_invite_url}/
      }
    }
  end

  def render("invite.json", %{params: {bot_invite_url, guild_invite_url}}) do
    %{
      type: 3,
      data: %{
        flags: 64,
        content:
          ~s/VirtualCryptoの招待: #{bot_invite_url}\nVirtualCryptoのサポートサーバー: #{guild_invite_url}/
      }
    }
  end

  def render("claim.json", %{params: params}) do
    InteractionsView.Claim.render(params)
  end
end
