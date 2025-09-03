# Simple script to create sample game data via GraphQL
# This can be run from the web interface or via API calls

IO.puts("Creating sample game data...")

# Sample GraphQL mutations to create data
sample_mutations = [
  # Create a guild
  """
  mutation {
    createGuild(input: {
      name: "Dragon Slayers"
      description: "Elite guild for dragon hunting"
      level: 10
      experience: 25000
      maxMembers: 50
      guildType: "hardcore"
      requirements: "Level 30+ required"
      active: true
    }) {
      id
      name
      level
    }
  }
  """,
  
  # Create items
  """
  mutation {
    createItem(input: {
      name: "Dragon Slayer Sword"
      description: "A legendary blade forged from dragon scales"
      itemType: "weapon"
      rarity: "legendary"
      levelRequirement: 50
      price: 10000
      usable: false
      stackable: false
      maxStack: 1
      attackPower: 150
      strengthBonus: 20
    }) {
      id
      name
      rarity
    }
  }
  """,
  
  # Create a quest
  """
  mutation {
    createQuest(input: {
      title: "The Dragon's Lair"
      description: "Venture into the dragon's lair and defeat the ancient beast"
      objective: "Defeat the Ancient Dragon"
      difficulty: "legendary"
      levelRequirement: 50
      xpReward: 10000
      goldReward: 5000
      zone: "Dragon Mountains"
      npcGiver: "King Aldric"
      active: true
      repeatable: false
    }) {
      id
      title
      difficulty
    }
  }
  """
]

IO.puts("Sample GraphQL mutations created!")
IO.puts("You can use these mutations in the GraphQL playground or admin interface:")
IO.puts("Visit: http://localhost:4000/game-cms-admin")

Enum.each(sample_mutations, fn mutation ->
  IO.puts("\n" <> String.duplicate("=", 50))
  IO.puts(mutation)
end)

IO.puts("\n" <> String.duplicate("=", 50))
IO.puts("Sample data creation script completed!")