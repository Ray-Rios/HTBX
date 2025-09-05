defmodule PhoenixAppWeb.Api.GameController do
  use PhoenixAppWeb, :controller
  alias PhoenixApp.Game

  # GET /api/game/profile
  def profile(conn, _params) do
    user = conn.assigns.current_user
    
    # Get or create player stats
    stats = Game.get_or_create_player_stats(user)
    
    # Get active session if any
    active_session = Game.get_active_session_for_user(user)
    
    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      user: %{
        id: user.id,
        name: user.name,
        email: user.email
      },
      stats: %{
        total_score: stats.total_score,
        total_playtime: stats.total_playtime,
        games_played: stats.games_played,
        highest_level: stats.highest_level,
        achievements: stats.achievements
      },
      active_session: if active_session do
        %{
          id: active_session.id,
          level: active_session.level,
          score: active_session.score,
          health: active_session.health,
          position: %{
            x: active_session.player_x,
            y: active_session.player_y,
            z: active_session.player_z
          }
        }
      else
        nil
      end
    })
  end

  # POST /api/game/session/start
  def start_session(conn, params) do
    user = conn.assigns.current_user
    
    case Game.create_game_session(user, params) do
      {:ok, session} ->
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          session: %{
            id: session.id,
            session_token: session.session_token,
            level: session.level,
            score: session.score,
            health: session.health
          }
        })
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          errors: format_changeset_errors(changeset)
        })
    end
  end

  # PUT /api/game/session/:id/update
  def update_session(conn, %{"id" => session_id} = params) do
    user = conn.assigns.current_user
    user_id = user.id
    
    # Ensure user owns this session
    case Game.get_game_session!(session_id) do
      %{user_id: ^user_id} = session ->
        case Game.update_game_session(session, params) do
          {:ok, updated_session} ->
            conn
            |> put_status(:ok)
            |> json(%{
              success: true,
              session: %{
                id: updated_session.id,
                level: updated_session.level,
                score: updated_session.score,
                health: updated_session.health,
                position: %{
                  x: updated_session.player_x,
                  y: updated_session.player_y,
                  z: updated_session.player_z
                }
              }
            })
          
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              success: false,
              errors: format_changeset_errors(changeset)
            })
        end
      
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{success: false, error: "Access denied"})
    end
  end

  # POST /api/game/session/:id/heartbeat
  def heartbeat(conn, %{"id" => session_id}) do
    user = conn.assigns.current_user
    user_id = user.id
    
    case Game.get_game_session!(session_id) do
      %{user_id: ^user_id} = session ->
        case Game.heartbeat_session(session) do
          {:ok, _session} ->
            conn
            |> put_status(:ok)
            |> json(%{success: true})
          
          {:error, _} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{success: false, error: "Failed to update heartbeat"})
        end
      
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{success: false, error: "Access denied"})
    end
  end

  # POST /api/game/event
  def create_event(conn, %{"event_type" => event_type} = params) do
    user = conn.assigns.current_user
    
    # Get active session
    case Game.get_active_session_for_user(user) do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{success: false, error: "No active game session"})
      
      session ->
        event_attrs = %{
          event_type: event_type,
          event_data: params["event_data"] || %{},
          client_timestamp: params["client_timestamp"]
        }
        
        case Game.create_game_event(session, user, event_attrs) do
          {:ok, event} ->
            conn
            |> put_status(:created)
            |> json(%{
              success: true,
              event: %{
                id: event.id,
                event_type: event.event_type,
                server_timestamp: event.server_timestamp
              }
            })
          
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              success: false,
              errors: format_changeset_errors(changeset)
            })
        end
    end
  end

  # GET /api/game/leaderboard
  def leaderboard(conn, params) do
    limit = String.to_integer(params["limit"] || "10")
    leaderboard = Game.get_leaderboard(limit)
    
    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      leaderboard: leaderboard
    })
  end

  # GET /api/game/stats
  def stats(conn, _params) do
    stats = Game.get_game_stats()
    
    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      stats: stats
    })
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end