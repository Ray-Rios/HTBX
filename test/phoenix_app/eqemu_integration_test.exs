defmodule PhoenixApp.EqemuIntegrationTest do
  use PhoenixApp.DataCase

  alias PhoenixApp.Accounts
  alias PhoenixApp.EqemuGame

  describe "user registration with EQEmu account creation" do
    test "creates EQEmu account when user registers" do
      user_attrs = %{
        email: "test@example.com",
        name: "Test User",
        password: "password123"
      }

      # Register user
      assert {:ok, user} = Accounts.register_user(user_attrs)
      
      # Verify EQEmu account was created
      assert eqemu_account = EqemuGame.get_account_by_user(user)
      assert eqemu_account.name == user.email
      assert eqemu_account.user_id == user.id
      assert eqemu_account.eqemu_id > 0
    end

    test "syncs email changes to EQEmu account" do
      user_attrs = %{
        email: "original@example.com",
        name: "Test User",
        password: "password123"
      }

      # Register user
      assert {:ok, user} = Accounts.register_user(user_attrs)
      
      # Get original EQEmu account
      original_account = EqemuGame.get_account_by_user(user)
      assert original_account.name == "original@example.com"

      # Update user email
      assert {:ok, updated_user} = Accounts.update_profile(user, %{email: "updated@example.com"})
      
      # Verify EQEmu account was updated
      updated_account = EqemuGame.get_account_by_user(updated_user)
      assert updated_account.name == "updated@example.com"
      assert updated_account.id == original_account.id  # Same account, just updated
    end
  end

  describe "EQEmu authentication" do
    setup do
      user_attrs = %{
        email: "player@example.com",
        name: "Player One",
        password: "gamepass123"
      }
      
      {:ok, user} = Accounts.register_user(user_attrs)
      %{user: user}
    end

    test "authenticates user for EQEmu login", %{user: user} do
      assert {:ok, %{user: auth_user, account: account}} = 
        Accounts.authenticate_for_eqemu("player@example.com", "gamepass123")
      
      assert auth_user.id == user.id
      assert account.name == user.email
      assert account.user_id == user.id
    end

    test "fails authentication with wrong password", %{user: _user} do
      assert {:error, :invalid_password} = 
        Accounts.authenticate_for_eqemu("player@example.com", "wrongpass")
    end

    test "fails authentication with wrong email" do
      assert {:error, :invalid_email} = 
        Accounts.authenticate_for_eqemu("nonexistent@example.com", "anypass")
    end

    test "verifies EQEmu account by name", %{user: user} do
      eqemu_account = EqemuGame.get_account_by_user(user)
      
      assert {:ok, verified_account} = Accounts.verify_eqemu_account(eqemu_account.name)
      assert verified_account.id == eqemu_account.id
      assert verified_account.user.id == user.id
    end
  end

  describe "character creation" do
    setup do
      user_attrs = %{
        email: "player@example.com",
        name: "Player One",
        password: "gamepass123"
      }
      
      {:ok, user} = Accounts.register_user(user_attrs)
      %{user: user}
    end

    test "creates character linked to user and EQEmu account", %{user: user} do
      character_attrs = %{
        name: "Testchar",
        race: 1,  # Human
        class: 1, # Warrior
        gender: 0
      }

      assert {:ok, character} = EqemuGame.create_character(user, character_attrs)
      
      # Verify character is linked to user
      assert character.user_id == user.id
      
      # Verify character is linked to EQEmu account
      eqemu_account = EqemuGame.get_account_by_user(user)
      assert character.account_id == eqemu_account.eqemu_id
      
      # Verify character has unique EQEmu ID
      assert character.eqemu_id > 0
    end

    test "lists user characters", %{user: user} do
      # Create multiple characters
      {:ok, _char1} = EqemuGame.create_character(user, %{name: "Char1", race: 1, class: 1})
      {:ok, _char2} = EqemuGame.create_character(user, %{name: "Char2", race: 2, class: 2})

      characters = EqemuGame.list_user_characters(user)
      assert length(characters) == 2
      assert Enum.all?(characters, fn char -> char.user_id == user.id end)
    end
  end

  describe "cascade deletion behavior" do
    setup do
      user_attrs = %{
        email: "deleteme@example.com",
        name: "Delete Me",
        password: "password123"
      }
      
      {:ok, user} = Accounts.register_user(user_attrs)
      
      # Create some characters
      {:ok, char1} = EqemuGame.create_character(user, %{name: "DeleteChar1", race: 1, class: 1})
      {:ok, char2} = EqemuGame.create_character(user, %{name: "DeleteChar2", race: 2, class: 2})
      
      %{user: user, characters: [char1, char2]}
    end

    test "deleting user cascades to EQEmu account and characters", %{user: user, characters: characters} do
      # Verify data exists before deletion
      assert eqemu_account = EqemuGame.get_account_by_user(user)
      assert length(EqemuGame.list_user_characters(user)) == 2
      
      # Delete the user
      assert {:ok, _deleted_user} = Accounts.delete_user_with_eqemu_cleanup(user)
      
      # Verify everything was deleted
      assert is_nil(Accounts.get_user(user.id))
      assert is_nil(EqemuGame.get_account_by_user(user))
      
      # Verify characters were deleted
      for char <- characters do
        assert_raise Ecto.NoResultsError, fn ->
          EqemuGame.get_character!(char.id)
        end
      end
    end

    test "deleting EQEmu account cascades to characters", %{user: user, characters: characters} do
      eqemu_account = EqemuGame.get_account_by_user(user)
      
      # Delete the EQEmu account directly
      assert {:ok, _deleted_account} = Repo.delete(eqemu_account)
      
      # Verify characters were deleted
      for char <- characters do
        assert_raise Ecto.NoResultsError, fn ->
          EqemuGame.get_character!(char.id)
        end
      end
      
      # User should still exist
      assert Accounts.get_user(user.id)
    end
  end
end