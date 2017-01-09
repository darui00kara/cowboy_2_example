defmodule Cowboy2Example.Handlers.GetParameterHandler do
  def init(req0, opts) do
    method = :cowboy_req.method(req0)
    %{echo: echo} = :cowboy_req.match_qs([{:echo, [], :undefined}], req0)
    req = echo(method, echo, req0)
    {:ok, req, opts}
  end

  defp echo("GET", :undefined, req) do
    :cowboy_req.reply(400, %{}, "Missing echo parameter.", req)
  end
  defp echo("GET", echo, req) do
    :cowboy_req.reply(200,
                      %{"content-type" => "text/plain; charset=utf-8"},
                      echo, req)
  end
  defp echo(_, _, req) do
    :cowboy_req.reply(405, req)
  end
end
