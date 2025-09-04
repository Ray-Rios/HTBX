defmodule PhoenixApp.EqemuGame.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "eqemu_items" do
    field :item_id, :integer
    field :name, :string
    field :lore, :string
    field :idfile, :string
    field :lorefile, :string
    field :nodrop, :integer, default: 0
    field :norent, :integer, default: 0
    field :nodonate, :integer, default: 0
    field :cantune, :integer, default: 0
    field :noswap, :integer, default: 0
    field :size, :integer, default: 0
    field :weight, :integer, default: 0
    field :item_type, :integer, default: 0
    field :icon, :integer, default: 0
    field :price, :integer, default: 0
    field :sellrate, :float, default: 1.0
    field :favor, :integer, default: 0
    field :guildfavor, :integer, default: 0
    field :pointtype, :integer, default: 0
    field :bagtype, :integer, default: 0
    field :bagslots, :integer, default: 0
    field :bagsize, :integer, default: 0
    field :bagwr, :integer, default: 0
    field :book, :integer, default: 0
    field :booktype, :integer, default: 0
    field :filename, :string
    field :banedmgrace, :integer, default: 0
    field :banedmgbody, :integer, default: 0
    field :banedmgamt, :integer, default: 0
    field :magic, :integer, default: 0
    field :casttime_, :integer, default: 0
    field :reqlevel, :integer, default: 0
    field :bardtype, :integer, default: 0
    field :bardvalue, :integer, default: 0
    field :light, :integer, default: 0
    field :delay, :integer, default: 0
    field :elemdmgtype, :integer, default: 0
    field :elemdmgamt, :integer, default: 0
    field :range_, :integer, default: 0
    field :damage, :integer, default: 0
    field :color, :integer, default: 0
    field :prestige, :integer, default: 0
    field :classes, :integer, default: 0
    field :races, :integer, default: 0
    field :deity, :integer, default: 0
    field :skillmodtype, :integer, default: 0
    field :skillmodvalue, :integer, default: 0
    field :banedmgraceamt, :integer, default: 0
    field :banedmgbodyamt, :integer, default: 0
    field :worntype, :integer, default: 0
    field :ac, :integer, default: 0
    field :accuracy, :integer, default: 0
    field :aagi, :integer, default: 0
    field :acha, :integer, default: 0
    field :adex, :integer, default: 0
    field :aint, :integer, default: 0
    field :asta, :integer, default: 0
    field :astr, :integer, default: 0
    field :awis, :integer, default: 0
    field :hp, :integer, default: 0
    field :mana, :integer, default: 0
    field :endur, :integer, default: 0
    field :atk, :integer, default: 0
    field :cr, :integer, default: 0
    field :dr, :integer, default: 0
    field :fr, :integer, default: 0
    field :mr, :integer, default: 0
    field :pr, :integer, default: 0
    field :svcorruption, :integer, default: 0
    field :haste, :integer, default: 0
    field :damageshield, :integer, default: 0

    has_many :character_inventory, PhoenixApp.EqemuGame.CharacterInventory

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :item_id, :name, :lore, :idfile, :lorefile, :nodrop, :norent, :nodonate,
      :cantune, :noswap, :size, :weight, :item_type, :icon, :price, :sellrate,
      :favor, :guildfavor, :pointtype, :bagtype, :bagslots, :bagsize, :bagwr,
      :book, :booktype, :filename, :banedmgrace, :banedmgbody, :banedmgamt,
      :magic, :casttime_, :reqlevel, :bardtype, :bardvalue, :light, :delay,
      :elemdmgtype, :elemdmgamt, :range_, :damage, :color, :prestige, :classes,
      :races, :deity, :skillmodtype, :skillmodvalue, :banedmgraceamt,
      :banedmgbodyamt, :worntype, :ac, :accuracy, :aagi, :acha, :adex, :aint,
      :asta, :astr, :awis, :hp, :mana, :endur, :atk, :cr, :dr, :fr, :mr, :pr,
      :svcorruption, :haste, :damageshield
    ])
    |> validate_required([:item_id, :name])
    |> validate_length(:name, min: 1, max: 64)
    |> validate_number(:item_id, greater_than: 0)
    |> unique_constraint(:item_id)
  end

  def item_type_name(%__MODULE__{item_type: item_type}) do
    case item_type do
      0 -> "1H Slashing"
      1 -> "2H Slashing"
      2 -> "1H Piercing"
      3 -> "1H Blunt"
      4 -> "2H Blunt"
      5 -> "Archery"
      8 -> "Shield"
      10 -> "Armor"
      11 -> "Misc"
      14 -> "Food"
      15 -> "Drink"
      16 -> "Light"
      17 -> "Combinable"
      18 -> "Bandage"
      19 -> "Throwing"
      20 -> "Spell"
      21 -> "Potion"
      22 -> "Wind Instrument"
      23 -> "Stringed Instrument"
      24 -> "Brass Instrument"
      25 -> "Percussion Instrument"
      26 -> "Arrow"
      27 -> "Jewelry"
      29 -> "Book"
      30 -> "Note"
      31 -> "Key"
      32 -> "Coin"
      33 -> "2H Piercing"
      34 -> "Fishing Pole"
      35 -> "Fishing Bait"
      36 -> "Alcohol"
      37 -> "Key (bis)"
      38 -> "Compass"
      39 -> "Poison"
      40 -> "Lockpick"
      42 -> "Hand to Hand"
      45 -> "Martial"
      _ -> "Unknown"
    end
  end

  def slot_name(slot_id) do
    case slot_id do
      0 -> "Charm"
      1 -> "Left Ear"
      2 -> "Head"
      3 -> "Face"
      4 -> "Right Ear"
      5 -> "Neck"
      6 -> "Shoulders"
      7 -> "Arms"
      8 -> "Back"
      9 -> "Left Wrist"
      10 -> "Right Wrist"
      11 -> "Range"
      12 -> "Hands"
      13 -> "Primary"
      14 -> "Secondary"
      15 -> "Left Ring"
      16 -> "Right Ring"
      17 -> "Chest"
      18 -> "Legs"
      19 -> "Feet"
      20 -> "Waist"
      21 -> "Powersource"
      22 -> "Ammo"
      _ when slot_id >= 23 and slot_id <= 30 -> "General #{slot_id - 22}"
      _ when slot_id >= 2000 and slot_id <= 2007 -> "Bank #{slot_id - 1999}"
      _ when slot_id >= 2500 and slot_id <= 2503 -> "Shared Bank #{slot_id - 2499}"
      _ -> "Unknown Slot"
    end
  end

  def is_weapon?(%__MODULE__{item_type: item_type}) do
    item_type in [0, 1, 2, 3, 4, 5, 19, 33, 42, 45]
  end

  def is_armor?(%__MODULE__{item_type: item_type}) do
    item_type in [8, 10]
  end

  def is_jewelry?(%__MODULE__{item_type: item_type}) do
    item_type == 27
  end

  def is_container?(%__MODULE__{bagslots: bagslots}) do
    bagslots > 0
  end

  def is_magic?(%__MODULE__{magic: magic}) do
    magic == 1
  end

  def is_lore?(%__MODULE__{lore: lore}) do
    not is_nil(lore) and String.length(lore) > 0
  end

  def is_nodrop?(%__MODULE__{nodrop: nodrop}) do
    nodrop == 1
  end

  def is_norent?(%__MODULE__{norent: norent}) do
    norent == 1
  end

  def can_use_class?(%__MODULE__{classes: classes}, class_id) do
    import Bitwise
    (classes &&& (1 <<< (class_id - 1))) != 0
  end

  def can_use_race?(%__MODULE__{races: races}, race_id) do
    import Bitwise
    race_bit = case race_id do
      1 -> 0   # Human
      2 -> 1   # Barbarian
      3 -> 2   # Erudite
      4 -> 3   # Wood Elf
      5 -> 4   # High Elf
      6 -> 5   # Dark Elf
      7 -> 6   # Half Elf
      8 -> 7   # Dwarf
      9 -> 8   # Troll
      10 -> 9  # Ogre
      11 -> 10 # Halfling
      12 -> 11 # Gnome
      128 -> 12 # Iksar
      130 -> 13 # Vah Shir
      330 -> 14 # Froglok
      522 -> 15 # Drakkin
      _ -> -1
    end
    
    if race_bit >= 0 do
      (races &&& (1 <<< race_bit)) != 0
    else
      false
    end
  end

  def total_stats(%__MODULE__{} = item) do
    item.astr + item.asta + item.acha + item.adex + item.aint + item.aagi + item.awis
  end

  def total_resistances(%__MODULE__{} = item) do
    item.mr + item.fr + item.cr + item.pr + item.dr + item.svcorruption
  end
end