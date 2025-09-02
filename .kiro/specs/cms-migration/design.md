# Design Document

## Overview

This design outlines the complete migration from the existing Phoenix/Elixir application to a modern KeystoneJS-based CMS system. KeystoneJS will serve as both the content management system and the primary API backend for the Unreal Engine 5 game, replacing the current Phoenix application entirely while maintaining integration with the existing Rust game service and pixel streaming infrastructure.

The new architecture will be significantly simpler, leveraging KeystoneJS's built-in features for authentication, GraphQL API generation, admin interface, and real-time capabilities, while maintaining the existing Docker-based deployment model.

## Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        UE5[UE5 Game Client]
        Browser[Web Browser]
        Admin[Admin Interface]
    end
    
    subgraph "KeystoneJS Application"
        KJS[KeystoneJS Server]
        GraphQL[Auto-Generated GraphQL API]
        REST[Auto-Generated REST API]
        AdminUI[Built-in Admin UI]
        Auth[Authentication System]
    end
    
    subgraph "Game Services"
        Rust[Rust Game Service]
        Pixel[Pixel Streaming]
    end
    
    subgraph "Data Layer"
        Postgres[(PostgreSQL Database)]
        Redis[(Redis Cache)]
    end
    
    UE5 --> GraphQL
    UE5 --> REST
    Browser --> Pixel
    Admin --> AdminUI
    
    KJS --> Postgres
    KJS --> Redis
    KJS --> Rust
    
    Rust --> Postgres
    Pixel --> Rust
```

### Technology Stack Replacement

**Before (Phoenix Stack):**
- Phoenix Framework (Elixir)
- Ecto ORM
- LiveView for real-time UI
- Guardian for JWT auth
- Absinthe for GraphQL
- Custom admin interfaces

**After (KeystoneJS Stack):**
- KeystoneJS 6 (Node.js/TypeScript)
- Prisma ORM (built-in)
- React-based Admin UI (built-in)
- Built-in authentication system
- Auto-generated GraphQL API
- Auto-generated REST API

## Components and Interfaces

### 1. KeystoneJS Core Application

**Purpose:** Central application server providing CMS, APIs, and authentication

**Key Features:**
- TypeScript-based configuration
- Automatic database schema generation
- Built-in admin interface
- Session-based authentication
- Role-based access control
- File upload handling
- Real-time subscriptions

**Configuration Structure:**
```typescript
// keystone.ts
import { config } from '@keystone-6/core';
import { lists } from './schema';
import { withAuth, session } from './auth';

export default withAuth(
  config({
    db: {
      provider: 'postgresql',
      url: process.env.DATABASE_URL,
    },
    lists,
    session,
    server: {
      cors: { origin: true, credentials: true },
      port: process.env.PORT || 3000,
    },
    graphql: {
      playground: process.env.NODE_ENV !== 'production',
      apolloStudioSandbox: true,
    },
    ui: {
      isAccessAllowed: (context) => !!context.session?.data,
    },
  })
);
```

### 2. Game Content Schema

**Purpose:** Define all game-related content types and their relationships

**Content Types:**
- Users (authentication and profiles)
- Characters (player character data)
- Items (game items, weapons, armor)
- Quests (game missions and objectives)
- Locations (game world areas)
- GameSessions (active player sessions)
- GameStats (player statistics and progress)

**Schema Example:**
```typescript
// schema/User.ts
import { list } from '@keystone-6/core';
import { text, password, checkbox, timestamp, relationship } from '@keystone-6/core/fields';

export const User = list({
  fields: {
    name: text({ validation: { isRequired: true } }),
    email: text({ validation: { isRequired: true }, isIndexed: 'unique' }),
    password: password({ validation: { isRequired: true } }),
    isAdmin: checkbox({ defaultValue: false }),
    gameProfile: relationship({ ref: 'GameProfile.user' }),
    gameSessions: relationship({ ref: 'GameSession.user', many: true }),
    createdAt: timestamp({ defaultValue: { kind: 'now' } }),
  },
});

// schema/GameProfile.ts
export const GameProfile = list({
  fields: {
    user: relationship({ ref: 'User.gameProfile' }),
    level: integer({ defaultValue: 1 }),
    experience: integer({ defaultValue: 0 }),
    health: integer({ defaultValue: 100 }),
    score: integer({ defaultValue: 0 }),
    positionX: float({ defaultValue: 0 }),
    positionY: float({ defaultValue: 0 }),
    positionZ: float({ defaultValue: 0 }),
    inventory: relationship({ ref: 'Item', many: true }),
    completedQuests: relationship({ ref: 'Quest', many: true }),
  },
});
```

### 3. API Layer

**GraphQL API (Auto-generated):**
- Full CRUD operations for all content types
- Relationship queries and mutations
- Real-time subscriptions
- Authentication-aware queries
- Field-level permissions

**REST API (Auto-generated):**
- RESTful endpoints for all content types
- JSON responses
- Standard HTTP methods
- Authentication via session cookies or API keys

**Custom API Extensions:**
```typescript
// Custom resolvers for game-specific logic
export const extendGraphqlSchema = graphQLSchemaExtension({
  typeDefs: `
    type Mutation {
      authenticateGameUser(email: String!, password: String!): AuthResult
      updatePlayerPosition(x: Float!, y: Float!, z: Float!): GameProfile
      completeQuest(questId: ID!): GameProfile
    }
  `,
  resolvers: {
    Mutation: {
      authenticateGameUser: async (root, { email, password }, context) => {
        // Custom game authentication logic
      },
      updatePlayerPosition: async (root, { x, y, z }, context) => {
        // Update player position in real-time
      },
    },
  },
});
```

### 4. Authentication System

**Built-in Session Management:**
- Cookie-based sessions for admin interface
- JWT tokens for API access
- Role-based access control
- Field-level permissions

**Game Authentication Integration:**
```typescript
// auth.ts
import { createAuth } from '@keystone-6/auth';
import { statelessSessions } from '@keystone-6/core/session';

const { withAuth } = createAuth({
  listKey: 'User',
  identityField: 'email',
  secretField: 'password',
  initFirstItem: {
    fields: ['name', 'email', 'password'],
    itemData: { isAdmin: true },
  },
});

const session = statelessSessions({
  maxAge: 60 * 60 * 24 * 30, // 30 days
  secret: process.env.SESSION_SECRET,
});
```

### 5. Integration with Rust Game Service

**Communication Pattern:**
- KeystoneJS serves as the primary data source
- Rust service calls KeystoneJS APIs for user data
- Real-time updates via webhooks or GraphQL subscriptions
- Shared database for game session data

**Integration Points:**
```typescript
// hooks/gameIntegration.ts
export const gameSessionHooks = {
  afterOperation: async ({ operation, item, context }) => {
    if (operation === 'create' || operation === 'update') {
      // Notify Rust game service of changes
      await notifyGameService(item);
    }
  },
};

async function notifyGameService(sessionData: any) {
  const gameServiceUrl = process.env.GAME_SERVICE_URL;
  await fetch(`${gameServiceUrl}/api/session-update`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(sessionData),
  });
}
```

## Data Models

### Core Game Entities

**User Management:**
```typescript
User {
  id: ID!
  name: String!
  email: String! @unique
  password: String!
  isAdmin: Boolean
  gameProfile: GameProfile
  createdAt: DateTime
  updatedAt: DateTime
}
```

**Game Profile:**
```typescript
GameProfile {
  id: ID!
  user: User!
  level: Int
  experience: Int
  health: Int
  score: Int
  positionX: Float
  positionY: Float
  positionZ: Float
  rotationX: Float
  rotationY: Float
  rotationZ: Float
  inventory: [Item!]!
  completedQuests: [Quest!]!
  isOnline: Boolean
  lastActive: DateTime
}
```

**Game Content:**
```typescript
Item {
  id: ID!
  name: String!
  description: Text
  type: ItemType
  rarity: Rarity
  stats: JSON
  image: CloudinaryImage
  price: Int
}

Quest {
  id: ID!
  title: String!
  description: Text!
  objectives: [QuestObjective!]!
  rewards: [Item!]!
  requiredLevel: Int
  isActive: Boolean
}

Location {
  id: ID!
  name: String!
  description: Text
  coordinates: JSON
  quests: [Quest!]!
  items: [Item!]!
}
```

### Database Schema Migration

**Migration Strategy:**
1. Create new KeystoneJS database schema
2. Export essential data from Phoenix (if any needs to be preserved)
3. Transform and import data using KeystoneJS migration scripts
4. Validate data integrity
5. Switch DNS/routing to new application

## Error Handling

### Application-Level Error Handling

**KeystoneJS Error Management:**
```typescript
// Error handling middleware
export const errorHandler = {
  onError: (error: Error, context: KeystoneContext) => {
    console.error('KeystoneJS Error:', error);
    
    // Log to external service
    if (process.env.NODE_ENV === 'production') {
      logToService(error, context);
    }
    
    return error;
  },
};
```

**API Error Responses:**
- GraphQL: Standard GraphQL error format
- REST: HTTP status codes with JSON error objects
- Game API: Custom error codes for game client handling

**Database Error Handling:**
- Prisma connection retry logic
- Transaction rollback on failures
- Data validation at schema level
- Referential integrity enforcement

### Game Integration Error Handling

**Rust Service Communication:**
```typescript
async function safeGameServiceCall(endpoint: string, data: any) {
  try {
    const response = await fetch(`${process.env.GAME_SERVICE_URL}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      timeout: 5000,
    });
    
    if (!response.ok) {
      throw new Error(`Game service error: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Game service communication failed:', error);
    // Continue operation without game service
    return null;
  }
}
```

## Testing Strategy

### Unit Testing
- Jest for TypeScript/Node.js code
- Test schema definitions and custom resolvers
- Mock external service calls
- Validate data transformations

### Integration Testing
- Test KeystoneJS API endpoints
- Validate GraphQL schema and queries
- Test authentication flows
- Verify game service integration

### End-to-End Testing
- Playwright for admin interface testing
- Game client API integration tests
- Real-time feature testing
- Performance testing under load

### Testing Environment
```typescript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  testMatch: ['**/__tests__/**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
  ],
};
```

## Deployment Architecture

### Docker Configuration

**New Docker Compose Structure:**
```yaml
services:
  keystone:
    build:
      context: .
      dockerfile: Dockerfile.keystone
    environment:
      - DATABASE_URL=postgresql://root@db:26257/keystone_app?sslmode=disable
      - REDIS_URL=redis://redis:6379
      - SESSION_SECRET=${SESSION_SECRET}
      - GAME_SERVICE_URL=http://game_service:8080
    ports:
      - "3000:3000"
    depends_on:
      - db
      - redis
    volumes:
      - ./uploads:/app/uploads

  game_service:
    # Existing Rust service configuration
    environment:
      - KEYSTONE_URL=http://keystone:3000
    
  db:
    # Existing CockroachDB configuration
    
  redis:
    # Existing Redis configuration
```

**KeystoneJS Dockerfile:**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

### Environment Configuration

**Production Environment Variables:**
```env
DATABASE_URL=postgresql://user:pass@host:port/keystone_app
REDIS_URL=redis://redis:6379
SESSION_SECRET=your-secret-key
GAME_SERVICE_URL=http://game_service:8080
NODE_ENV=production
PORT=3000
CLOUDINARY_CLOUD_NAME=your-cloud
CLOUDINARY_API_KEY=your-key
CLOUDINARY_API_SECRET=your-secret
```

### Health Checks and Monitoring

**Application Health Checks:**
```typescript
// health.ts
export const healthCheck = {
  '/health': async () => {
    const dbStatus = await checkDatabase();
    const redisStatus = await checkRedis();
    const gameServiceStatus = await checkGameService();
    
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      services: {
        database: dbStatus,
        redis: redisStatus,
        gameService: gameServiceStatus,
      },
    };
  },
};
```

This design provides a comprehensive foundation for migrating from Phoenix to KeystoneJS while maintaining all existing game functionality and improving the overall architecture with modern tooling and built-in CMS capabilities.