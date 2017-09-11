defmodule StaccaBot.RATPWorker do

  use GenServer
  require Logger

  defmodule Resource do
    defstruct [:mode,
               :ligne,
               :arret,
               :direction
              ]
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Logger.info "Starting RATPWorker"
    {:ok, :ok}
  end

  def handle_call({:bus, bus}, _from, state) do
    result = case bus do
      "105" -> [carnot("A"), carnot("R")]
      "322" -> [sente_des_mares("A"), sente_des_mares("R")]
      "129" -> [romainville_carnot("A"), romainville_carnot("R")]
    end
    {:ok, result}
  end


  defp sente_des_mares(way) do
    %{}
    |> mode("bus")
    |> ligne("322")
    |> arret("sente+des+mares")
    |> direction(way)
    |> build()
  end

  defp carnot(way) do
    %{}
    |> mode("bus")
    |> ligne("105")
    |> arret("carnot")
    |> direction(way)
    |> build()
  end

  defp romainville_carnot(way) do
    %{}
    |> mode("bus")
    |> ligne("129")
    |> arret("romainville+++carnot")
    |> direction(way)
    |> build()
  end


  defp mode(map, mode),   do: Map.put_new(map, :mode, mode)
  defp ligne(map, ligne), do: Map.put_new(map, :ligne, ligne)
  defp arret(map, arret), do: Map.put_new(map, :arret, arret)

  defp direction(map, direction) when direction in ["A", "R"] do
    Map.put_new(map, :direction, direction)
  end

  defp build(map) do
    structure = struct(%Resource{}, map)

    "https://api-ratp.pierre-grimaud.fr/v3/schedules/#{structure.mode}/#{structure.ligne}/#{structure.arret}/#{structure.direction}?_format=JSON"
    |> get_schedules
    |> format_schedules
  end

  defp get_schedules(url) do
    case HTTPoison.get url do
      {:ok, response} ->
        Poison.decode response.body
      {:error, reason} ->
        Logger.error inspect(reason)
        {:error, reason}
    end
  end

  defp format_schedules({:ok, data}) do
    dest = hd(data["result"]["schedules"])["destination"] <> " : " # Je récupère la destination du bus
    data["result"]["schedules"]
    |> Enum.map(fn(map) -> map["message"] end) # J'accède aux horaires de chaque bus, et les met dans une liste
    |> Enum.intersperse(" | ") # Entre chaque élément de la liste, je rajoute cet élément
    |> List.insert_at(0, dest) # Je met au début de la liste la destination
    |> Enum.join # Je transforme cette liste en chaîne de caractères.
  end
end
