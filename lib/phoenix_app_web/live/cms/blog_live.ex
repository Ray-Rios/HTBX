defmodule PhoenixAppWeb.CMS.BlogLive do
  use PhoenixAppWeb, :live_view
  
  alias PhoenixApp.CMS

  def mount(_params, _session, socket) do
    posts = CMS.list_posts(status: :publish, post_type: "post")
    
    {:ok, 
     socket
     |> assign(:posts, posts)
     |> assign(:page_title, "Blog")}
  end

  def handle_params(%{"slug" => slug}, _uri, socket) do
    case find_post_by_slug(slug) do
      nil ->
        {:noreply, 
         socket
         |> put_flash(:error, "Post not found")
         |> push_navigate(to: ~p"/blog")}
      
      post ->
        {:noreply, 
         socket
         |> assign(:current_post, post)
         |> assign(:page_title, post.title)}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :current_post, nil)}
  end

  defp find_post_by_slug(slug) do
    CMS.list_posts(status: :publish, post_type: "post")
    |> Enum.find(fn post -> post.slug == slug end)
  end

  def render(%{current_post: nil} = assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6">
            <h1 class="text-3xl font-bold text-gray-900">Blog</h1>
            <p class="mt-2 text-gray-600">Latest posts and updates</p>
          </div>
        </div>
      </div>

      <!-- Blog Posts -->
      <div class="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <%= if length(@posts) > 0 do %>
          <div class="space-y-8">
            <%= for post <- @posts do %>
              <article class="bg-white shadow rounded-lg overflow-hidden">
                <div class="p-6">
                  <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center text-sm text-gray-500">
                      <time datetime={post.inserted_at}>
                        <%= if post.inserted_at, do: Calendar.strftime(post.inserted_at, "%B %d, %Y"), else: "No date" %>
                      </time>
                    </div>
                  </div>
                  
                  <h2 class="text-2xl font-bold text-gray-900 mb-3">
                    <.link navigate={~p"/blog/#{post.slug}"} class="hover:text-blue-600">
                      <%= post.title %>
                    </.link>
                  </h2>
                  
                  <div class="text-gray-600 mb-4">
                    <%= if post.excerpt && post.excerpt != "" do %>
                      <%= post.excerpt %>
                    <% else %>
                      <%= String.slice(strip_html(post.content || ""), 0, 200) %>...
                    <% end %>
                  </div>
                  
                  <div class="flex items-center justify-between">
                    <.link 
                      navigate={~p"/blog/#{post.slug}"} 
                      class="text-blue-600 hover:text-blue-800 font-medium"
                    >
                      Read more →
                    </.link>
                  </div>
                </div>
              </article>
            <% end %>
          </div>
        <% else %>
          <div class="text-center py-12">
            <div class="text-gray-500">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No posts yet</h3>
              <p class="mt-1 text-sm text-gray-500">Get started by creating your first blog post.</p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{current_post: _post} = assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6">
            <nav class="flex items-center space-x-2 text-sm text-gray-500 mb-4">
              <.link navigate={~p"/blog"} class="hover:text-gray-700">Blog</.link>
              <span>→</span>
              <span class="text-gray-900"><%= @current_post.title %></span>
            </nav>
            <h1 class="text-3xl font-bold text-gray-900"><%= @current_post.title %></h1>
            <div class="mt-2 flex items-center text-sm text-gray-500">
              <time datetime={@current_post.inserted_at}>
                <%= if @current_post.inserted_at, do: Calendar.strftime(@current_post.inserted_at, "%B %d, %Y"), else: "No date" %>
              </time>
            </div>
          </div>
        </div>
      </div>

      <!-- Post Content -->
      <div class="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <article class="bg-white shadow rounded-lg overflow-hidden">
          <div class="p-8">
            <div class="prose prose-lg max-w-none">
              <%= raw(format_content(@current_post.content || "")) %>
            </div>
          </div>
        </article>

        <!-- Back to Blog -->
        <div class="mt-8">
          <.link 
            navigate={~p"/blog"} 
            class="inline-flex items-center text-blue-600 hover:text-blue-800"
          >
            ← Back to Blog
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp strip_html(content) do
    content
    |> String.replace(~r/<[^>]*>/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp format_content(content) do
    content
    |> String.replace("\n", "<br>")
    |> String.replace("\r\n", "<br>")
  end
end