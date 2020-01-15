defmodule UiWeb.DistanceLive do
  use Phoenix.LiveView

  @topic "distance"

  def render(assigns) do
    UiWeb.PageView.render("distance.html", assigns)
  end

  def mount(_, socket) do
    temperature = 22
    UiWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_info({:reading, reading}, socket) do
    IO.puts("HANDLE BROADCAST: #{reading}")
    {:noreply, assign(socket, :temperature, reading)}
  end
end
