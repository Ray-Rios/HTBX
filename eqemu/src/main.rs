use hyper::service::{make_service_fn, service_fn};
use hyper::{Body, Method, Request, Response, Server, StatusCode};
use serde::{Deserialize, Serialize};
use std::convert::Infallible;
use std::net::SocketAddr;
use uuid::Uuid;

#[derive(Serialize, Deserialize)]
struct GameSession {
    id: String,
    user_id: String,
    status: String,
    created_at: String,
}

#[derive(Serialize, Deserialize)]
struct ApiResponse<T> {
    success: bool,
    data: Option<T>,
    message: String,
}

async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let response = match (req.method(), req.uri().path()) {
        (&Method::GET, "/api/status") => {
            let response = ApiResponse {
                success: true,
                data: Some(serde_json::json!({
                    "service": "eqemu_service",
                    "version": "0.1.0",
                    "status": "running",
                    "timestamp": chrono::Utc::now().to_rfc3339()
                })),
                message: "Service status retrieved".to_string(),
            };
            Response::builder()
                .status(StatusCode::OK)
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&response).unwrap()))
                .unwrap()
        }
        
        (&Method::POST, "/api/sessions") => {
            let session = GameSession {
                id: Uuid::new_v4().to_string(),
                user_id: "placeholder".to_string(),
                status: "active".to_string(),
                created_at: chrono::Utc::now().to_rfc3339(),
            };
            
            let response = ApiResponse {
                success: true,
                data: Some(session),
                message: "Game session created".to_string(),
            };
            
            Response::builder()
                .status(StatusCode::CREATED)
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&response).unwrap()))
                .unwrap()
        }
        
        _ => {
            let response = ApiResponse::<()> {
                success: false,
                data: None,
                message: "Not found".to_string(),
            };
            Response::builder()
                .status(StatusCode::NOT_FOUND)
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&response).unwrap()))
                .unwrap()
        }
    };

    Ok(response)
}

#[tokio::main]
async fn main() {
    let port = std::env::var("API_SERVICE_PORT")
        .unwrap_or_else(|_| "7000".to_string())
        .parse::<u16>()
        .unwrap_or(7000);
    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    
    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle_request))
    });

    let server = Server::bind(&addr).serve(make_svc);

    println!("🎮 EQEmu Service running on http://{}", addr);
    println!("🔍 Status API: http://{}/api/status", addr);

    if let Err(e) = server.await {
        eprintln!("Server error: {}", e);
    }
}