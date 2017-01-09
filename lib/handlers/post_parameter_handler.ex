defmodule Cowboy2Example.Handlers.PostParameterHandler do
  def init(req0, opts) do
    method = :cowboy_req.method(req0)
    hasBody = :cowboy_req.has_body(req0)
    req = maybe_echo(method, hasBody, req0)
    {:ok, req, opts}
  end

  defp maybe_echo("POST", true, req0) do
    {:ok, postVals, req} = :cowboy_req.read_urlencoded_body(req0)
    val = :proplists.get_value("echo", postVals)
    echo(val, req)
  end
  defp maybe_echo("POST", false, req) do
    :cowboy_req.reply(400, [], "Missing body", req)
  end
  defp maybe_echo(_, _, req) do
    :cowboy_req.reply(405, req)
  end

  defp echo(:undefined, req) do
    :cowboy_req.reply(400, [], "Missing echo parameter", req)
  end
  defp echo(message, req) do
    :cowboy_req.reply(200,
                      %{"content-type" => "text/plain; charset=utf-8"},
                      message, req)
  end
end
