defmodule ShuntWeb.PageController do
  use ShuntWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
