# CMS Seeds - WordPress-style sample data
alias PhoenixApp.Repo
alias PhoenixApp.CMS
alias PhoenixApp.CMS.Content.Post
alias PhoenixApp.CMS.Accounts.User

# Clear existing data
Repo.delete_all(Post)
Repo.delete_all(User)

# Create admin user
{:ok, admin} = CMS.create_user(%{
  login: "admin",
  email: "admin@example.com",
  password: "password123",
  display_name: "Site Administrator",
  first_name: "Admin",
  last_name: "User",
  role: "administrator",
  status: :active
})

# Create sample blog posts
sample_posts = [
  %{
    title: "Welcome to Your New WordPress-Style CMS",
    content: """
    # Welcome to Phoenix CMS!

    This is your first blog post in the new **WordPress-equivalent Phoenix CMS**. This system provides all the functionality you expect from WordPress, but built with the power and reliability of Phoenix and Elixir.

    ## Features

    - **Rich Content Editor** with full-screen support
    - **WordPress-compatible database schema**
    - **Real-time LiveView interface**
    - **Complete CRUD operations**
    - **Post and Page management**
    - **WordPress SQL import capability**

    ## Getting Started

    You can edit this post by clicking the "Edit" button in the admin interface. Try out the rich editor with its toolbar and full-screen mode!

    ### Markdown Support

    The editor supports markdown formatting:

    - **Bold text**
    - *Italic text*
    - [Links](https://phoenixframework.org)
    - `Code snippets`
    - Lists and more!

    > This is a blockquote to show off the styling.

    ```elixir
    # Even code blocks work great!
    defmodule MyApp do
      def hello do
        "Hello, Phoenix CMS!"
      end
    end
    ```

    Start creating your content and see how easy it is to manage with this modern CMS!
    """,
    excerpt: "Welcome to your new WordPress-equivalent Phoenix CMS with rich editing capabilities and real-time updates.",
    status: :publish,
    post_type: "post",
    slug: "welcome-to-phoenix-cms",
    author_id: admin.id
  },
  %{
    title: "Getting Started with Content Creation",
    content: """
    # Content Creation Made Easy

    Creating content in Phoenix CMS is intuitive and powerful. Here's what you need to know:

    ## The Rich Editor

    Our rich editor provides:
    - **Full-screen editing mode** (press F11 or click the fullscreen button)
    - **Live preview** to see how your content will look
    - **Markdown support** for quick formatting
    - **Keyboard shortcuts** for power users

    ## Post vs Pages

    - **Posts** are for blog content, news, and time-sensitive material
    - **Pages** are for static content like About, Contact, etc.

    ## Publishing Options

    You can:
    - Save as **Draft** to work on later
    - **Publish** immediately to make it live
    - Set to **Private** for internal use only

    Try creating your own content and see how easy it is!
    """,
    excerpt: "Learn how to create and manage content with the powerful Phoenix CMS editor.",
    status: :publish,
    post_type: "post",
    slug: "getting-started-content-creation",
    author_id: admin.id
  },
  %{
    title: "Draft Post Example",
    content: """
    # This is a Draft Post

    This post is saved as a draft to show how the system handles different post statuses.

    You can see drafts in the admin interface and continue editing them before publishing.
    """,
    excerpt: "An example of a draft post that's not yet published.",
    status: :draft,
    post_type: "post",
    slug: "draft-post-example",
    author_id: admin.id
  }
]

# Create sample pages
sample_pages = [
  %{
    title: "About Us",
    content: """
    # About Our Organization

    Welcome to our website! We're excited to share our story with you.

    ## Our Mission

    We strive to provide excellent service and innovative solutions to our customers.

    ## Our Team

    Our team consists of dedicated professionals who are passionate about what they do.

    ## Contact Information

    Feel free to reach out to us anytime:
    - Email: info@example.com
    - Phone: (555) 123-4567
    - Address: 123 Main St, City, State 12345
    """,
    excerpt: "Learn more about our organization, mission, and team.",
    status: :publish,
    post_type: "page",
    slug: "about",
    author_id: admin.id
  },
  %{
    title: "Contact Us",
    content: """
    # Get In Touch

    We'd love to hear from you! Here are the best ways to reach us:

    ## Contact Information

    **Email:** info@example.com
    **Phone:** (555) 123-4567
    **Address:** 123 Main St, City, State 12345

    ## Business Hours

    - Monday - Friday: 9:00 AM - 5:00 PM
    - Saturday: 10:00 AM - 2:00 PM
    - Sunday: Closed

    ## Contact Form

    *Contact form functionality would be implemented here*
    """,
    excerpt: "Contact information and ways to get in touch with us.",
    status: :publish,
    post_type: "page",
    slug: "contact",
    author_id: admin.id
  },
  %{
    title: "Privacy Policy",
    content: """
    # Privacy Policy

    Last updated: #{Date.utc_today()}

    ## Information We Collect

    We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us.

    ## How We Use Your Information

    We use the information we collect to:
    - Provide, maintain, and improve our services
    - Process transactions
    - Send you technical notices and support messages
    - Communicate with you about products, services, and events

    ## Information Sharing

    We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

    ## Security

    We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

    ## Contact Us

    If you have any questions about this Privacy Policy, please contact us at privacy@example.com.
    """,
    excerpt: "Our privacy policy explaining how we collect, use, and protect your information.",
    status: :publish,
    post_type: "page",
    slug: "privacy-policy",
    author_id: admin.id
  }
]

# Insert sample posts
Enum.each(sample_posts, fn post_attrs ->
  case CMS.create_post(post_attrs) do
    {:ok, post} -> 
      IO.puts("Created post: #{post.title}")
    {:error, changeset} -> 
      IO.puts("Failed to create post: #{inspect(changeset.errors)}")
  end
end)

# Insert sample pages
Enum.each(sample_pages, fn page_attrs ->
  case CMS.create_post(page_attrs) do
    {:ok, page} -> 
      IO.puts("Created page: #{page.title}")
    {:error, changeset} -> 
      IO.puts("Failed to create page: #{inspect(changeset.errors)}")
  end
end)

# Seed default taxonomies
case CMS.seed_default_taxonomies() do
  {:ok, _} -> IO.puts("Created default taxonomies")
  {:error, reason} -> IO.puts("Failed to create taxonomies: #{inspect(reason)}")
end

IO.puts("\n✅ CMS seeding completed!")
IO.puts("Admin login: admin@example.com")
IO.puts("Admin password: password123")
IO.puts("\nSample content created:")
IO.puts("- #{length(sample_posts)} blog posts")
IO.puts("- #{length(sample_pages)} pages")
IO.puts("- Default categories and tags")