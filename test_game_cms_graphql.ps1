# Test Game CMS GraphQL API
$baseUrl = "http://localhost:4000"

Write-Host "Testing Game CMS GraphQL API..." -ForegroundColor Green

# Test 1: Get all characters
Write-Host "`n1. Testing characters query..." -ForegroundColor Yellow
$charactersQuery = @{
    query = "query { characters { id name class level experience health mana gold currentZone } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/graphql" -Method POST -Body $charactersQuery -ContentType "application/json"
    Write-Host "Characters Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Get all items
Write-Host "`n2. Testing items query..." -ForegroundColor Yellow
$itemsQuery = @{
    query = "query { items { id name description itemType rarity levelRequirement price } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/graphql" -Method POST -Body $itemsQuery -ContentType "application/json"
    Write-Host "Items Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Get all quests
Write-Host "`n3. Testing quests query..." -ForegroundColor Yellow
$questsQuery = @{
    query = "query { quests { id title description difficulty levelRequirement xpReward goldReward } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/graphql" -Method POST -Body $questsQuery -ContentType "application/json"
    Write-Host "Quests Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Get all guilds
Write-Host "`n4. Testing guilds query..." -ForegroundColor Yellow
$guildsQuery = @{
    query = "query { guilds { id name description level experience maxMembers guildType } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/graphql" -Method POST -Body $guildsQuery -ContentType "application/json"
    Write-Host "Guilds Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Create a new character (mutation)
Write-Host "`n5. Testing create character mutation..." -ForegroundColor Yellow
$createCharacterMutation = @{
    query = "mutation { createCharacter(input: { name: `"Test Hero`", class: `"Warrior`", level: 1 }) { id name class level } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/graphql" -Method POST -Body $createCharacterMutation -ContentType "application/json"
    Write-Host "Create Character Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nGame CMS GraphQL API testing completed!" -ForegroundColor Green