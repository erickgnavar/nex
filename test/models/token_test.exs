defmodule Nex.TokenTest do
  use Nex.ModelCase

  alias Nex.Token

  @valid_attrs %{expire_at: %{day: 17, month: 4, year: 2010}, value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Token.changeset(%Token{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Token.changeset(%Token{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "generate new token" do
    tokens = Repo.all(Token)
    assert length(tokens) == 0
    assert [Token.new] == Repo.all(Token)
  end

  test "check token not found" do
    assert {:error, "Token not found"} = Token.check("")
  end

  test "check not expired token" do
    token_value = Token.new().value
    assert {:ok, %Token{value: token_value}} = Token.check(token_value)
  end

  test "check expired token" do
    token = Token.new
    expired_date = Timex.add(Timex.today, Timex.Duration.from_days(-1))
    changeset = Token.changeset(token, %{expire_at: expired_date})
    updated_token = Repo.update!(changeset)
    assert {:error, "Token expired"} = Token.check(updated_token.value)
  end
end
