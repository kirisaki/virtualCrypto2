defmodule VirtualCrypto.Command do
  @moduledoc """
  """

  def help do
    %{
      "name" => "help",
      "description" => "ヘルプを表示します。"
    }
  end

  def invite do
    %{
      "name" => "invite",
      "description" => "Botの招待URLを表示します。"
    }
  end

  def give do
    %{
      "name" => "give",
      "description" => "未配布分の通貨を送信します。管理者権限が必要です。",
      "options" => [
        %{
          "name" => "user",
          "description" => "送信先のユーザーです。",
          "type" => 6,
          "required" => true
        },
        %{
          "name" => "amount",
          "description" => "送信する通貨の量です。",
          "type" => 4,
          "required" => true
        }
      ]
    }
  end

  def pay do
    %{
      "name" => "pay",
      "description" => "指定したユーザーに通貨を指定した分だけ送信します。",
      "options" => [
        %{
          "name" => "unit",
          "description" => "送信したい通貨の単位です。",
          "type" => 3,
          "required" => true
        },
        %{
          "name" => "user",
          "description" => "送信先のユーザーです。",
          "type" => 6,
          "required" => true
        },
        %{
          "name" => "amount",
          "description" => "送信する通貨の量です。",
          "type" => 4,
          "required" => true
        }
      ]
    }
  end

  def info do
    %{
      "name" => "info",
      "description" => "通貨の情報を表示します。通貨名または単位がない場合はそのサーバーの通貨を表示します。",
      "options" => [
        %{
          "name" => "name",
          "description" => "検索したい通貨の通貨名です。",
          "type" => 3,
          "required" => false
        },
        %{
          "name" => "unit",
          "description" => "検索したい通貨の単位です。",
          "type" => 3,
          "required" => false
        }
      ]
    }
  end

  def create do
    %{
      "name" => "create",
      "description" => "新しい通貨を作成します",
      "options" => [
        %{
          "name" => "name",
          "description" => "新しい通貨の通貨名です。2~32文字までの英数字です。",
          "type" => 3,
          "required" => true
        },
        %{
          "name" => "unit",
          "description" => "新しい通貨の単位です。1~10文字の英子文字です。",
          "type" => 3,
          "required" => true
        },
        %{
          "name" => "amount",
          "description" => "通貨の初期発行枚数です。あなたの所持金となります。",
          "type" => 4,
          "required" => true
        }
      ]
    }
  end

  def bal do
    %{
      "name" => "bal",
      "description" => "自分の所持通貨を確認します。"
    }
  end

  def claim do
    %{
      "name" => "claim",
      "description" => "請求に関するコマンドです。",
      "options" => [
        %{
          "name" => "list",
          "description" => "請求の一覧を表示します。",
          "type" => 1,
          "options" => []
        },
        %{
          "name" => "make",
          "description" => "請求を作成します。",
          "type" => 1,
          "options" => [
            %{
              "name" => "user",
              "description" => "請求先のユーザーです。",
              "type" => 6,
              "required" => true
            },
            %{
              "name" => "unit",
              "description" => "請求する通貨の単位です。",
              "type" => 3,
              "required" => true
            },
            %{
              "name" => "amount",
              "description" => "請求する通貨の枚数です。",
              "type" => 4,
              "required" => true
            }
          ]
        },
        %{
          "name" => "approve",
          "description" => "請求を承諾し支払います。",
          "type" => 1,
          "options" => [
            %{
              "name" => "id",
              "description" => "請求の番号です。/claim listで確認できます。",
              "type" => 4,
              "required" => true
            }
          ]
        },
        %{
          "name" => "deny",
          "description" => "請求を拒否します。",
          "type" => 1,
          "options" => [
            %{
              "name" => "id",
              "description" => "請求の番号です。/claim listで確認できます。",
              "type" => 4,
              "required" => true
            }
          ]
        },
        %{
          "name" => "cancel",
          "description" => "自分が送った請求をキャンセルします。",
          "type" => 1,
          "options" => [
            %{
              "name" => "id",
              "description" => "請求の番号です。/claim listで確認できます。",
              "type" => 4,
              "required" => true
            }
          ]
        }
      ]
    }
  end

  def post_all do
    HTTPoison.start()

    headers = [
      {"Authorization", "Bot " <> Application.get_env(:virtualCrypto, :bot_token)},
      {"Content-Type", "application/json"}
    ]

    url = Application.get_env(:virtualCrypto, :command_post_url)
    commands = [help(), invite(), give(), pay(), info(), create(), bal(), claim()]

    commands
    |> Enum.each(fn command ->
      {:ok, r} = HTTPoison.post(url, Jason.encode!(command), headers)
      IO.inspect(r.status_code)
    end)
  end
end
