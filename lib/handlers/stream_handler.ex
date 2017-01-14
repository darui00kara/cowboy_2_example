defmodule Cowboy2Example.Handlers.StreamHandler do
  def init(req0, opts) do
    req = :cowboy_req.stream_reply(200, req0)
    :cowboy_req.stream_body("hoge\r\n", :nofin, req)
    :timer.sleep(1000)
    :cowboy_req.stream_body("hoge\r\n", :nofin, req)
    :timer.sleep(1000)
    :cowboy_req.stream_body("stream!\r\n", :fin, req)
    {:ok, req, opts}
  end
end
