defmodule ElixirServer.Clients do
  @table :clients_table

  def welcome_client(name, socket, transport) do
    members = :ets.match_object(@table, {:_, :"$1", :_})
    {:ok, {ip, port}} = :inet.peername(socket)
    list = for {sock, name_new, trans} <- members, true do
      send_indie_message(
        sock,
        trans,
        PoisonIvy.welcome_message_all(
          %{
            "name" => name,
            "ip" => ip
                    |> Tuple.to_list
                    |> Enum.join("."),
            "port" => port
          }
        )
      )
      {:ok, {ip2, port2}} = :inet.peername(sock)
      %{
        "name" => name_new,
        "ip" => ip2
                |> Tuple.to_list
                |> Enum.join("."),
        "port" => port2
      }
    end
    IO.inspect PoisonIvy.welcome_message_self(list,ip)
    send_indie_message(socket, transport, PoisonIvy.welcome_message_self(list,ip))
    :ets.insert(@table, {socket, name, transport})
  end

  def goodbye_client(socket) do
    [{_, goner, _}] = :ets.lookup(@table, socket)
    :ets.delete(@table, socket)
    send_msg_to_all(PoisonIvy.goodbye_message(goner))
  end

  def send_msg(socket, message, message_id, receiver) do
    [{_, sender, transport}] = :ets.lookup(@table, socket)
    [{s, _, t}] = :ets.match_object(@table, {:"$1", receiver, :"$3"})
    send_indie_message(socket, transport, PoisonIvy.message_sent(message_id))
    send_indie_message(s, t, PoisonIvy.message_received(message, sender))
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