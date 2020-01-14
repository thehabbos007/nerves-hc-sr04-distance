defmodule Firmware.Sensor do
  require Logger

  def do_sensor_reading do
    :erlang.nif_error(:nif_not_loaded)
  end

  @on_load :load_nif
  def load_nif do
    nif_file = '#{:code.priv_dir(:firmware)}/sensor'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.warn("Failed to load NIF: #{inspect(reason)}")
    end
  end
end
