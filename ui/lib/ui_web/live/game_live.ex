defmodule UiWeb.GameLive do
  use Phoenix.LiveView
  import SMA

  @topic "distance"
  @min 4
  @max 50
  @sma_window 4

  def render(assigns) do
    UiWeb.PageView.render("game.html", assigns)
  end

  def mount(_, socket) do
    UiWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:distance_list, List.duplicate(0, @sma_window))
      |> assign(:game_state, :not_started)
      |> assign(:distance, 0)
      |> assign(:target, 50)
      |> assign(:points, 0)
      |> assign(:round, 0)
      |> assign(:timer, nil)

    {:ok, socket}
  end

  def game_round_assigns(socket) do
    round = socket.assigns[:round]
    timer = Process.send_after(self(), :round_end, 3_000)

    socket
      |> assign(:distance_list, List.duplicate(0, @sma_window))
      |> assign(:distance, 0)
      |> assign(:target, :rand.uniform(100))
      |> assign(:round, round + 1)
      |> assign(:timer, timer)
  end

  def handle_event("start_game", _value, socket) do
    socket =
      game_round_assigns(socket)
      |> assign(:game_state, :started)
      |> assign(:round, 0)
      |> assign(:points, 0)

    {:noreply, socket}
  end

  def handle_info(:round_end, %{assigns: %{round: round_num}} = socket) when round_num >= 10 do
    socket = calculate_new_points(socket)
    {:noreply, assign(socket, :game_state, :over)}
  end

  def handle_info(:round_end, socket) do
    socket =
      socket
      |> calculate_new_points()
      |> game_round_assigns()

    {:noreply, socket}
  end

  def handle_info({:reading, reading}, socket) do
    value = map_to_percentage(reading)
    percentages = if reading < 200 do [value | socket.assigns[:distance_list]] else socket.assigns[:distance_list] end
    {:noreply, set_percentages(socket, percentages)}
  end

  def set_percentages(socket, percentages) do
    percentages =
      if(length(percentages) > @sma_window * 2) do
        Enum.take(percentages, @sma_window)
      else
        percentages
      end

    socket
    |> assign(:distance_list, percentages)
    |> assign(:distance, hd(sma(percentages, @sma_window)))
  end

  def map_to_percentage(reading) when reading < @min, do: 0
  def map_to_percentage(reading), do: min(reading / @max * 100, 100)

  def calculate_new_points(
        %{assigns: %{points: points, distance: distance, target: target}} = socket
      ) do
    new_points = points + 100 - abs(target - distance)
    assign(socket, :points, round(new_points))
  end
end
