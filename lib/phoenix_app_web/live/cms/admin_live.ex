defmodule PhoenixAppWeb.CMS.AdminLive do
  use PhoenixAppWeb, :live_view
  
  alias PhoenixApp.CMS
  alias PhoenixApp.CMS.Content.Post
  alias PhoenixApp.CMS.Import.WordPressImporter

  def mount(_params, _session, socket) do
    posts = CMS.list_posts()
    users = PhoenixApp.Accounts.list_users()
    
    {:ok, 
     socket
     |> assign(:posts, posts)
     |> assign(:users, users)
     |> assign(:page_title, "CMS Admin")
     |> assign(:active_tab, "dashboard")
     |> assign(:show_post_form, false)
     |> assign(:editing_post, nil)
     |> assign(:post_form, to_form(%{}, as: :post))
     |> assign(:import_result, nil)}
  end

  def handle_params(%{"tab" => tab}, _uri, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def handle_event("new_post", _params, socket) do
    changeset = Post.changeset(%Post{}, %{post_type: "post"})
    
    {:noreply,
     socket
     |> assign(:show_post_form, true)
     |> assign(:editing_post, nil)
     |> assign(:post_form, to_form(changeset, as: :post))}
  end

  def handle_event("new_page", _params, socket) do
    changeset = Post.changeset(%Post{}, %{post_type: "page"})
    
    {:noreply,
     socket
     |> assign(:show_post_form, true)
     |> assign(:editing_post, nil)
     |> assign(:post_form, to_form(changeset, as: :post))}
  end

  def handle_event("edit_post", %{"id" => id}, socket) do
    post = CMS.get_post!(id)
    changeset = Post.changeset(post, %{})
    
    {:noreply,
     socket
     |> assign(:show_post_form, true)
     |> assign(:editing_post, post)
     |> assign(:post_form, to_form(changeset, as: :post))}
  end

  def handle_event("cancel_post_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_post_form, false)
     |> assign(:editing_post, nil)}
  end

  def handle_event("save_post", %{"post" => post_params}, socket) do
    case socket.assigns.editing_post do
      nil ->
        # Create new post
        case CMS.create_post(post_params) do
          {:ok, _post} ->
            {:noreply,
             socket
             |> assign(:show_post_form, false)
             |> assign(:posts, CMS.list_posts())
             |> put_flash(:info, "Post created successfully!")}
          
          {:error, changeset} ->
            {:noreply, assign(socket, :post_form, to_form(changeset, as: :post))}
        end
      
      post ->
        # Update existing post
        case CMS.update_post(post, post_params) do
          {:ok, _post} ->
            {:noreply,
             socket
             |> assign(:show_post_form, false)
             |> assign(:editing_post, nil)
             |> assign(:posts, CMS.list_posts())
             |> put_flash(:info, "Post updated successfully!")}
          
          {:error, changeset} ->
            {:noreply, assign(socket, :post_form, to_form(changeset, as: :post))}
        end
    end
  end

  def handle_event("save_draft", %{"post" => post_params}, socket) do
    # Force status to draft
    draft_params = Map.put(post_params, "status", "draft")
    
    case socket.assigns.editing_post do
      nil ->
        case CMS.create_post(draft_params) do
          {:ok, post} ->
            {:noreply,
             socket
             |> assign(:editing_post, post)
             |> assign(:posts, CMS.list_posts())
             |> put_flash(:info, "Draft saved!")}
          
          {:error, changeset} ->
            {:noreply, assign(socket, :post_form, to_form(changeset, as: :post))}
        end
      
      post ->
        case CMS.update_post(post, draft_params) do
          {:ok, updated_post} ->
            {:noreply,
             socket
             |> assign(:editing_post, updated_post)
             |> assign(:posts, CMS.list_posts())
             |> put_flash(:info, "Draft saved!")}
          
          {:error, changeset} ->
            {:noreply, assign(socket, :post_form, to_form(changeset, as: :post))}
        end
    end
  end

  def handle_event("save_draft", _params, socket) do
    # Handle case where no post params are sent (just the button click)
    {:noreply, put_flash(socket, :info, "Please fill in the title to save draft")}
  end

  def handle_event("delete_post", %{"id" => id}, socket) do
    post = CMS.get_post!(id)
    {:ok, _} = CMS.delete_post(post)
    
    {:noreply,
     socket
     |> assign(:posts, CMS.list_posts())
     |> put_flash(:info, "Post deleted successfully!")}
  end

  def handle_event("import_wordpress", %{"file" => file_path}, socket) do
    case WordPressImporter.import_sql_file(file_path) do
      {:ok, result} ->
        {:noreply,
         socket
         |> assign(:import_result, result)
         |> assign(:posts, CMS.list_posts())
         |> put_flash(:info, "WordPress import completed!")}
      
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Import failed: #{reason}")}
    end
  end

  def handle_event("toggle_admin", %{"user_id" => user_id}, socket) do
    user = PhoenixApp.Accounts.get_user!(user_id)
    
    case PhoenixApp.Accounts.update_user(user, %{is_admin: !user.is_admin}) do
      {:ok, _updated_user} ->
        {:noreply, socket
         |> assign(users: PhoenixApp.Accounts.list_users())
         |> put_flash(:info, "User admin status updated")}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update user")}
    end
  end

  def handle_event("delete_user", %{"user_id" => user_id}, socket) do
    user = PhoenixApp.Accounts.get_user!(user_id)
    
    case PhoenixApp.Accounts.delete_user(user) do
      {:ok, _deleted_user} ->
        {:noreply, socket
         |> assign(users: PhoenixApp.Accounts.list_users())
         |> put_flash(:info, "User deleted successfully")}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete user")}
    end
  end

  def render(assigns) do
    ~H"""
    
    <div class="w-full min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div class="flex items-center">
              <h1 class="text-3xl font-bold text-gray-900">WordPress Phoenix CMS</h1>
            </div>
            <div class="flex items-center space-x-4">
              <button
                phx-click="new_post"
                class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
              >
                New Post
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <nav class="-mb-px flex space-x-8">
            <button
              phx-click="switch_tab"
              phx-value-tab="dashboard"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "dashboard", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Dashboard
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="posts"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "posts", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Posts
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="pages"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "pages", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Pages
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="import"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "import", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Import
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="users"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "users", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Users
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="users"
              class={[
                "py-4 px-1 border-b-2 font-medium text-sm",
                if(@active_tab == "users", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300")
              ]}
            >
              Users
            </button>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <%= if @active_tab == "dashboard" do %>
          <%= render_dashboard(assigns) %>
        <% end %>

        <%= if @active_tab == "posts" do %>
          <%= render_posts(assigns) %>
        <% end %>

        <%= if @active_tab == "pages" do %>
          <%= render_pages(assigns) %>
        <% end %>

        <%= if @active_tab == "import" do %>
          <%= render_import(assigns) %>
        <% end %>

        <%= if @active_tab == "users" do %>
          <%= render_users(assigns) %>
        <% end %>

        <%= if @active_tab == "users" do %>
          <%= render_users(assigns) %>
        <% end %>
      </div>

      <!-- Post Form Modal -->
      <%= if @show_post_form do %>
        <%= render_post_form(assigns) %>
      <% end %>
    </div>
    """
  end

  defp render_dashboard(assigns) do
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Stats Cards -->
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Posts</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= length(@posts) %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Published</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    <%= Enum.count(@posts, fn p -> p.status == "publish" end) %>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Drafts</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    <%= Enum.count(@posts, fn p -> p.status == "draft" end) %>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Posts -->
      <div class="mt-8">
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Posts</h3>
            <div class="flow-root">
              <ul class="-my-5 divide-y divide-gray-200">
                <%= for post <- Enum.take(@posts, 5) do %>
                  <li class="py-4">
                    <div class="flex items-center space-x-4">
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">
                          <%= post.title %>
                        </p>
                        <p class="text-sm text-gray-500">
                          <%= post.status %> • <%= if post.inserted_at, do: Calendar.strftime(post.inserted_at, "%B %d, %Y"), else: "No date" %>
                        </p>
                      </div>
                      <div class="flex-shrink-0">
                        <button
                          phx-click="edit_post"
                          phx-value-id={post.id}
                          class="text-blue-600 hover:text-blue-500 text-sm font-medium"
                        >
                          Edit
                        </button>
                      </div>
                    </div>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_posts(assigns) do
    blog_posts = Enum.filter(assigns.posts, fn post -> post.post_type == "post" end)
    assigns = assign(assigns, :blog_posts, blog_posts)
    
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Blog Posts</h3>
            <button
              phx-click="new_post"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
            >
              Add New Post
            </button>
          </div>
          
          <%= if length(@blog_posts) > 0 do %>
            <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for post <- @blog_posts do %>
                    <tr>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900"><%= post.title %></div>
                        <div class="text-sm text-gray-500"><%= String.slice(post.content || "", 0, 100) %>...</div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class={[
                          "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                          case post.status do
                            "publish" -> "bg-green-100 text-green-800"
                            "draft" -> "bg-yellow-100 text-yellow-800"
                            "private" -> "bg-blue-100 text-blue-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          <%= post.status %>
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= if post.inserted_at, do: Calendar.strftime(post.inserted_at, "%B %d, %Y"), else: "No date" %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          phx-click="edit_post"
                          phx-value-id={post.id}
                          class="text-blue-600 hover:text-blue-900 mr-4"
                        >
                          Edit
                        </button>
                        <button
                          phx-click="view_post"
                          phx-value-slug={post.slug}
                          class="text-green-600 hover:text-green-900 mr-4"
                        >
                          View
                        </button>
                        <button
                          phx-click="delete_post"
                          phx-value-id={post.id}
                          data-confirm="Are you sure you want to delete this post?"
                          class="text-red-600 hover:text-red-900"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% else %>
            <div class="text-center py-12">
              <div class="text-gray-500">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <h3 class="mt-2 text-sm font-medium text-gray-900">No posts yet</h3>
                <p class="mt-1 text-sm text-gray-500">Get started by creating your first blog post.</p>
                <div class="mt-6">
                  <button
                    phx-click="new_post"
                    class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                  >
                    Add New Post
                  </button>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_pages(assigns) do
    pages = Enum.filter(assigns.posts, fn post -> post.post_type == "page" end)
    assigns = assign(assigns, :pages, pages)
    
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Pages</h3>
            <button
              phx-click="new_page"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
            >
              Add New Page
            </button>
          </div>
          
          <%= if length(@pages) > 0 do %>
            <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for page <- @pages do %>
                    <tr>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900"><%= page.title %></div>
                        <div class="text-sm text-gray-500">/<%= page.slug %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class={[
                          "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                          case page.status do
                            "publish" -> "bg-green-100 text-green-800"
                            "draft" -> "bg-yellow-100 text-yellow-800"
                            "private" -> "bg-blue-100 text-blue-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          <%= page.status %>
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= if page.inserted_at, do: Calendar.strftime(page.inserted_at, "%B %d, %Y"), else: "No date" %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          phx-click="edit_post"
                          phx-value-id={page.id}
                          class="text-blue-600 hover:text-blue-900 mr-4"
                        >
                          Edit
                        </button>
                        <button
                          phx-click="view_page"
                          phx-value-slug={page.slug}
                          class="text-green-600 hover:text-green-900 mr-4"
                        >
                          View
                        </button>
                        <button
                          phx-click="delete_post"
                          phx-value-id={page.id}
                          data-confirm="Are you sure you want to delete this page?"
                          class="text-red-600 hover:text-red-900"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% else %>
            <div class="text-center py-12">
              <div class="text-gray-500">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <h3 class="mt-2 text-sm font-medium text-gray-900">No pages yet</h3>
                <p class="mt-1 text-sm text-gray-500">Get started by creating your first page.</p>
                <div class="mt-6">
                  <button
                    phx-click="new_page"
                    class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                  >
                    Add New Page
                  </button>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_import(assigns) do
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">WordPress Import</h3>
          <p class="mt-2 text-sm text-gray-600">Import your WordPress site data from an SQL dump file.</p>
          
          <div class="mt-6">
            <form phx-submit="import_wordpress" class="space-y-4">
              <div>
                <label for="file_path" class="block text-sm font-medium text-gray-700">SQL File Path</label>
                <input
                  type="text"
                  name="file"
                  id="file_path"
                  placeholder="/path/to/wordpress-dump.sql"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
              <button
                type="submit"
                class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
              >
                Import WordPress Data
              </button>
            </form>
          </div>

          <%= if @import_result do %>
            <div class="mt-6 bg-green-50 border border-green-200 rounded-md p-4">
              <h4 class="text-sm font-medium text-green-800">Import Results:</h4>
              <ul class="mt-2 text-sm text-green-700">
                <li>Users imported: <%= @import_result.users %></li>
                <li>Posts imported: <%= @import_result.posts %></li>
                <li>Taxonomies imported: <%= @import_result.taxonomies %></li>
                <li>Terms imported: <%= @import_result.terms %></li>
                <li>Options imported: <%= @import_result.options %></li>
              </ul>
              <%= if length(@import_result.errors) > 0 do %>
                <div class="mt-2">
                  <h5 class="text-sm font-medium text-red-800">Errors:</h5>
                  <ul class="text-sm text-red-700">
                    <%= for error <- Enum.take(@import_result.errors, 5) do %>
                      <li>• <%= error %></li>
                    <% end %>
                  </ul>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_post_form(assigns) do
    ~H"""
    <!-- Full Screen Modal Overlay -->
    <div class="fixed inset-0 bg-gray-900 bg-opacity-75 z-50 flex items-center justify-center">
      <div class="bg-white w-full h-full max-w-none max-h-none overflow-hidden flex flex-col">
        <!-- Modal Header -->
        <div class="flex justify-between items-center p-6 border-b bg-white">
          <div class="flex items-center space-x-4">
            <h3 class="text-xl font-semibold text-gray-900">
              <%= if @editing_post, do: "Edit #{String.capitalize(@editing_post.post_type || "post")}", else: "New Post" %>
            </h3>
            <%= if @editing_post do %>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                ID: <%= @editing_post.id %>
              </span>
            <% end %>
          </div>
          <div class="flex items-center space-x-3">
            <button
              type="button"
              phx-click="save_draft"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Save Draft
            </button>
            <button
              phx-click="cancel_post_form"
              class="text-gray-400 hover:text-gray-600 p-2"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
        </div>

        <!-- Modal Body -->
        <div class="flex-1 overflow-hidden">
          <.form for={@post_form} phx-submit="save_post" class="h-full flex">
            <!-- Main Content Area -->
            <div class="flex-1 flex flex-col overflow-hidden">
              <!-- Title and Slug -->
              <div class="p-6 border-b bg-gray-50">
                <div class="space-y-4">
                  <div>
                    <input
                      type="text"
                      name="post[title]"
                      value={Phoenix.HTML.Form.input_value(@post_form, :title)}
                      placeholder="Enter title here"
                      class="w-full text-2xl font-semibold border-none bg-transparent placeholder-gray-400 focus:ring-0 focus:outline-none"
                      autofocus
                    />
                  </div>
                  <div class="flex items-center space-x-2 text-sm text-gray-500">
                    <span>Permalink:</span>
                    <span class="text-blue-600">/blog/</span>
                    <input
                      type="text"
                      name="post[slug]"
                      value={Phoenix.HTML.Form.input_value(@post_form, :slug)}
                      placeholder="post-slug"
                      class="border-none bg-transparent text-blue-600 focus:ring-0 focus:outline-none"
                    />
                  </div>
                </div>
              </div>

              <!-- Content Editor -->
              <div class="flex-1 overflow-hidden">
                <textarea
                  id="post-content-editor"
                  name="post[content]"
                  class="w-full h-full border-none resize-none focus:ring-0 focus:outline-none"
                  placeholder="Start writing your content here..."
                  phx-hook="RichEditor"
                ><%= Phoenix.HTML.Form.input_value(@post_form, :content) %></textarea>
              </div>
            </div>

            <!-- Sidebar -->
            <div class="w-80 bg-gray-50 border-l overflow-y-auto">
              <div class="p-6 space-y-6">
                <!-- Publish Box -->
                <div class="bg-white rounded-lg shadow p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Publish</h4>
                  
                  <div class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                      <select name="post[status]" class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 text-sm">
                        <option value="draft" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :draft}>Draft</option>
                        <option value="publish" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :publish}>Published</option>
                        <option value="private" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :private}>Private</option>
                      </select>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Type</label>
                      <select name="post[post_type]" class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 text-sm">
                        <option value="post" selected={Phoenix.HTML.Form.input_value(@post_form, :post_type) == "post"}>Blog Post</option>
                        <option value="page" selected={Phoenix.HTML.Form.input_value(@post_form, :post_type) == "page"}>Static Page</option>
                      </select>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Visibility</label>
                      <div class="space-y-2">
                        <label class="flex items-center">
                          <input type="radio" name="visibility" value="public" checked class="mr-2">
                          <span class="text-sm">Public</span>
                        </label>
                        <label class="flex items-center">
                          <input type="radio" name="visibility" value="password" class="mr-2">
                          <span class="text-sm">Password protected</span>
                        </label>
                        <label class="flex items-center">
                          <input type="radio" name="visibility" value="private" class="mr-2">
                          <span class="text-sm">Private</span>
                        </label>
                      </div>
                    </div>

                    <div class="pt-4 border-t">
                      <button
                        type="submit"
                        class="w-full px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                      >
                        <%= if @editing_post, do: "Update", else: "Publish" %>
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Excerpt -->
                <div class="bg-white rounded-lg shadow p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Excerpt</h4>
                  <textarea
                    name="post[excerpt]"
                    rows="3"
                    class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 text-sm"
                    placeholder="Optional excerpt..."
                  ><%= Phoenix.HTML.Form.input_value(@post_form, :excerpt) %></textarea>
                  <p class="mt-2 text-xs text-gray-500">
                    Excerpts are optional hand-crafted summaries of your content.
                  </p>
                </div>

                <!-- Categories & Tags -->
                <div class="bg-white rounded-lg shadow p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Categories</h4>
                  <div class="space-y-2">
                    <label class="flex items-center">
                      <input type="checkbox" class="mr-2" checked>
                      <span class="text-sm">Uncategorized</span>
                    </label>
                    <button type="button" class="text-sm text-blue-600 hover:text-blue-800">+ Add New Category</button>
                  </div>
                </div>

                <div class="bg-white rounded-lg shadow p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Tags</h4>
                  <input
                    type="text"
                    placeholder="Add tags separated by commas"
                    class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 text-sm"
                  />
                  <p class="mt-2 text-xs text-gray-500">
                    Separate tags with commas
                  </p>
                </div>

                <!-- Featured Image -->
                <div class="bg-white rounded-lg shadow p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Featured Image</h4>
                  <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                      <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                    <div class="mt-4">
                      <button type="button" class="text-sm text-blue-600 hover:text-blue-800">
                        Set featured image
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp render_users(assigns) do
    user_stats = get_user_stats(assigns.users)
    assigns = assign(assigns, :user_stats, user_stats)
    
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Users</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @user_stats.total %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Confirmed</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @user_stats.confirmed %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Admins</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @user_stats.admins %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Recent</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @user_stats.recent %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Users Table -->
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">All Users</h3>
          
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for user <- @users do %>
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="flex items-center">
                        <div class="flex-shrink-0 h-10 w-10">
                          <div class={[
                            "h-10 w-10 rounded-full flex items-center justify-center text-white font-medium",
                            "bg-gradient-to-r from-blue-500 to-purple-600"
                          ]}>
                            <%= String.first(user.name || user.email) |> String.upcase() %>
                          </div>
                        </div>
                        <div class="ml-4">
                          <div class="text-sm font-medium text-gray-900"><%= user.name || "No name" %></div>
                          <div class="text-sm text-gray-500"><%= user.email %></div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class={[
                        "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                        if(user.confirmed_at, do: "bg-green-100 text-green-800", else: "bg-yellow-100 text-yellow-800")
                      ]}>
                        <%= if user.confirmed_at, do: "Confirmed", else: "Pending" %>
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class={[
                        "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                        if(user.is_admin, do: "bg-purple-100 text-purple-800", else: "bg-gray-100 text-gray-800")
                      ]}>
                        <%= if user.is_admin, do: "Admin", else: "User" %>
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <%= Calendar.strftime(user.inserted_at, "%B %d, %Y") %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button
                        phx-click="toggle_admin"
                        phx-value-user_id={user.id}
                        class={[
                          "mr-4 px-3 py-1 rounded text-xs font-medium",
                          if(user.is_admin, do: "bg-red-100 text-red-800 hover:bg-red-200", else: "bg-blue-100 text-blue-800 hover:bg-blue-200")
                        ]}
                      >
                        <%= if user.is_admin, do: "Remove Admin", else: "Make Admin" %>
                      </button>
                      <button
                        phx-click="delete_user"
                        phx-value-user_id={user.id}
                        data-confirm="Are you sure you want to delete this user?"
                        class="text-red-600 hover:text-red-900"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_user_stats(users) do
    total = length(users)
    confirmed = Enum.count(users, & &1.confirmed_at)
    admins = Enum.count(users, & &1.is_admin)
    
    # Users created in the last 30 days
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)
    recent = Enum.count(users, fn user ->
      DateTime.compare(user.inserted_at, thirty_days_ago) == :gt
    end)

    %{
      total: total,
      confirmed: confirmed,
      admins: admins,
      recent: recent
    }
  end

end