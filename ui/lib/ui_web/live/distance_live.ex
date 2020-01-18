defmodule UiWeb.DistanceLive do
  use Phoenix.LiveView

  @topic "distance"

  def render(assigns) do
    UiWeb.PageView.render("distance.html", assigns)
  end

  def mount(_, socket) do
    distance = 22
    UiWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :distance, distance)}
  end

  def handle_info({:reading, reading}, socket) when reading < 200 do
    {:noreply, assign(socket, :distance, reading)}
  end

  def handle_info({:reading, _}, socket), do:  {:noreply, socket}

end
