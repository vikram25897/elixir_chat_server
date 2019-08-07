defmodule ElixirServer.Clients do
  @table :clients_table

  def welcome_client(name, socket, transport) do
    members = :ets.match_object(@table, {:_, :"$1", :_})
    list = for {socket, name_new, transport} <- members, true do
      send_indie_message(socket, transport, PoisonIvy.welcome_message_all(name))
      name_new
    end
    send_indie_message(socket, transport, PoisonIvy.welcome_message_self(list))
    :ets.insert(@table, {socket, name, transport})
  end

  def goodbye_client(socket) do
    [{_, goner, _}] = :ets.lookup(@table, socket)
    :ets.delete(@table, socket)
    send_msg_to_all(PoisonIvy.goodbye_message(goner))
  end

  def send_msg(socket, message, message_id) do
    [{_, sender, _}] = :ets.lookup(@table, socket)
    list = :ets.match_object(@table, {:"$1", :"$2", :"$3"})
    Enum.each list, fn ({sock, _, transport}) ->
      cond do
        sock == socket -> send_indie_message(socket, transport, PoisonIvy.message_sent(message_id))
        true -> send_indie_message(sock, transport, PoisonIvy.message_received(message, sender))
      end
    end
  end

  def send_msg_to_all(message) do
    list = :ets.match_object(@table, {:_, :_, :_})
    Enum.each list, fn ({sock, _, transport}) ->
      transport.send(sock, message)
    end
  end

  def send_indie_message(socket, transport, message) do
    transport.send(socket, message)
  end
end