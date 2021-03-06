defmodule Firmware.SensorServer do
  use GenServer
  alias Firmware.Sensor

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    Sensor.init_sensor()
    schedule_reading()
    {:ok, -1.0}
  end

  def handle_info(:pub_reading, state) do
    {:ok, reading} = Sensor.do_sensor_reading()
    Phoenix.PubSub.broadcast(Nerves.PubSub, "distance", {:reading, reading})
    schedule_reading()
    {:noreply, state}
  end

  defp schedule_reading(), do: Process.send_after(self(), :pub_reading, 100)

end
