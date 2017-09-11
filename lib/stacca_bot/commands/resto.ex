defmodule StaccaBot.Commands.Resto do
  use StaccaBot.Commander
  use StaccaBot.Router
  alias __MODULE__

  defstruct [:carte,
             :coordonnees,
             :adresse,
             :description,
             :nom
            ]

  @type t :: %__MODULE__{nom: String.t, description: String.t,
                         coordonnees: [float()], carte: map(), adresse: String.t
                        }

  def resto(update) do
    {:ok, _} = send_message "Liste des restaurants",

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
          %{
            callback_data: "/resto Namaste Népal",
            text: "Namaste Népal"
          }
        ]
      ]
    }
  end

  @spec build_resto(String.t) :: [map()]
  def build_resto(resto) when is_binary(resto) do
    load_restos()
    |> get_resto(resto)
    |> Map.get(:carte)
    |> Map.keys
    |> Enum.chunk_every(2)
    |> Enum.map(fn chunk -> Resto.build_inline_keyboard(chunk, resto) end)
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
    load_restos()
    |> get_resto(resto)
    |> Map.get(:carte)
    |> Map.get(cat)
    |> Enum.map(fn {plat, prix} -> "• #{plat} : #{prix}€" end)
    |> Enum.join("\n")
  end

  @spec load_restos() :: [Resto.t]
def load_restos() do
    File.read!("priv/resto.toml")
    |> Tomlex.load
    |> Enum.map(fn {nom, data} -> %Resto{carte: data.carte, coordonnees: data.coordonnees,
                                         description: data.description, nom: Atom.to_string(nom)} end)
  end

  @spec get_resto([Resto.t()], String.t) :: Resto.t
  def get_resto(restos, nom) when is_list(restos) and
                                is_binary(nom) do
    Enum.find(restos, fn struct -> struct.nom == nom end)
  end

  # @spec get_coord(String.t) :: [float()]
  def get_coord(resto) when is_binary(resto) do
    load_restos()
    |> get_resto(resto)
    |> Map.get(:coordonnees) 
  end

  def get_coord(%Resto{coordonnees: coord}=resto) when is_map(resto) do
    coord
  end

  # @spec get_adresse(String.t) :: String.t
  def get_adresse(resto) when is_binary(resto) do
    load_restos()
    |> get_resto(resto)
    |> Map.get(:adresse)
  end

  def get_adresse(%Resto{adresse: adresse}=resto) when is_map(resto) do
    adresse
  end

  @spec get_venue(String.t) :: {float(), float(), String.t}
  def get_venue(resto) when is_binary(resto) do
    r = get_resto(load_restos(), resto)
    [lat, long] = get_coord(r)
    adresse     = get_adresse(r)
    {lat, long, adresse}
  end
end
