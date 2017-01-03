defmodule Cowboy2Example.Handlers.ExampleHandler do
  def init(req, opts) do
    {:cowboy_rest, req, opts}
  end

  def content_types_provided(req, state) do
    {
      [{"text/html", :html_example},
       {"application/json", :json_example},
       {"text/plain", :text_example}],
       req, state
    }
  end

  def html_example(req, state) do
    body = """
      <html>
        <head>
          <meta charset=\"utf-8\">
        	<title>REST Example</title>
        </head>
        <body>
          <h1>REST Example!!</h1>
        </body>
      </html>
    """

    {body, req, state}
  end

  def json_example(req, state) do
    body = "{\"rest\": \"Example!!\"}"

    {body, req, state}
  end

  def text_example(req, state) do
    {"REST Example as text!!", req, state}
  end

  #def init(req0, state) do
  #  req = :cowboy_req.reply 200, %{"content-type" => "text/plain"}, "Example", req0
  #  {:ok, req, state}
  #end
end
