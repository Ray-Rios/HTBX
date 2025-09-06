# EQEmu Integration Documentation

This document explains how the Phoenix web application integrates with EQEmu server authentication and character management.

## Overview

The integration ensures that users who register on the website can seamlessly log into the EQEmu game server using the same credentials, and their characters are properly linked between both systems.

## Key Components

### 1. User Registration Integration

When a user registers on the website:
1. A `User` record is created in the `users` table
2. An `EqemuAccount` record is automatically created in the `eqemu_accounts` table
3. The EQEmu account name is set to the user's email address
4. Both records are linked via foreign keys

### 2. Authentication Flow

**Website Login:**
- User logs in with email/password
- Standard Phoenix authentication

**EQEmu Server Login:**
- User logs in with email/password (same credentials)
- EQEmu server calls `/api/eqemu/authenticate` endpoint
- Phoenix validates credentials and returns account information

### 3. Character Management

**Character Creation:**
- Characters are linked to both the website user and EQEmu account
- Each character has:
  - `user_id`: Links to website user
  - `account_id`: Links to EQEmu account (via `eqemu_id`)
  - `eqemu_id`: Unique character ID for EQEmu server

## Database Schema Relationships

```
users (Website Users)
├── id (binary_id)
├── email (unique)
└── password_hash

eqemu_accounts (EQEmu Accounts)
├── id (binary_id)
├── user_id → users.id
├── eqemu_id (integer, unique)
├── name (= users.email)
└── status (0=player, 100=admin)

eqemu_characters (Game Characters)
├── id (binary_id)
├── user_id → users.id
├── account_id → eqemu_accounts.eqemu_id
├── eqemu_id (integer, unique)
├── name (character name)
└── [game stats...]
```

## API Endpoints

### POST /api/eqemu/authenticate
Authenticates a user for EQEmu server login.

**Request:**
```json
{
  "email": "player@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "player@example.com",
    "name": "Player Name",
    "is_admin": false
  },
  "account": {
    "id": "uuid",
    "eqemu_id": 1001,
    "name": "player@example.com",
    "status": 0,
    "expansion": 8
  }
}
```

### POST /api/eqemu/verify_account
Verifies an EQEmu account exists.

**Request:**
```json
{
  "account_name": "player@example.com"
}
```

### GET /api/eqemu/characters/:user_id
Lists all characters for a user.

### POST /api/eqemu/characters
Creates a new character.

## Key Functions

### PhoenixApp.Accounts
- `register_user/1` - Creates user + EQEmu account
- `authenticate_for_eqemu/2` - EQEmu server authentication
- `verify_eqemu_account/1` - Verify account exists

### PhoenixApp.EqemuGame
- `create_eqemu_account/1` - Creates EQEmu account for user
- `get_or_create_eqemu_account/1` - Gets or creates account
- `create_character/2` - Creates character linked to user/account
- `sync_user_to_eqemu_account/1` - Syncs email changes

## Configuration

The integration automatically:
- Creates EQEmu accounts when users register
- Syncs email changes to EQEmu account names
- Links characters to both systems
- Maintains referential integrity

## Deletion Cascade Behavior

**After running the cascade migration (`20250105000002_fix_eqemu_cascade_deletes.exs`):**

When a **website user** is deleted:
1. ✅ Their EQEmu account is automatically deleted
2. ✅ All their characters are automatically deleted
3. ✅ All character inventory/data is automatically deleted

When an **EQEmu account** is deleted:
1. ✅ All characters belonging to that account are automatically deleted
2. ✅ All character inventory/data is automatically deleted

**Deletion Flow:**
```
Delete User
    ↓ (CASCADE)
Delete EQEmu Account  
    ↓ (CASCADE)
Delete All Characters
    ↓ (CASCADE)
Delete All Character Data
```

## Security Considerations

1. **Password Security**: Uses bcrypt for password hashing
2. **Account Linking**: Foreign key constraints prevent orphaned records
3. **Admin Status**: Website admins get GM status in EQEmu (status=100)
4. **Unique Constraints**: Prevents duplicate accounts/characters
5. **Cascade Deletes**: Ensures complete cleanup when accounts are removed

## Testing

Run the integration tests:
```bash
mix test test/phoenix_app/eqemu_integration_test.exs
```

## Troubleshooting

**Common Issues:**

1. **Account Not Found**: User may not have EQEmu account
   - Solution: Call `get_or_create_eqemu_account/1`

2. **Email Mismatch**: EQEmu account name doesn't match user email
   - Solution: Call `sync_user_to_eqemu_account/1`

3. **Character Creation Fails**: Missing account_id
   - Solution: Ensure EQEmu account exists first

## Migration Notes

When migrating existing data:
1. Run migrations to create tables
2. Create EQEmu accounts for existing users
3. Link existing characters to accounts
4. Verify all relationships are correct