defmodule StaccaBot.Commands do
  use StaccaBot.Router
  use StaccaBot.Commander

  alias StaccaBot.Commands.Resto

  # You can create commands in the format `/command` by
  # using the macro `command "command"`.
  command ["hello", "hi"] do
    # Logger module injected from StaccaBot.Commander
    Logger.log :info, "Command /hello or /hi"

    # You can use almost any function from the Nadia core without
    # having to specify the current chat ID as you can see below.
    # For example, `Nadia.send_message/3` takes as first argument
    # the ID of the chat you want to send this message. Using the
    # macro `send_message/2` defined at StaccaBot.Commander, it is
    # injected the proper ID at the function. Go take a look.
    #
    # See also: https://hexdocs.pm/nadia/Nadia.html
    send_message "Hello World!"
  end

  # You may split code to other modules using the syntax
  # "Module, :function" instead od "do..end"
  command "resto", Resto, :resto

  ###############
  # Restaurants #
  ###############

  callback_query_command "resto" do
    case update.callback_query.data do
      "/resto " <> resto ->
        Logger.debug "[+] Dispatching for " <> resto
        {:ok, _} = send_message "Choisissez une catégorie de plats",
          reply_markup: %Model.InlineKeyboardMarkup{
            inline_keyboard: [
              Resto.build_resto(resto),
            ]
          }
        answer_callback_query text: "Excellent choix."
      _ ->
        Logger.warn "Something fucked up. The user managed to enter another input starting with /resto…"
        answer_callback_query text: "srsly… :/"
    end
  end

  callback_query_command "catégorie" do
    case update.callback_query.data do
      "/catégorie pasta " <> resto ->
        msg = Resto.build(:pasta, String.to_atom(resto))
        send_message "La Pasta de #{resto} : "
        send_message(msg)
        answer_callback_query text: "Bien évidemment, on trouve la meilleur pasta chez " <> resto <> "…"
      "/catégorie pizza " <> resto ->
        msg = Resto.build(:pizza, String.to_atom(resto))
        send_message "La Pizza de #{resto} : "
        send_message msg
        answer_callback_query text: "Vous vous régalerez avec ces pizzas de chez " <> resto <> "…"
      "/catégorie vin " <> resto ->
        msg = Resto.build(:vin, String.to_atom(resto))
        send_message "Les Vins de #{resto} : "
        send_message msg
        answer_callback_query text: "Le vin coule à flots chez " <> resto <> "…"
      "/catégorie plats " <> resto ->
        msg = Resto.build(:plats, String.to_atom(resto))
        send_message "Les plats principaux de #{resto} : "
        send_message msg
        answer_callback_query text: "Enjaillez vos papilles chez " <> resto <> " !"
    end
  end

  #####################
  # Fin du restaurant #
  #####################


  # Advanced Stuff
  #
  # Now that you already know basically how this boilerplate works let me
  # introduce you to a cool feature that happens under the hood.
  #
  # If you are used to telegram bot API, you should know that there's more
  # than one path to fetch the current message chat ID so you could answer it.
  # With that in mind and backed upon the neat macro system and the cool
  # pattern matching of Elixir, this boilerplate automatically detectes whether
  # the current message is a `inline_query`, `callback_query` or a plain chat
  # `message` and handles the current case of the Nadia method you're trying to
  # use.
  #
  # If you search for `defmacro send_message` at StaccaBot.Commander, you'll see an
  # example of what I'm talking about. It just works! It basically means:
  # When you are with a callback query message, when you use `send_message` it
  # will know exatcly where to find it's chat ID. Same goes for the other kinds.

  inline_query_command "foo" do
    Logger.log :info, "Inline Query Command /foo"
    # Where do you think the message will go for?
    # If you answered that it goes to the user private chat with this bot,
    # you're right. Since inline querys can't receive nothing other than
    # Nadia.InlineQueryResult models. Telegram bot API could be tricky.
    send_message "This came from an inline query"
  end

  # Fallbacks

  # Rescues any unmatched callback query.
  callback_query do
    Logger.log :warn, "Did not match any callback query"

    answer_callback_query text: "Sorry, but there is no JoJo better than Joseph."
  end

  # Rescues any unmatched inline query.
  inline_query do
    Logger.log :warn, "Did not match any inline query"

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "Darude-Sandstorm Non non Biyori Renge Miyauchi Cover 1 Hour",
        thumb_url: "https://img.youtube.com/vi/yZi89iQ11eM/3.jpg",
        description: "Did you mean Darude Sandstorm?",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=yZi89iQ11eM",
        }
      }
    ]
  end

  # The `message` macro must come at the end since it matches anything.
  # You may use it as a fallback.
  command "help" do
    {:ok, _} = send_message help(), parse_mode: "html"
  end

  message do
    {:ok, _} = send_message help(), parse_mode: "html"
  end

  defp help() do
    """
    <b>Aide pour Staccato</b>
    <i>Si vous voulez les menus des restaurants que j'ai en mémoire, tapez : </i>
    <code>/resto</code>
    <i>Le reste suivra…</i>
    """
  end

end
