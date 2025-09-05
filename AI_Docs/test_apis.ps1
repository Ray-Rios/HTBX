# Test API endpoints
Write-Host "Testing Phoenix App APIs..." -ForegroundColor Green

# Test GraphQL endpoint
Write-Host "`n1. Testing GraphQL endpoint..." -ForegroundColor Yellow
try {
    $body = @{
        query = "{ __schema { types { name } } }"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/graphql" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ GraphQL endpoint is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ GraphQL endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Game Register API
Write-Host "`n2. Testing Game Register API..." -ForegroundColor Yellow
try {
    $body = @{
        email = "test@example.com"
        password = "password123"
        name = "Test User"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/game/register" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ Game Register API is working (Status: $($response.StatusCode))" -ForegroundColor Green
    $result = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($result.message)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Game Register API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Game Login API
Write-Host "`n3. Testing Game Login API..." -ForegroundColor Yellow
try {
    $body = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/game/login" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ Game Login API is working (Status: $($response.StatusCode))" -ForegroundColor Green
    $result = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($result.message)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Game Login API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Web Login
Write-Host "`n4. Testing Web Login page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4000/login" -Method GET -ErrorAction Stop
    Write-Host "✅ Web Login page is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Web Login page failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 API Testing Complete!" -ForegroundColor Green