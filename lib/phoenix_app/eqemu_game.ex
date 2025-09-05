defmodule PhoenixApp.EqemuGame do
  @moduledoc """
  The EqemuGame context.
  """

  import Ecto.Query, warn: false
  alias PhoenixApp.Repo

  alias PhoenixApp.EqemuGame.{
    Character,
    CharacterStats,
    Item
  }

  # Characters
  def list_characters do
    Character
    |> order_by([c], c.name)
    |> Repo.all()
  end

  def list_user_characters(user) do
    Character
    |> where([c], c.user_id == ^user.id)
    |> order_by([c], c.name)
    |> Repo.all()
  end

  def get_character!(id), do: Repo.get!(Character, id)

  def get_character_with_details(id) do
    Character
    |> where([c], c.id == ^id)
    |> preload([:stats])
    |> Repo.one()
  end

  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  # Character Stats
  def get_character_stats(character_id) do
    CharacterStats
    |> where([cs], cs.character_id == ^character_id)
    |> Repo.one()
  end

  def create_character_stats(character_id, attrs \\ %{}) do
    %CharacterStats{}
    |> CharacterStats.changeset(Map.put(attrs, :character_id, character_id))
    |> Repo.insert()
  end

  def update_character_stats(%CharacterStats{} = stats, attrs) do
    stats
    |> CharacterStats.changeset(attrs)
    |> Repo.update()
  end

  # Items
  def list_items(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    filter = Keyword.get(opts, :filter)

    query = Item

    query =
      if filter do
        where(query, [i], ilike(i.name, ^"%#{filter}%"))
      else
        query
      end

    query
    |> order_by([i], i.name)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_by_item_id(item_id) do
    Item
    |> where([i], i.item_id == ^item_id)
    |> Repo.one()
  end

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  # Placeholder functions for missing modules
  def list_zones, do: []
  def list_guilds, do: []
  def list_npcs(_opts \\ []), do: []
  def list_spells(_opts \\ []), do: []
  def list_tasks(_opts \\ []), do: []
  def get_character_quests(_character_id), do: []

  # Missing functions referenced in resolver - placeholder implementations
  def create_character(_user, attrs), do: create_character(attrs)
  def search_characters(_query), do: list_characters()
  def search_items(_query), do: list_items()
  def search_zones(_query), do: list_zones()
  def get_character_inventory(_character_id), do: []
  def create_inventory_item(_character_id, _input), do: {:ok, %{}}
  def get_zone!(_id), do: %{}
  def get_zone_by_zone_id(_zone_id), do: nil
  def get_zone_by_short_name(_short_name), do: nil
  def zone_character(_character_id, _zone_id, _x, _y, _z, _heading), do: {:ok, %{}}
  def get_guild!(_id), do: %{}
  def get_character_guild(_character_id), do: nil
  def join_guild(_character_id, _guild_id), do: {:ok, %{}}
  def leave_guild(_character_id), do: {:ok, %{}}
  def get_available_quests(_character_id), do: []
  def accept_quest(_character_id, _task_id), do: {:ok, %{}}
  def complete_quest(_character_id, _task_id), do: {:ok, %{}}

  # Game mechanics
  def enter_world(character) do
    # Initialize character in world - placeholder implementation
    {:ok, character}
  end

  # Utility functions
  def get_character_level_range(level) do
    case level do
      l when l <= 10 -> {1, 10}
      l when l <= 20 -> {11, 20}
      l when l <= 30 -> {21, 30}
      l when l <= 40 -> {31, 40}
      l when l <= 50 -> {41, 50}
      l when l <= 60 -> {51, 60}
      _ -> {61, 65}
    end
  end

  def calculate_experience_for_level(level) do
    # EverQuest experience formula
    base_exp = 1000
    multiplier = :math.pow(level, 2.5)
    trunc(base_exp * multiplier)
  end

  def get_race_name(race_id) do
    case race_id do
      1 -> "Human"
      2 -> "Barbarian"
      3 -> "Erudite"
      4 -> "Wood Elf"
      5 -> "High Elf"
      6 -> "Dark Elf"
      7 -> "Half Elf"
      8 -> "Dwarf"
      9 -> "Troll"
      10 -> "Ogre"
      11 -> "Halfling"
      12 -> "Gnome"
      128 -> "Iksar"
      130 -> "Vah Shir"
      330 -> "Froglok"
      522 -> "Drakkin"
      _ -> "Unknown"
    end
  end

  def get_class_name(class_id) do
    case class_id do
      1 -> "Warrior"
      2 -> "Cleric"
      3 -> "Paladin"
      4 -> "Ranger"
      5 -> "Shadow Knight"
      6 -> "Druid"
      7 -> "Monk"
      8 -> "Bard"
      9 -> "Rogue"
      10 -> "Shaman"
      11 -> "Necromancer"
      12 -> "Wizard"
      13 -> "Magician"
      14 -> "Enchanter"
      15 -> "Beastlord"
      16 -> "Berserker"
      _ -> "Unknown"
    end
  end

  def get_deity_name(deity_id) do
    case deity_id do
      201 -> "Bertoxxulous"
      202 -> "Brell Serilis"
      203 -> "Cazic Thule"
      204 -> "Erollisi Marr"
      205 -> "Bristlebane"
      206 -> "Innoruuk"
      207 -> "Karana"
      208 -> "Mithaniel Marr"
      209 -> "Prexus"
      210 -> "Quellious"
      211 -> "Rallos Zek"
      212 -> "Rodcet Nife"
      213 -> "Solusek Ro"
      214 -> "The Tribunal"
      215 -> "Tunare"
      216 -> "Veeshan"
      396 -> "Agnostic"
      _ -> "Unknown"
    end
  end
end