defmodule PhoenixAppWeb.HealthController do
  use PhoenixAppWeb, :controller

  def check(conn, _params) do
    # Basic health check - you can add more sophisticated checks here
    health_status = %{
      status: "ok",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      service: "phoenix_app",
      version: "1.0.0"
    }

    # Optional: Add database connectivity check
    try do
      PhoenixApp.Repo.query!("SELECT 1")
      health_status = Map.put(health_status, :database, "connected")
    rescue
      _ ->
        health_status = Map.put(health_status, :database, "disconnected")
    end

    conn
    |> put_status(:ok)
    |> json(health_status)
  end
end