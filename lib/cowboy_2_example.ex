defmodule Cowboy2Example do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    dispatch = :cowboy_router.compile routes
    {:ok, _} = :cowboy.start_clear :http, 100, [{:port, 4000}], %{env: %{dispatch: dispatch}}

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Cowboy2Example.Worker.start_link(arg1, arg2, arg3)
      # worker(Cowboy2Example.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cowboy2Example.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp routes do
    [{:_, [{"/", Cowboy2Example.Handlers.ExampleHandler, []},
           {"/get-parameter", Cowboy2Example.Handlers.GetParameterHandler, []},
           {"/post-parameter", Cowboy2Example.Handlers.PostParameterHandler, []},
           {"/upload-top", :cowboy_static, {:priv_file, :cowboy_2_example, "index.html"}},
           {"/upload", Cowboy2Example.Handlers.UploadHandler, []}]}]
  end
end
