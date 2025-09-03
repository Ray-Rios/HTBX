# Chat Seeds
alias PhoenixApp.{Repo, Chat}

# Create default channels if they don't exist
channels = [
  %{
    name: "general",
    description: "General discussion for everyone",
    channel_type: "text",
    position: 1
  },
  %{
    name: "random",
    description: "Random conversations and off-topic discussions",
    channel_type: "text",
    position: 2
  },
  %{
    name: "announcements",
    description: "Important announcements and updates",
    channel_type: "text",
    position: 3
  },
  %{
    name: "help",
    description: "Get help and support from the community",
    channel_type: "text",
    position: 4
  },
  %{
    name: "General Voice",
    description: "General voice chat for everyone",
    channel_type: "voice",
    position: 1
  },
  %{
    name: "Gaming Voice",
    description: "Voice chat for gaming sessions",
    channel_type: "voice",
    position: 2
  }
]

Enum.each(channels, fn channel_attrs ->
  case Repo.get_by(Chat.Channel, name: channel_attrs.name) do
    nil ->
      case Chat.create_channel(channel_attrs) do
        {:ok, channel} ->
          IO.puts("Created channel: #{channel.name}")
        {:error, changeset} ->
          IO.puts("Failed to create channel #{channel_attrs.name}: #{inspect(changeset.errors)}")
      end
    _existing ->
      IO.puts("Channel #{channel_attrs.name} already exists")
  end
end)

IO.puts("Chat seeds completed!")