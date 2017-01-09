# Cowboy基礎の基礎

## Goal

- Elixir+Cowboy(2系)でHello World(text/plain)を表示する
- PlugからCowboyを使って、起動からリクエストを処理するまでのフローを眺める (Code Reading)

## Foreword

お久しぶりです。みなさん。
2016年冬コミ(C91)で原稿とともに人権を落とした敗北主義者です。

今回は、原稿とはあまり関係ない部分をやっていきたいと思います。
(副声音：どうにも原稿を書くモチベーションが上がらないので息抜きさせてください！)

内容としては、Cowboyで一番基本的な使い方をやることとPlugからの流れを追うことです。(何番煎じ？)
それでは、楽しんでいただけたら幸いです。

## Dev-Environment

開発環境は下記のとおりです。

- OS: MacOS X v10.11.6
- Erlang: Eshell V8.2, OTP-Version 19
  * Cowboy: v2.0.0-pre4
- Elixir: v1.3.4
  * Plug: v1.3.0

## Body

### Hello from the cowboy

#### Create elixir project & Install package

##### Example:

```cmd
$ mix new --sup cowboy_2_example
$ cd cowboy_2_example
$ mix test
```

##### File: mix.exs

```elixir
defmodule Cowboy2Example.Mixfile do
  ...

  def application do
    [applications: [:logger, :cowboy],
     mod: {Cowboy2Example, []}]
  end

  defp deps do
    [{:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.4"}]
  end
end
```

##### Example:

```cmd
$ mix deps.get
$ mix compile
```

#### Application & Supervisor setup

##### File: lib/cowboy_2_example.ex

```elixir
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
    [{:_, [{"/", Cowboy2Example.Handlers.ExampleHandler, []}]}]
  end
end
```

#### Create Handler

##### Example:

```cmd
$ mkdir lib/handlers
$ touch lib/handlers/example_handler.ex
```

##### File: lib/handlers/example_handler.ex

```elixir
defmodule Cowboy2Example.Handlers.ExampleHandler do
  def init(req0, state) do
    req = :cowboy_req.reply 200, %{"content-type" => "text/plain"}, "Example", req0
    {:ok, req, state}
  end
end
```

#### Hello World!

##### Example:

```cmd
$ iex -S mix
```

##### Access URL: http://localhost:4000

#### Add HTML & JSON response

##### File: lib/handlers/example_handler.ex

```elixir
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
end
```

- JSON

```cmd
$ curl -i -H "Accept: application/json" http://localhost:4000
HTTP/1.1 200 OK
content-length: 21
content-type: application/json
date: Tue, 03 Jan 2017 13:34:08 GMT
server: Cowboy
vary: accept

{"rest": "Example!!"}
```

- text

```cmd
$ curl -i -H "Accept: text/plain" http://localhost:4000
HTTP/1.1 200 OK
content-length: 22
content-type: text/plain
date: Tue, 03 Jan 2017 13:34:23 GMT
server: Cowboy
vary: accept

REST Example as text!!
```

- HTML

```cmd
$ curl -i -H "Accept: text/css" http://localhost:4000
HTTP/1.1 406 Not Acceptable
content-length: 0
date: Tue, 03 Jan 2017 13:34:42 GMT
server: Cowboy
```

- HTML(use browser)

##### Access URL: http://localhost:4000

### Cowboy to Plug flow

CowboyからPlugのフローを眺めていきましょう。
(読むのはPlugのソースです。Cowboyのソースは・・・Erlangできないんでわからないです！)

まずは、アプリケーションの起動対象が書いてあるmix.exsから追っていきましょう。

```elixir
plug/mix.exs

def application do
  [applications: [:crypto, :logger, :mime],
   mod: {Plug, []}]
end
```

```elixir
plug/mix.exs

def deps do
  [{:mime, "~> 1.0"},
   {:cowboy, "~> 1.0.1 or ~> 1.1", optional: true},
   {:ex_doc, "~> 0.12", only: :docs},
   {:inch_ex, ">= 0.0.0", only: :docs},
   {:hackney, "~> 1.2.0", only: :test}]
end
```

利用しているCowboyはv1.0.1かv1.1のようです。
起動しているアプリケーションのモジュールはPlugですね。
次は、Plugを追いましょう。

```elixir
plug/lib/plug.ex

def start(_type, _args) do
  Logger.add_translator {Plug.Adapters.Translator, :translate}
  Plug.Supervisor.start_link()
end
```

start/2の中で起動しているSupervisorはPlug.Supervisorですね。
(さくさく進みますね〜)

```elixir
plug/lib/plug/supervisor.ex

def start_link() do
  Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
end
```

```elixir
plug/lib/plug/supervisor.ex

def init(:ok) do
  import Supervisor.Spec

  children = [
    worker(Plug.Upload, [])
  ]

  Plug.Keys = :ets.new(Plug.Keys, [:named_table, :public, read_concurrency: true])
  supervise(children, strategy: :one_for_one)
end
```

さてさて、workerはPlug.Uploadのみ・・・だと！？
どうやらSupervisorまでではCowboyの「か」の字も出てこないようですね。

さて、ここからどうやって追いましょうか・・・。
そういえばPlug+Cowboyで以前に使った時は、起動するとき何かメソッドで実行していたはずです。
http/3だったかな？それを探しましょう。どこだ〜

```elixir
plug/lib/plug/adapters/cowboy.ex

def http(plug, opts, cowboy_options \\ []) do
  run(:http, plug, opts, cowboy_options)
end
```

余談ですがHTTPSを使うなら、こちらになるみたいですね。

```elixir
plug/lib/plug/adapters/cowboy.ex

def https(plug, opts, cowboy_options \\ []) do
  Application.ensure_all_started(:ssl)
  run(:https, plug, opts, cowboy_options)
end
```

それと、下記のメソッドを使ってworkerに追加すればできるみたいです。

```elixir
plug/lib/plug/adapters/cowboy.ex

def child_spec(scheme, plug, opts, cowboy_options \\ []) do
  [ref, nb_acceptors, trans_opts, proto_opts] = args(scheme, plug, opts, cowboy_options)
  ranch_module = case scheme do
    :http  -> :ranch_tcp
    :https -> :ranch_ssl
  end
  :ranch.child_spec(ref, nb_acceptors, ranch_module, trans_opts, :cowboy_protocol, proto_opts)
end
```

本筋に戻りましょう。とりあえず、cowboy.exとそのままの名前でありましたね。
http/3内でrun/4を呼び出しています。run/4に行きましょう。

```elixir
plug/lib/plug/adapters/cowboy.ex

defp run(scheme, plug, opts, cowboy_options) do
  case Application.ensure_all_started(:cowboy) do
    {:ok, _} ->
      :ok
    {:error, {:cowboy, _}} ->
      raise "could not start the cowboy application. Please ensure it is listed " <>
            "as a dependency both in deps and application in your mix.exs"
  end
  apply(:cowboy, :"start_#{scheme}", args(scheme, plug, opts, cowboy_options))
end
```

内容としては、Cowboyが起動しているか確認しているのと:cowboyの起動用メソッドを呼び出しているようです。
ここで終わってしまうのでしょうか？Cowboyに対して用意するHandlerとかはどこに・・・
さきほど出した"Hello World"のソースを思い出してみましょう。
どうやってHandlerを指定していたでしょうか？

```elixir
Example

defmodule Cowboy2Example do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    dispatch = :cowboy_router.compile routes
    {:ok, _} = :cowboy.start_clear :http, 100, [{:port, 4000}], %{env: %{dispatch: dispatch}}

    ...
  end

  defp routes do
    [{:_, [{"/", Cowboy2Example.Handlers.ExampleHandler, []}]}]
  end
end
```

そうそうルーティングで指定して、その内容を起動用のメソッドに渡していますね。(:dispatchがキー)
先ほどのソースならapplyしているときのargs/4が怪しいです。見にいきましょう。

```elixir
plug/lib/plug/adapters/cowboy.ex

def args(scheme, plug, opts, cowboy_options) do
  {cowboy_options, non_keyword_options} =
    Enum.partition(cowboy_options, &is_tuple(&1) and tuple_size(&1) == 2)

  cowboy_options
  |> Keyword.put_new(:max_connections, 16_384)
  |> Keyword.put_new(:ref, build_ref(plug, scheme))
  |> Keyword.put_new(:dispatch, cowboy_options[:dispatch] || dispatch_for(plug, opts))
  |> normalize_cowboy_options(scheme)
  |> to_args(non_keyword_options)
end
```

cowboyのオプションに分解してますね・・・。ビンゴ！見事:dispatchキーを見つけました。
さてさて次はdispatch_for/2ですね。

```elixir
plug/lib/plug/adapters/cowboy.ex

defp dispatch_for(plug, opts) do
  opts = plug.init(opts)
  [{:_, [{:_, Plug.Adapters.Cowboy.Handler, {plug, opts}}]}]
end
```

よしよし、ようやっとHandlerを見つけたぞ！
このモジュールを追っていきます。
いくつか関数がありますが、まぁinit/3から。

```elixir
plug/lib/plug/adapters/cowboy/handler.ex

def init({transport, :http}, req, {plug, opts}) when transport in [:tcp, :ssl] do
  {:upgrade, :protocol, __MODULE__, req, {transport, plug, opts}}
end
```

あぁ、Cowboyのプロトコルアップグレードですね。
参考: [Cowboy User Guide(1.0) - Protocol upgrades](https://ninenines.eu/docs/en/cowboy/1.0/guide/upgrade_protocol/)

なら次は、upgrade/4です。

```elixir
plug/lib/plug/adapters/cowboy/handler.ex

@connection Plug.Adapters.Cowboy.Conn
@already_sent {:plug_conn, :sent}
```

```elixir
plug/lib/plug/adapters/cowboy/handler.ex

def upgrade(req, env, __MODULE__, {transport, plug, opts}) do
  conn = @connection.conn(req, transport)
  try do
    %{adapter: {@connection, req}} =
      conn
      |> plug.call(opts)
      |> maybe_send(plug)

    {:ok, req, [{:result, :ok} | env]}
  catch
    :error, value ->
      stack = System.stacktrace()
      exception = Exception.normalize(:error, value, stack)
      reason = {{exception, stack}, {plug, :call, [conn, opts]}}
      terminate(reason, req, stack)
    :throw, value ->
      stack = System.stacktrace()
      reason = {{{:nocatch, value}, stack}, {plug, :call, [conn, opts]}}
      terminate(reason, req, stack)
    :exit, value ->
      stack = System.stacktrace()
      reason = {value, {plug, :call, [conn, opts]}}
      terminate(reason, req, stack)
  after
    receive do
      @already_sent -> :ok
    after
      0 -> :ok
    end
  end
end
```

おおっと、長いな・・・。細かいところは省きましょう。メインの流れだけ追います。
リクエストをConnに分解(?)しているところから。

```elixir
plug/lib/plug/adapters/cowboy/conn.ex

def conn(req, transport) do
  {path, req} = :cowboy_req.path req
  {host, req} = :cowboy_req.host req
  {port, req} = :cowboy_req.port req
  {meth, req} = :cowboy_req.method req
  {hdrs, req} = :cowboy_req.headers req
  {qs, req}   = :cowboy_req.qs req
  {peer, req} = :cowboy_req.peer req
  {remote_ip, _} = peer

  %Plug.Conn{
    adapter: {__MODULE__, req},
    host: host,
    method: meth,
    owner: self(),
    path_info: split_path(path),
    peer: peer,
    port: port,
    remote_ip: remote_ip,
    query_string: qs,
    req_headers: hdrs,
    request_path: path,
    scheme: scheme(transport)
  }
end
```

分解してPlug.Connに入れ直しているだけですね。
call/2はいいとして、maybe_send/2は確認しておきましょう。

```elixir
plug/lib/plug/adapters/cowboy/handler.ex

defp maybe_send(%Plug.Conn{state: :unset}, _plug),      do: raise Plug.Conn.NotSentError
defp maybe_send(%Plug.Conn{state: :set} = conn, _plug), do: Plug.Conn.send_resp(conn)
defp maybe_send(%Plug.Conn{} = conn, _plug),            do: conn
defp maybe_send(other, plug) do
  raise "Cowboy adapter expected #{inspect plug} to return Plug.Conn but got: #{inspect other}"
end
```

ふむふむ、この先があるのは:stateが:setか・・・Plug.Conn.send_resp/1へ。

```elixir
plug/lib/plug/conn.ex

def send_resp(conn)

def send_resp(%Conn{state: :unset}) do
  raise ArgumentError, "cannot send a response that was not set"
end

def send_resp(%Conn{adapter: {adapter, payload}, state: :set, owner: owner} = conn) do
  conn = run_before_send(conn, :set)
  {:ok, body, payload} = adapter.send_resp(payload, conn.status, conn.resp_headers, conn.resp_body)
  send owner, @already_sent
  %{conn | adapter: {adapter, payload}, resp_body: body, state: :sent}
end

def send_resp(%Conn{}) do
  raise AlreadySentError
end
```

そろそろ疲れてきたよ〜＞＜
しかし、もう少しだけ頑張ろう！

3つ目かな。run_before_send/2は情報を取得しているだけだからいいや。
adapter.send_resp/4の部分だな。adapterはPlug.Adapters.Cowboy.Connで生成しているConnにありましたね。

```elixir
plug/lib/plug/adapters/cowboy/conn.ex

%Plug.Conn{
  adapter: {__MODULE__, req},
  host: host,
  method: meth,
  owner: self(),
  path_info: split_path(path),
  peer: peer,
  port: port,
  remote_ip: remote_ip,
  query_string: qs,
  req_headers: hdrs,
  request_path: path,
  scheme: scheme(transport)
}
```

やっと・・・やっとたどり着いたぞー。
:cowboy_req.reply/4をやっと確認できました。

```elixir
plug/lib/plug/adapters/cowboy/conn.ex

def send_resp(req, status, headers, body) do
  status = Integer.to_string(status) <> " " <> Plug.Conn.Status.reason_phrase(status)
  {:ok, req} = :cowboy_req.reply(status, headers, body, req)
  {:ok, nil, req}
end
```

もうだめ・・・orz
他にもまだ何かあるかもしれませんが、とりあえずここまでで大丈夫でしょう。

## Afterword

凡百プログラマの私ではここまでです。
では、またお会いすることがあればノシ

## Bibliography

参考にした書籍及びサイトの一覧は下記になります。

[Github - ninenines/cowboy](https://github.com/ninenines/cowboy)
[Github - elixir-lang/plug](https://github.com/elixir-lang/plug)
[Cowboy User Guide(1.0) - Protocol upgrades](https://ninenines.eu/docs/en/cowboy/1.0/guide/upgrade_protocol/)
[Cowboy User Guide(2.0)](https://ninenines.eu/docs/en/cowboy/2.0/guide/)


