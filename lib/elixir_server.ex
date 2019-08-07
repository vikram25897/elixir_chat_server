defmodule ElixirServer.Application do
  use Application
  def start(_type,_args) do
    :ets.new(:clients_table, [:named_table, :ordered_set, :public])
    :ranch.start_listener(:server, :ranch_tcp, [{:port, 6000}], ElixirServer.Pool, [])
  end
end
