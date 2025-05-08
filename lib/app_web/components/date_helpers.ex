defmodule AppWeb.DateHelpers do
  import Timex

  def format_datetime(datetime) do
    Timex.format!(datetime, "{Mshort} {D}, {YYYY} at {h24}:{m}")
  end

  def relative_time(datetime) do
    Timex.format!(datetime, "{relative}", :relative)
  end
end
