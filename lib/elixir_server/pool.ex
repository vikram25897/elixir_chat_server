defmodule ElixirServer.Pool do
  use GenServer
  require Logger
  @behaviour :ranch_protocol

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    case Poison.decode(data) do
      {:ok, %{"name" => name}} -> ElixirServer.Clients.welcome_client(name,socket,transport)
      {:ok, %{"message" => message,"message_id"=>message_id}} -> ElixirServer.Clients.send_msg(socket,message,message_id)
      result -> transport.send(socket,"Some Error")
    end
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    ElixirServer.Clients.goodbye_client(socket)
    transport.close(socket)
    {:stop, :normal, state}
  end
end
