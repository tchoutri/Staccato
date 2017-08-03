defmodule StaccaBot.Commands.Resto do
  use StaccaBot.Commander
  use StaccaBot.Router

  def resto(update) do
    {:ok, _} = send_message "Liste des restaurants en mémoire",

    reply_markup: %Model.InlineKeyboardMarkup{
      inline_keyboard: [
        [
          %{
            callback_data: "/resto Luna Rossa",
            text: "Luna Rossa",
          },
          %{
            callback_data: "/resto Le Train de Vie",
            text: "Le Train de Vie",
          },
        ]
      ]
    }
  end

  @spec build_resto(String.t) :: [map()]
  def build_resto(resto) when is_binary(resto) do
    load_resto()
    |> Map.get(String.to_atom(resto))
    |> Map.keys
    |> build_inline_keyboard(resto)
  end


  @spec build_inline_keyboard([atom()], atom()) :: [map()]
def build_inline_keyboard(categories, restaurant) when is_list(categories) and
                                                       is_atom(restaurant) do
    Enum.map categories, fn cat ->
      %{
        callback_data: "/catégorie #{cat} #{restaurant}",
        text: String.capitalize("#{cat}")
      }
    end
  end

  @spec build(atom(), atom()) :: String.t
def build(cat, resto) when is_atom(resto) and
                           is_atom(cat) do
    load_resto()
    |> Map.get(resto)
    |> Map.get(cat)
    |> Enum.map(fn {plat, prix} -> "• #{plat} : #{prix}€" end)
    |> Enum.join("\n")
  end

  def load_resto() do
    File.read!("priv/resto.toml")
    |> Tomlex.load
  end
end
