defmodule UiWeb.GameLive do
    use Phoenix.LiveView

    @topic "distance"
    @min 5
    @max 50

    def render(assigns) do
        UiWeb.PageView.render("game.html", assigns)
    end

    def mount(_, socket) do
      temperature = 1.1
      UiWeb.Endpoint.subscribe(@topic)
      {:ok, assign(socket, :distance_percentage, temperature)}
    end

    def handle_info({:reading, reading}, socket) do
      value = map_to_percentage(reading)
      {:noreply, assign(socket, :distance_percentage, value)}
    end

    def map_to_percentage(reading) when reading < @min, do: 0
    def map_to_percentage(reading), do: min(reading/@max*100, 100)
end
