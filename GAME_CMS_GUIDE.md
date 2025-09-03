# Game CMS System Guide

## Overview

The Game CMS system provides a comprehensive content management solution for your MMO game, integrating seamlessly with your Phoenix application and UE5 pixel streaming setup. This system replaces mock data with real, persistent game data and provides full CRUD operations through both GraphQL API and a web-based admin interface.

## Architecture

### Database Schema
- **Characters**: Player avatars with stats, levels, equipment, and guild membership
- **Items**: Weapons, armor, consumables with detailed properties and effects
- **Quests**: Missions with rewards, prerequisites, and difficulty levels
- **Guilds**: Player organizations with leadership and member management
- **Chat Messages**: In-game communication system with multiple channels

### API Layer
- **GraphQL API**: Full CRUD operations for all game entities
- **Phoenix LiveView Admin**: Real-time web interface for content management
- **Authentication Integration**: Uses existing user system with role-based access

## Getting Started

### 1. Database Setup

Run the migration to create the game CMS tables:

```bash
docker-compose exec web mix ecto.migrate
```

### 2. Create Sample Data

Use the provided script to create sample game data:

```bash
docker-compose exec web mix run --no-start create_sample_data.exs
```

### 3. Access Admin Interface

Navigate to the admin panel:
- URL: `http://localhost:4000/game-cms-admin`
- Requires admin role on user account

## GraphQL API Reference

### Queries

#### Characters
```graphql
query {
  characters {
    id
    name
    class
    level
    experience
    health
    maxHealth
    mana
    maxMana
    gold
    currentZone
    strength
    agility
    intelligence
    vitality
    attackPower
    defense
    critChance
    attackSpeed
    userId
    guildId
    insertedAt
    updatedAt
  }
}

query {
  character(id: "1") {
    id
    name
    class
    level
    guild {
      name
      description
    }
  }
}

query {
  myCharacter {
    id
    name
    class
    level
  }
}
```

#### Items
```graphql
query {
  items {
    id
    name
    description
    itemType
    rarity
    levelRequirement
    price
    icon
    usable
    stackable
    maxStack
    attackPower
    defense
    healthBonus
    manaBonus
    strengthBonus
    agilityBonus
    intelligenceBonus
    vitalityBonus
    healthRestore
    manaRestore
    buffDuration
    buffEffect
  }
}

query {
  item(id: "1") {
    id
    name
    description
    rarity
    price
  }
}
```

#### Quests
```graphql
query {
  quests {
    id
    title
    description
    objective
    difficulty
    levelRequirement
    xpReward
    goldReward
    itemRewards
    prerequisites
    zone
    npcGiver
    active
    repeatable
    maxCompletions
  }
}

query {
  quest(id: "1") {
    id
    title
    description
    difficulty
    xpReward
    goldReward
  }
}
```

#### Guilds
```graphql
query {
  guilds {
    id
    name
    description
    level
    experience
    maxMembers
    guildType
    requirements
    active
    leaderId
    memberCount
    characters {
      id
      name
      class
      level
    }
  }
}

query {
  guild(id: "1") {
    id
    name
    description
    memberCount
    characters {
      name
      class
      level
    }
  }
}
```

#### Chat Messages
```graphql
query {
  chatMessages(limit: 50) {
    id
    message
    channel
    messageType
    userId
    characterId
    insertedAt
  }
}
```

#### Game Statistics
```graphql
query {
  gameCmsStats {
    totalCharacters
    totalItems
    totalQuests
    totalGuilds
    activeUsers
    recentEvents {
      id
      eventType
      message
      severity
      insertedAt
    }
  }
}
```

### Mutations

#### Character Management
```graphql
mutation {
  createCharacter(input: {
    name: "Hero Name"
    class: "Warrior"
    level: 1
    experience: 0
    health: 100
    maxHealth: 100
    mana: 50
    maxMana: 50
    gold: 100
    currentZone: "Starting Area"
    strength: 15
    agility: 10
    intelligence: 8
    vitality: 12
    userId: "user-uuid"
  }) {
    id
    name
    class
    level
  }
}

mutation {
  updateCharacter(id: "1", input: {
    level: 25
    experience: 15000
    gold: 5000
  }) {
    id
    name
    level
    experience
    gold
  }
}

mutation {
  deleteCharacter(id: "1") {
    id
    name
  }
}
```

#### Item Management
```graphql
mutation {
  createItem(input: {
    name: "Iron Sword"
    description: "A sturdy iron blade"
    itemType: "weapon"
    rarity: "common"
    levelRequirement: 5
    price: 100
    attackPower: 25
    usable: false
    stackable: false
  }) {
    id
    name
    itemType
    rarity
  }
}

mutation {
  updateItem(id: "1", input: {
    price: 150
    attackPower: 30
  }) {
    id
    name
    price
    attackPower
  }
}

mutation {
  deleteItem(id: "1") {
    id
    name
  }
}
```

#### Quest Management
```graphql
mutation {
  createQuest(input: {
    title: "Goblin Hunt"
    description: "Clear the goblin camp"
    objective: "Defeat 10 goblins"
    difficulty: "easy"
    levelRequirement: 5
    xpReward: 500
    goldReward: 100
    zone: "Forest"
    npcGiver: "Village Elder"
    active: true
    repeatable: false
  }) {
    id
    title
    difficulty
    xpReward
  }
}

mutation {
  updateQuest(id: "1", input: {
    xpReward: 750
    goldReward: 150
  }) {
    id
    title
    xpReward
    goldReward
  }
}

mutation {
  deleteQuest(id: "1") {
    id
    title
  }
}
```

#### Guild Management
```graphql
mutation {
  createGuild(input: {
    name: "Dragon Slayers"
    description: "Elite dragon hunting guild"
    level: 1
    maxMembers: 50
    guildType: "hardcore"
    requirements: "Level 20+"
    leaderId: "user-uuid"
  }) {
    id
    name
    guildType
    maxMembers
  }
}

mutation {
  updateGuild(id: "1", input: {
    level: 5
    maxMembers: 75
    experience: 10000
  }) {
    id
    name
    level
    experience
  }
}

mutation {
  deleteGuild(id: "1") {
    id
    name
  }
}
```

#### Chat System
```graphql
mutation {
  sendChatMessage(input: {
    message: "Hello, world!"
    channel: "global"
    messageType: "chat"
    characterId: "1"
  }) {
    id
    message
    channel
    insertedAt
  }
}
```

## Admin Interface Features

### Dashboard
- Overview of all game statistics
- Recent activity feed
- Quick access to all management sections

### Character Management
- View all characters with filtering and sorting
- Create new characters
- Edit character stats, levels, and properties
- Delete characters
- Assign characters to guilds

### Item Management
- Browse all items by type and rarity
- Create new items with full property sets
- Edit item stats and properties
- Delete items
- Preview item effects

### Quest Management
- View all quests by difficulty and zone
- Create new quests with rewards and prerequisites
- Edit quest objectives and rewards
- Toggle quest active status
- Delete quests

### Guild Management
- View all guilds with member counts
- Create new guilds
- Edit guild properties and requirements
- Manage guild membership
- Delete guilds

### Chat Monitoring
- View recent chat messages across all channels
- Filter by channel type
- Monitor for inappropriate content
- Delete messages if needed

## Integration with UE5

### Authentication
The system integrates with your existing user authentication. When a user logs into your UE5 game through the pixel streaming interface, their session is tied to their Phoenix user account.

### API Endpoints
Your UE5 game can make HTTP requests to the GraphQL endpoint:
- **URL**: `http://localhost:4000/api/graphql`
- **Method**: POST
- **Headers**: 
  - `Content-Type: application/json`
  - `Authorization: Bearer <user-token>` (if using token auth)

### Example UE5 Integration
```cpp
// Example HTTP request from UE5 to get character data
FString GraphQLQuery = TEXT("{\"query\":\"query { myCharacter { id name class level health mana gold } }\"}");
FString URL = TEXT("http://localhost:4000/api/graphql");

// Make HTTP request using UE5's HTTP module
// Process response and update game state
```

## Testing

### GraphQL API Testing
Use the provided PowerShell script to test all endpoints:

```powershell
.\test_game_cms_graphql.ps1
```

### Manual Testing
1. Access the admin interface at `http://localhost:4000/game-cms-admin`
2. Create sample data through the web interface
3. Test GraphQL queries using a tool like GraphiQL or Postman
4. Verify data persistence by refreshing the admin interface

## Security Considerations

### Authentication
- Admin interface requires user to have admin role
- GraphQL mutations require authenticated user
- User can only access their own character data (unless admin)

### Data Validation
- All inputs are validated at the schema level
- Database constraints prevent invalid data
- Proper error handling for all operations

### Rate Limiting
Consider implementing rate limiting for the GraphQL API to prevent abuse:
- Limit queries per user per minute
- Implement query complexity analysis
- Monitor for suspicious activity

## Performance Optimization

### Database Indexes
The migration includes proper indexes for:
- Character lookups by user and guild
- Item filtering by type and rarity
- Quest filtering by difficulty and zone
- Chat message ordering by timestamp

### Caching
Consider implementing caching for frequently accessed data:
- Character stats and equipment
- Item definitions
- Quest information
- Guild member lists

### Query Optimization
- Use database-level filtering instead of application-level
- Implement pagination for large result sets
- Use GraphQL field selection to minimize data transfer

## Troubleshooting

### Common Issues

1. **Migration Errors**
   - Ensure database is running
   - Check for existing table conflicts
   - Verify user permissions

2. **GraphQL Errors**
   - Check schema compilation
   - Verify resolver implementations
   - Ensure proper authentication

3. **Admin Interface Issues**
   - Verify user has admin role
   - Check LiveView configuration
   - Ensure proper routing

### Debugging

Enable detailed logging in your Phoenix configuration:
```elixir
config :logger, level: :debug
```

Monitor database queries:
```elixir
config :phoenix_app, PhoenixApp.Repo,
  log: :debug
```

## Future Enhancements

### Planned Features
- Real-time notifications for game events
- Advanced analytics and reporting
- Automated content moderation
- Integration with external game services
- Mobile admin interface
- Bulk data import/export tools

### Scalability Considerations
- Database sharding for large player bases
- Redis caching for session data
- CDN integration for static assets
- Microservice architecture for game systems

## Support

For issues or questions about the Game CMS system:
1. Check the troubleshooting section above
2. Review the Phoenix and GraphQL documentation
3. Examine the source code in the `lib/phoenix_app/game_cms/` directory
4. Test with the provided scripts and examples

The Game CMS system provides a solid foundation for managing your MMO game content and can be extended to meet your specific requirements as your game grows.