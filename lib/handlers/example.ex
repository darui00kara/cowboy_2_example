defmodule Cowboy2Example.Handlers.Example do
  def init(req0, state) do
    req = :cowboy_req.reply 200, %{"content-type" => "text/plain"}, "Example", req0
    {:ok, req, state}
  end
end
