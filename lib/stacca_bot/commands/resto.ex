defmodule StaccaBot.Commands.Resto do
  use StaccaBot.Commander
  use StaccaBot.Router
  alias __MODULE__

  defstruct [:carte,
             :coordonees,
             :description,
             :nom
            ]

  @type t :: %__MODULE__{nom: String.t, description: String.t,
                         coordonees: [float()], carte: map()
                        }

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
        ],
        [
          %{
            callback_data: "/resto Istanbul Express",
            text: "Istanbul Express",
          },
        ]
      ]
    }
  end

  @spec build_resto(String.t) :: [map()]
  def build_resto(resto) when is_binary(resto) do
    load_resto()
    |> get_resto(resto)
    |> Map.get(:carte)
    |> Map.keys
    |> build_inline_keyboard(resto)
  end


  @spec build_inline_keyboard([atom()], String.t) :: [map()]
  def build_inline_keyboard(categories, restaurant) when is_list(categories) and
                                                         is_binary(restaurant) do
    Enum.map categories, fn cat ->
      %{
        callback_data: "/catégorie #{cat} #{restaurant}",
        text: String.capitalize("#{cat}")
      }
    end
  end

  @spec build(atom(), String.t) :: String.t
  def build(cat, resto) when is_binary(resto) and
                             is_atom(cat) do
    load_resto()
    |> get_resto(resto)
    |> Map.get(:carte)
    |> Map.get(cat)
    |> Enum.map(fn {plat, prix} -> "• #{plat} : #{prix}€" end)
    |> Enum.join("\n")
  end

  @spec load_resto() :: [Resto.t]
  def load_resto() do
    File.read!("priv/resto.toml")
    |> Tomlex.load
    |> Enum.map(fn {nom, data} -> %Resto{carte: data.carte, coordonees: data.coordonees,
                                         description: data.description, nom: Atom.to_string(nom)} end)
  end

  @spec get_resto([Resto.t()], String.t) :: Resto.t
def get_resto(restos, nom) when is_list(restos) and
                                is_binary(nom) do
    Enum.find(restos, fn struct -> struct.nom == nom end)
  end
end
