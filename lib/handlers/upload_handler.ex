defmodule Cowboy2Example.Handlers.UploadHandler do
  def init(req, opts) do
    {:ok, headers, req2} = :cowboy_req.read_part(req)
    {:ok, data, req3} = :cowboy_req.read_part_body(req2)
    {:file, "inputfile", filename, content_type, _te}
      = :cow_multipart.form_data(headers)
    :io.format("Received file ~p of content-type ~p as follow:~n~p~n~n",
             [filename, content_type, data])
    {:ok, req3, opts}
  end
end
