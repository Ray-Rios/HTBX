defmodule PhoenixAppWeb.CMS.AdminLive do
  use PhoenixAppWeb, :live_view
  
  alias PhoenixApp.CMS
  alias PhoenixApp.CMS.Content.Post
  alias PhoenixApp.CMS.Import.WordPressImporter

  def mount(_params, _session, socket) do
    posts = CMS.list_posts()
    
    {:ok, 
     socket
     |> assign(:posts, posts)
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
    {:noreply, push_patch(socket, to: ~p"/cms/admin?tab=#{tab}")}
  end

  def handle_event("new_post", _params, socket) do
    changeset = Post.changeset(%Post{}, %{})
    
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

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
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
                    <%= Enum.count(@posts, fn p -> p.status == :publish end) %>
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
                    <%= Enum.count(@posts, fn p -> p.status == :draft end) %>
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
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900">All Posts</h3>
            <button
              phx-click="new_post"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
            >
              Add New Post
            </button>
          </div>
          
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
                <%= for post <- @posts do %>
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm font-medium text-gray-900"><%= post.title %></div>
                      <div class="text-sm text-gray-500"><%= String.slice(post.content || "", 0, 100) %>...</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class={[
                        "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                        case post.status do
                          :publish -> "bg-green-100 text-green-800"
                          :draft -> "bg-yellow-100 text-yellow-800"
                          :private -> "bg-blue-100 text-blue-800"
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
                        phx-click="delete_post"
                        phx-value-id={post.id}
                        data-confirm="Are you sure?"
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

  defp render_pages(assigns) do
    ~H"""
    <div class="px-4 py-6 sm:px-0">
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">Pages</h3>
          <p class="mt-2 text-sm text-gray-600">Manage your static pages here.</p>
          <!-- Pages content will go here -->
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
    <!-- Modal Overlay -->
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-11/12 max-w-4xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <!-- Modal Header -->
          <div class="flex justify-between items-center pb-4 border-b">
            <h3 class="text-lg font-medium text-gray-900">
              <%= if @editing_post, do: "Edit Post", else: "New Post" %>
            </h3>
            <button
              phx-click="cancel_post_form"
              class="text-gray-400 hover:text-gray-600"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <!-- Modal Body -->
          <div class="mt-6">
            <.form for={@post_form} phx-submit="save_post" class="space-y-6">
              <div>
                <.input field={@post_form[:title]} label="Title" placeholder="Enter post title" />
              </div>

              <div>
                <.input field={@post_form[:slug]} label="Slug" placeholder="post-url-slug" />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Content</label>
                <textarea
                  id="post-content-editor"
                  name="post[content]"
                  rows="12"
                  class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Write your post content here..."
                  phx-hook="RichEditor"
                ><%= Phoenix.HTML.Form.input_value(@post_form, :content) %></textarea>
              </div>

              <div>
                <.input field={@post_form[:excerpt]} label="Excerpt" placeholder="Brief description" />
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                  <select name="post[status]" class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                    <option value="draft" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :draft}>Draft</option>
                    <option value="publish" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :publish}>Published</option>
                    <option value="private" selected={Phoenix.HTML.Form.input_value(@post_form, :status) == :private}>Private</option>
                  </select>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Post Type</label>
                  <select name="post[post_type]" class="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                    <option value="post" selected={Phoenix.HTML.Form.input_value(@post_form, :post_type) == "post"}>Post</option>
                    <option value="page" selected={Phoenix.HTML.Form.input_value(@post_form, :post_type) == "page"}>Page</option>
                  </select>
                </div>
              </div>

              <!-- Modal Footer -->
              <div class="flex justify-end space-x-3 pt-4 border-t">
                <button
                  type="button"
                  phx-click="cancel_post_form"
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
                >
                  <%= if @editing_post, do: "Update Post", else: "Create Post" %>
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end