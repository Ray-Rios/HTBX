# Navbar Solution

## Problem
The navbar component `<.navbar current_user={@current_user} />` couldn't be used in layouts because Phoenix LiveView layouts don't automatically receive assigns from LiveViews.

## Solution
Created a page wrapper component that includes the navbar and can be used by individual LiveViews.

## Files Created/Modified

### 1. Created Page Wrapper Component
- **File**: `lib/phoenix_app_web/components/page_wrapper.ex`
- **Purpose**: Provides a reusable wrapper that includes the navbar

### 2. Updated Web Module
- **File**: `lib/phoenix_app_web.ex`
- **Change**: Added import for `PhoenixAppWeb.Components.PageWrapper`

### 3. Updated LiveViews
- **Files Updated**: 
  - `lib/phoenix_app_web/live/home_live.ex`
  - `lib/phoenix_app_web/live/profile_live.ex`
- **Change**: Wrapped content with `<.page_with_navbar current_user={@current_user}>`

### 4. Removed Individual Navbar Calls
- **Files**: Various LiveViews that had individual navbar calls
- **Change**: Removed `<.navbar current_user={@current_user} />` calls

## How to Add Navbar to Other Pages

To add the navbar to any LiveView, wrap the entire render content with the page wrapper:

```elixir
def render(assigns) do
  ~H"""
  <.page_with_navbar current_user={@current_user}>
    <!-- Your existing page content here -->
    <div class="your-content">
      <!-- ... -->
    </div>
  </.page_with_navbar>
  """
end
```

## Pages That Need Navbar Added

The following LiveViews still need the navbar wrapper added:

1. `lib/phoenix_app_web/live/dashboard_live.ex`
2. `lib/phoenix_app_web/live/game_player_live.ex`
3. `lib/phoenix_app_web/live/game_admin_live.ex`
4. `lib/phoenix_app_web/live/cms/blog_live.ex`
5. `lib/phoenix_app_web/live/chat_live.ex`
6. `lib/phoenix_app_web/live/shop_live.ex`
7. `lib/phoenix_app_web/live/cart_live.ex`
8. `lib/phoenix_app_web/live/checkout_live.ex`
9. `lib/phoenix_app_web/live/quest_live.ex`
10. `lib/phoenix_app_web/live/desktop_live.ex`
11. `lib/phoenix_app_web/live/files_live.ex`
12. `lib/phoenix_app_web/live/admin_cms_live.ex`
13. `lib/phoenix_app_web/live/cms/admin_live.ex`

## Pages That Should NOT Have Navbar

- `lib/phoenix_app_web/live/auth_live.ex` (login/register pages)
- Any full-screen game interfaces
- Any modal or popup components

## Benefits of This Approach

1. **Consistent**: Every page that needs a navbar gets the same navbar
2. **Flexible**: Easy to add/remove navbar from specific pages
3. **Maintainable**: Navbar logic is centralized in one component
4. **Current User Access**: Each LiveView has access to its own `@current_user` assign

## Alternative Approaches Considered

1. **Layout-based**: Tried adding navbar to `app.html.heex` but LiveView assigns don't pass to layouts
2. **JavaScript-based**: Could fetch user info via JS, but would be less reliable
3. **Session-based**: Could read from session in layout, but would require additional complexity

The page wrapper approach is the cleanest solution that works with Phoenix LiveView's architecture.