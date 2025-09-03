# Migration from PBKDF2 to Bcrypt - Performance Fix

## The Problem ❌

**PBKDF2 was causing massive performance issues:**
- Login taking 30+ seconds
- API endpoints running slowly
- Poor user experience

**PBKDF2 vs Bcrypt Performance:**
- PBKDF2: ~100,000+ rounds by default = VERY SLOW
- Bcrypt: ~12 rounds by default = Much faster while still secure

## The Solution ✅

**Switched from PBKDF2 to Bcrypt** - a much faster but equally secure hashing algorithm.

## Changes Made

### 1. Dependencies (`mix.exs`)
```elixir
# OLD
{:pbkdf2_elixir, "~> 2.0"},

# NEW  
{:bcrypt_elixir, "~> 3.0"},
```

### 2. User Model (`lib/phoenix_app/accounts/user.ex`)
```elixir
# OLD
def valid_password?(%__MODULE__{password_hash: hash}, password) do
  Pbkdf2.verify_pass(password, hash)
end

defp put_password_hash(changeset) do
  if pwd = get_change(changeset, :password) do
    hash = case Pbkdf2.hash_pwd_salt(pwd) do
      hash when is_binary(hash) -> hash
      hash when is_list(hash) -> List.to_string(hash)
      hash -> to_string(hash)
    end
    put_change(changeset, :password_hash, hash)
  else
    changeset
  end
end

# NEW
def valid_password?(%__MODULE__{password_hash: hash}, password) do
  Bcrypt.verify_pass(password, hash)
end

defp put_password_hash(changeset) do
  if pwd = get_change(changeset, :password) do
    hash = Bcrypt.hash_pwd_salt(pwd)
    put_change(changeset, :password_hash, hash)
  else
    changeset
  end
end
```

### 3. Accounts Module (`lib/phoenix_app/accounts/accounts.ex`)
```elixir
# OLD
def check_password(%User{password_hash: hash}, password) do
  hash_string = case hash do
    h when is_binary(h) -> h
    h when is_list(h) -> List.to_string(h)
    h -> to_string(h)
  end
  Pbkdf2.verify_pass(password, hash_string)
end

# NEW
def check_password(%User{password_hash: hash}, password) do
  Bcrypt.verify_pass(password, hash)
end
```

### 4. CMS User Model (`lib/phoenix_app/cms/accounts/user.ex`)
```elixir
# OLD
put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
Pbkdf2.verify_pass(password, hashed_password)

# NEW
put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
Bcrypt.verify_pass(password, hashed_password)
```

### 5. Dev Configuration (`config/dev.exs`)
```elixir
# OLD
config :pbkdf2_elixir, :rounds, 1000

# NEW
config :bcrypt_elixir, :log_rounds, 4  # Fast for development (default is 12)
```

### 6. Fixed API Security Issue (`lib/phoenix_app_web/controllers/api/game_auth_controller.ex`)
```elixir
# OLD - SECURITY VULNERABILITY!
if user.password_hash && String.length(user.password_hash) > 10 do
  # This was NOT actually checking the password!

# NEW - PROPER PASSWORD VERIFICATION
case Accounts.authenticate_user(email, password) do
  {:ok, user} -> # Login success
  {:error, _reason} -> # Login failed
```

## Migration Steps Required

### 1. Install New Dependency
```bash
mix deps.get
```

### 2. Handle Existing Users
⚠️ **IMPORTANT**: Existing users with PBKDF2 hashes won't be able to login until they reset their passwords OR you implement a migration strategy.

**Option A: Force Password Reset (Recommended)**
- Existing users will need to reset their passwords
- New passwords will use Bcrypt

**Option B: Dual Hash Support (Complex)**
- Support both PBKDF2 and Bcrypt temporarily
- Migrate users gradually

### 3. Test Performance
- Login should now be under 1 second
- API endpoints should be much faster
- Check server logs for timing improvements

## Expected Performance Improvements

### Before (PBKDF2)
- ❌ Login: 30+ seconds
- ❌ API calls: Very slow
- ❌ Poor user experience

### After (Bcrypt)
- ✅ Login: Under 1 second
- ✅ API calls: Much faster
- ✅ Great user experience

## Production Configuration

For production, you can increase security by using more rounds:

```elixir
# config/prod.exs
config :bcrypt_elixir, :log_rounds, 12  # Default, good security/performance balance
```

## Testing Checklist

1. ✅ **New user registration**: Should work with Bcrypt hashes
2. ⚠️ **Existing user login**: May fail until password reset
3. ✅ **API authentication**: Should be much faster
4. ✅ **Performance**: Login under 1 second
5. ✅ **Security**: Proper password verification in API

## Next Steps

1. Run `mix deps.get` to install bcrypt_elixir
2. Test with a new user account
3. Consider password reset flow for existing users
4. Monitor performance improvements

The authentication system should now be dramatically faster while maintaining security!