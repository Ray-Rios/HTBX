# Game CMS Seeds
alias PhoenixApp.{Repo, Accounts}
alias PhoenixApp.GameCMS.{Character, Item, Quest, Guild, ChatMessage}

# Create a test user if it doesn't exist
user = case Accounts.get_user_by_email("admin@test.com") do
  nil ->
    {:ok, user} = Accounts.register_user(%{
      "email" => "admin@test.com",
      "password" => "password123",
      "name" => "Admin User",
      "role" => "admin"
    })
    user
  user -> user
end

# Create sample guilds
guild1 = Repo.insert!(%Guild{
  name: "Dragon Slayers",
  description: "Elite guild focused on defeating the most powerful dragons",
  level: 15,
  experience: 45000,
  max_members: 100,
  guild_type: "hardcore",
  requirements: "Level 50+, Dragon kill experience required",
  active: true,
  leader_id: user.id
})

guild2 = Repo.insert!(%Guild{
  name: "Peaceful Traders",
  description: "A merchant guild focused on trade and commerce",
  level: 8,
  experience: 12000,
  max_members: 50,
  guild_type: "casual",
  requirements: "Level 10+, Trading skills preferred",
  active: true,
  leader_id: user.id
})

# Create sample characters
character1 = Repo.insert!(%Character{
  name: "Thorin Ironforge",
  class: "Warrior",
  level: 65,
  experience: 125000,
  health: 850,
  max_health: 850,
  mana: 200,
  max_mana: 200,
  gold: 15000,
  current_zone: "Dragon's Lair",
  strength: 85,
  agility: 45,
  intelligence: 25,
  vitality: 80,
  attack_power: 320,
  defense: 180,
  crit_chance: 15.5,
  attack_speed: 1.2,
  user_id: user.id,
  guild_id: guild1.id,
  last_active: DateTime.utc_now()
})

character2 = Repo.insert!(%Character{
  name: "Luna Starweaver",
  class: "Mage",
  level: 58,
  experience: 98000,
  health: 450,
  max_health: 450,
  mana: 800,
  max_mana: 800,
  gold: 8500,
  current_zone: "Mystic Forest",
  strength: 20,
  agility: 35,
  intelligence: 95,
  vitality: 40,
  attack_power: 280,
  defense: 85,
  crit_chance: 22.0,
  attack_speed: 0.8,
  user_id: user.id,
  guild_id: guild1.id,
  last_active: DateTime.utc_now()
})

character3 = Repo.insert!(%Character{
  name: "Swift Shadowstep",
  class: "Rogue",
  level: 42,
  experience: 45000,
  health: 520,
  max_health: 520,
  mana: 300,
  max_mana: 300,
  gold: 12000,
  current_zone: "Thieves' Quarter",
  strength: 55,
  agility: 88,
  intelligence: 45,
  vitality: 50,
  attack_power: 245,
  defense: 120,
  crit_chance: 28.5,
  attack_speed: 1.8,
  user_id: user.id,
  guild_id: guild2.id,
  last_active: DateTime.utc_now()
})

# Create sample items
Repo.insert!(%Item{
  name: "Dragon Slayer Sword",
  description: "A legendary blade forged from dragon scales and blessed by ancient magic",
  item_type: "weapon",
  rarity: "legendary",
  level_requirement: 60,
  price: 50000,
  icon: "dragon_sword.png",
  usable: false,
  stackable: false,
  max_stack: 1,
  attack_power: 180,
  defense: 0,
  strength_bonus: 25,
  agility_bonus: 10
})

Repo.insert!(%Item{
  name: "Mystic Staff of Elements",
  description: "A powerful staff that channels elemental magic",
  item_type: "weapon",
  rarity: "epic",
  level_requirement: 45,
  price: 25000,
  icon: "mystic_staff.png",
  usable: false,
  stackable: false,
  max_stack: 1,
  attack_power: 120,
  intelligence_bonus: 35,
  mana_bonus: 200
})

Repo.insert!(%Item{
  name: "Health Potion",
  description: "Restores 500 health points instantly",
  item_type: "consumable",
  rarity: "common",
  level_requirement: 1,
  price: 50,
  icon: "health_potion.png",
  usable: true,
  stackable: true,
  max_stack: 99,
  health_restore: 500
})

Repo.insert!(%Item{
  name: "Mana Elixir",
  description: "Restores 300 mana points instantly",
  item_type: "consumable",
  rarity: "common",
  level_requirement: 1,
  price: 75,
  icon: "mana_elixir.png",
  usable: true,
  stackable: true,
  max_stack: 99,
  mana_restore: 300
})

Repo.insert!(%Item{
  name: "Dragon Scale Armor",
  description: "Heavy armor crafted from ancient dragon scales",
  item_type: "armor",
  rarity: "epic",
  level_requirement: 55,
  price: 35000,
  icon: "dragon_armor.png",
  usable: false,
  stackable: false,
  max_stack: 1,
  defense: 250,
  health_bonus: 300,
  vitality_bonus: 20
})

# Create sample quests
Repo.insert!(%Quest{
  title: "The Dragon's Hoard",
  description: "Ancient dragons have been terrorizing the countryside. Investigate their lair and put an end to their reign of terror.",
  objective: "Defeat 3 Ancient Dragons and retrieve the Golden Crown",
  difficulty: "legendary",
  level_requirement: 60,
  xp_reward: 15000,
  gold_reward: 5000,
  item_rewards: [1, 5], # Dragon Slayer Sword, Dragon Scale Armor
  prerequisites: [],
  zone: "Dragon's Lair",
  npc_giver: "King Aldric",
  active: true,
  repeatable: false,
  max_completions: 1
})

Repo.insert!(%Quest{
  title: "Mystic Forest Exploration",
  description: "The Mystic Forest holds many secrets. Explore its depths and uncover the ancient magic within.",
  objective: "Collect 10 Mystic Crystals and defeat the Forest Guardian",
  difficulty: "hard",
  level_requirement: 40,
  xp_reward: 8000,
  gold_reward: 2000,
  item_rewards: [2], # Mystic Staff of Elements
  prerequisites: [],
  zone: "Mystic Forest",
  npc_giver: "Elder Sage Miriel",
  active: true,
  repeatable: false,
  max_completions: 1
})

Repo.insert!(%Quest{
  title: "Daily Herb Gathering",
  description: "The local alchemist needs fresh herbs for potion making. Gather herbs from around the town.",
  objective: "Collect 20 Healing Herbs",
  difficulty: "easy",
  level_requirement: 5,
  xp_reward: 500,
  gold_reward: 100,
  item_rewards: [3, 4], # Health Potion, Mana Elixir
  prerequisites: [],
  zone: "Starting Town",
  npc_giver: "Alchemist Gwendolyn",
  active: true,
  repeatable: true,
  max_completions: 999
})

Repo.insert!(%Quest{
  title: "Thieves' Guild Initiation",
  description: "Prove your worth to the Thieves' Guild by completing a series of stealth missions.",
  objective: "Complete 5 stealth missions without being detected",
  difficulty: "medium",
  level_requirement: 25,
  xp_reward: 3000,
  gold_reward: 1500,
  item_rewards: [],
  prerequisites: [],
  zone: "Thieves' Quarter",
  npc_giver: "Shadow Master Vex",
  active: true,
  repeatable: false,
  max_completions: 1
})

# Create sample chat messages
Repo.insert!(%ChatMessage{
  message: "Welcome to the Dragon Slayers guild! Ready for some epic adventures?",
  channel: "guild",
  message_type: "chat",
  user_id: user.id,
  character_id: character1.id
})

Repo.insert!(%ChatMessage{
  message: "Looking for a group to tackle the Mystic Forest quest. Anyone interested?",
  channel: "global",
  message_type: "chat",
  user_id: user.id,
  character_id: character2.id
})

Repo.insert!(%ChatMessage{
  message: "Selling rare items at the market square. Come check out my wares!",
  channel: "trade",
  message_type: "chat",
  user_id: user.id,
  character_id: character3.id
})

IO.puts("Game CMS seeds completed successfully!")
IO.puts("Created:")
IO.puts("- 2 Guilds")
IO.puts("- 3 Characters")
IO.puts("- 5 Items")
IO.puts("- 4 Quests")
IO.puts("- 3 Chat Messages")