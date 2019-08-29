defmodule PoisonIvy do

  def message_sent(message_id) do
    Poison.encode!(
      %{
        "type" => "message_sent",
        "message_id" => message_id,
      }
    )
  end

  def message_received(message, sender) do
    Poison.encode!(
      %{
        "type" => "message_received",
        "message" => message,
        "sender" => sender,
      }
    )
  end

  def welcome_message_self(list) do
    Poison.encode!(
      %{
        "type" => "entered_chat",
        "members" => list,
      }
    )
  end

  def welcome_message_all(rookie) do
    Poison.encode!(
      %{
        "type" => "welcome",
        "who" => rookie,
      }
    )
  end

  def goodbye_message(goner) do
    Poison.encode!(
      %{
        "type" => "gone",
        "who" => goner,
      }
    )
  end
  def theme_data do
    one()
  end
  def one do
    %{
      "received_bubble_color" => "0xFF40C4FF",
      "sent_bubble_color"=>"3329330",
      "main_theme_color" => "10398633",
      "background_color" => "1171908"
    }
  end
  def two do
    %{
      "received_bubble_color" => "0xFFC06C84",
      "sent_bubble_color"=>"65280",
      "main_theme_color" => "0xFF6C5B7B",
      "background_color" => "0xFFF8B195"
    }
  end
end
