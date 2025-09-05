defmodule PhoenixAppWeb.HealthController do
  use PhoenixAppWeb, :controller

  def check(conn, _params) do
    # Basic health check - you can add more sophisticated checks here
    base_status = %{
      status: "ok",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      service: "phoenix_app",
      version: "1.0.0"
    }

    # Optional: Add database connectivity check
    health_status = try do
      PhoenixApp.Repo.query!("SELECT 1")
      Map.put(base_status, :database, "connected")
    rescue
      _ ->
        Map.put(base_status, :database, "disconnected")
    end

    conn
    |> put_status(:ok)
    |> json(health_status)
  end
end