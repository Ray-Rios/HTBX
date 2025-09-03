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