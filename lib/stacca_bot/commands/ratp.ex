defmodule StaccaBot.Commands.RATP do
  use StaccaBot.Commander

  def bus(update) do
    {:ok, _} = send_message "",

    reply_markup: %Model.InlineKeyboardMarkup{
      inline_keyboard: [
        %{
          callback_data: "/bus 105",
          text: "105"
        },
        %{
          callback_data: "/bus 322",
          text: "322"
        },
        %{
          callback_data: "/bus 129",
          text: "129"
        }
      ]
    }
  end
end
