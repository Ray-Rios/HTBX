defmodule PhoenixApp.EqemuGame do
  @moduledoc """
  The EqemuGame context.
  """

  import Ecto.Query, warn: false
  alias PhoenixApp.Repo

  alias PhoenixApp.EqemuGame.{
    Character,
    CharacterStats,
    Item,
    CharacterInventory,
    Guild,
    GuildMember,
    Zone,
    NPC,
    NPCSpawn,
    Spell,
    Task,
    CharacterTask,
    Faction,
    CharacterFactionValue,
    LootTable,
    LootTableEntry,
    Merchant,
    Door
  }

  # Characters
  def list_characters do
    Repo.all(Character)
  end

  def list_user_characters(user) do
    Character
    |> where([c], c.user_id == ^user.id)
    |> where([c], is_nil(c.deleted_at))
    |> order_by([c], desc: c.last_login)
    |> Repo.all()
  end

  def get_character!(id), do: Repo.get!(Character, id)

  def get_character_by_name(name) do
    Character
    |> where([c], c.name == ^name)
    |> where([c], is_nil(c.deleted_at))
    |> Repo.one()
  end

  def create_character(user, attrs \\ %{}) do
    %Character{}
    |> Character.changeset(Map.put(attrs, :user_id, user.id))
    |> Repo.insert()
  end

  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def delete_character(%Character{} = character) do
    character
    |> Character.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
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
    item_type = Keyword.get(opts, :item_type)

    query = Item

    query =
      if filter do
        where(query, [i], ilike(i.name, ^"%#{filter}%"))
      else
        query
      end

    query =
      if item_type do
        where(query, [i], i.item_type == ^item_type)
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

  # Character Inventory
  def get_character_inventory(character_id) do
    CharacterInventory
    |> where([ci], ci.character_id == ^character_id)
    |> order_by([ci], ci.slotid)
    |> preload(:item)
    |> Repo.all()
  end

  def create_inventory_item(character_id, attrs \\ %{}) do
    %CharacterInventory{}
    |> CharacterInventory.changeset(Map.put(attrs, :character_id, character_id))
    |> Repo.insert()
  end

  def update_inventory_item(%CharacterInventory{} = inventory_item, attrs) do
    inventory_item
    |> CharacterInventory.changeset(attrs)
    |> Repo.update()
  end

  def delete_inventory_item(%CharacterInventory{} = inventory_item) do
    Repo.delete(inventory_item)
  end

  # Guilds
  def list_guilds do
    Guild
    |> order_by([g], g.name)
    |> Repo.all()
  end

  def get_guild!(id), do: Repo.get!(Guild, id)

  def get_guild_by_guild_id(guild_id) do
    Guild
    |> where([g], g.guild_id == ^guild_id)
    |> Repo.one()
  end

  def get_character_guild(character_id) do
    character = get_character!(character_id)
    
    if character.guild_id > 0 do
      get_guild_by_guild_id(character.guild_id)
    else
      nil
    end
  end

  def create_guild(attrs \\ %{}) do
    %Guild{}
    |> Guild.changeset(attrs)
    |> Repo.insert()
  end

  def update_guild(%Guild{} = guild, attrs) do
    guild
    |> Guild.changeset(attrs)
    |> Repo.update()
  end

  def delete_guild(%Guild{} = guild) do
    Repo.delete(guild)
  end

  # Guild Members
  def get_guild_members(guild_id) do
    GuildMember
    |> where([gm], gm.guild_id == ^guild_id)
    |> preload(:character)
    |> order_by([gm], gm.rank_)
    |> Repo.all()
  end

  def join_guild(character_id, guild_id, rank \\ 0) do
    %GuildMember{}
    |> GuildMember.changeset(%{
      character_id: character_id,
      guild_id: guild_id,
      rank_: rank
    })
    |> Repo.insert()
  end

  def leave_guild(character_id) do
    GuildMember
    |> where([gm], gm.character_id == ^character_id)
    |> Repo.delete_all()
  end

  # Zones
  def list_zones do
    Zone
    |> order_by([z], z.long_name)
    |> Repo.all()
  end

  def get_zone!(id), do: Repo.get!(Zone, id)

  def get_zone_by_zone_id(zone_id) do
    Zone
    |> where([z], z.zoneidnumber == ^zone_id)
    |> Repo.one()
  end

  def get_zone_by_short_name(short_name) do
    Zone
    |> where([z], z.short_name == ^short_name)
    |> Repo.one()
  end

  def create_zone(attrs \\ %{}) do
    %Zone{}
    |> Zone.changeset(attrs)
    |> Repo.insert()
  end

  def update_zone(%Zone{} = zone, attrs) do
    zone
    |> Zone.changeset(attrs)
    |> Repo.update()
  end

  def delete_zone(%Zone{} = zone) do
    Repo.delete(zone)
  end

  # NPCs
  def list_npcs(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    filter = Keyword.get(opts, :filter)

    query = NPC

    query =
      if filter do
        where(query, [n], ilike(n.name, ^"%#{filter}%"))
      else
        query
      end

    query
    |> order_by([n], n.name)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def get_npc!(id), do: Repo.get!(NPC, id)

  def get_npc_by_npc_id(npc_id) do
    NPC
    |> where([n], n.npc_id == ^npc_id)
    |> Repo.one()
  end

  def create_npc(attrs \\ %{}) do
    %NPC{}
    |> NPC.changeset(attrs)
    |> Repo.insert()
  end

  def update_npc(%NPC{} = npc, attrs) do
    npc
    |> NPC.changeset(attrs)
    |> Repo.update()
  end

  def delete_npc(%NPC{} = npc) do
    Repo.delete(npc)
  end

  # Spells
  def list_spells(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    filter = Keyword.get(opts, :filter)

    query = Spell

    query =
      if filter do
        where(query, [s], ilike(s.name, ^"%#{filter}%"))
      else
        query
      end

    query
    |> order_by([s], s.name)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def get_spell!(id), do: Repo.get!(Spell, id)

  def get_spell_by_spell_id(spell_id) do
    Spell
    |> where([s], s.spell_id == ^spell_id)
    |> Repo.one()
  end

  def create_spell(attrs \\ %{}) do
    %Spell{}
    |> Spell.changeset(attrs)
    |> Repo.insert()
  end

  def update_spell(%Spell{} = spell, attrs) do
    spell
    |> Spell.changeset(attrs)
    |> Repo.update()
  end

  def delete_spell(%Spell{} = spell) do
    Repo.delete(spell)
  end

  # Tasks (Quests)
  def list_tasks(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    filter = Keyword.get(opts, :filter)

    query = Task

    query =
      if filter do
        where(query, [t], ilike(t.title, ^"%#{filter}%"))
      else
        query
      end

    query
    |> order_by([t], t.title)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def get_available_quests(character_id) do
    character = get_character!(character_id)
    
    # Get quests available for character's level
    Task
    |> where([t], t.minlevel <= ^character.level)
    |> where([t], t.maxlevel >= ^character.level)
    |> order_by([t], t.title)
    |> Repo.all()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def get_task_by_task_id(task_id) do
    Task
    |> where([t], t.task_id == ^task_id)
    |> Repo.one()
  end

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  # Character Tasks
  def get_character_quests(character_id) do
    CharacterTask
    |> where([ct], ct.character_id == ^character_id)
    |> preload(:task)
    |> order_by([ct], desc: ct.acceptedtime)
    |> Repo.all()
  end

  def accept_quest(character_id, task_id) do
    %CharacterTask{}
    |> CharacterTask.changeset(%{
      character_id: character_id,
      task_id: task_id,
      acceptedtime: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def complete_quest(character_id, task_id) do
    character_task = 
      CharacterTask
      |> where([ct], ct.character_id == ^character_id)
      |> where([ct], ct.task_id == ^task_id)
      |> Repo.one()

    if character_task do
      character_task
      |> CharacterTask.changeset(%{completedtime: DateTime.utc_now()})
      |> Repo.update()
    else
      {:error, :not_found}
    end
  end

  # Zone Character
  def zone_character(character_id, zone_id, x \\ nil, y \\ nil, z \\ nil, heading \\ nil) do
    zone = get_zone_by_zone_id(zone_id)
    
    if zone do
      attrs = %{
        zone_id: zone_id,
        x: x || zone.safe_x,
        y: y || zone.safe_y,
        z: z || zone.safe_z,
        heading: heading || zone.safe_heading
      }
      
      character = get_character!(character_id)
      update_character(character, attrs)
    else
      {:error, :zone_not_found}
    end
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