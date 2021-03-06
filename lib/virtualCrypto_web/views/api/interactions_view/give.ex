defmodule VirtualCryptoWeb.Api.InteractionsView.Give do
  import VirtualCryptoWeb.Api.InteractionsView.Util

  defp render_error(:not_found_money) do
    "エラー: 通貨が存在しません。"
  end

  defp render_error(:not_found_sender_asset) do
    "エラー: 通貨を持っていません。"
  end

  defp render_error(:not_enough_amount) do
    "エラー: 通貨が不足しています。"
  end

  defp render_error(:permission) do
    "エラー: 実行には管理者権限が必要です。"
  end

  def render(:ok, {receiver, amount, unit}) do
    %{
      type: 3,
      data: %{
        tts: false,
        embeds: [
          %{
            "description" =>
              "\u2705 " <>
                mention(receiver) <> "へ" <> Integer.to_string(amount) <> unit <> "発行されました。",
            color: 0x38EA42
          }
        ],
        allowed_mentions: []
      }
    }
  end

  def render(:error, v) do
    %{
      type: 3,
      data: %{
        tts: false,
        flags: 64,
        content: render_error(v),
        allowed_mentions: []
      }
    }
  end
end
