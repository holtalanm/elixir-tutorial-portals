defmodule Portal do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Portal.Door, [])
    ]

    opts = [strategy: :simple_one_for_one, name: Portal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defstruct [:left, :right]

  @doc """
    Starts transferring 'data' from 'left' to 'right'.
  """
  def transfer(left, right, data) do
    # First add all data to the portal on the left
    for item <- data do
      Portal.Door.push(left, item)
    end

    # Returns a portal struct we will use next
    %Portal{left: left, right: right}
  end

  @doc """
    Pushes data from the origin Door to the destination Door.
  """
  defp data_transfer(origin, destination) do
    case Portal.Door.pop(origin) do
      :error      -> :ok
      {:ok, h}    -> Portal.Door.push(destination, h)
    end
  end

  @doc """
    Pushes data to the right in the given 'portal'.
  """
  def push_right(portal) do
    data_transfer(portal.left, portal.right)
    # let's return the portal itself
    portal
  end

  @doc """
    Pushes data to the left in the given 'portal'.
  """
  def push_left(portal) do
    data_transfer(portal.right, portal.left)
    # let's return the portal itself
    portal
  end

  @doc """
    Shoots a new door with the given 'color'.
  """
  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end
end

defimpl Inspect, for: Portal do
  def inspect(%Portal{left: left, right: right}, _) do
    left_door = inspect(left)
    right_door = inspect(right)

    left_data = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))

    max = max(String.length(left_door), String.length(left_data))

    """
      #Portal<
        #{String.rjust(left_door, max)} <=> #{right_door}
        #{String.rjust(left_data, max)} <=> #{right_data}
    """
  end
end
