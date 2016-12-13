defmodule ComplexNum do
  defstruct [:real, :imaginary, mode: Cartesian]

  alias ComplexNum.{Cartesian, Polar}

  @behaviour Numeric

  def new(real, imaginary \\ 0, opts \\ [polar: false])
  def new(real, imaginary, opts)  do
    if opts[:polar] do
      Polar.new(real, imaginary)
    else
      Cartesian.new(real, imaginary)
    end
  end

  delegatable_binary_funs = [:add, :sub, :mult, :div, :pow]


  def add(ca = %ComplexNum{mode: Polar}, cb = %ComplexNum{}) do
    add(Polar.to_cartesian(ca), cb)
  end
  def add(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Polar}) do
    add(ca, Polar.to_cartesian(cb))
  end
  def add(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do
    Cartesian.add(ca, cb)
  end


end

defimpl Inspect, for: ComplexNum do
  def inspect(polar = %ComplexNum{mode: Polar}, _opts) do
    "#ComplexNum (Polar) <#{inspect(polar.real)} · e^(𝑖#{inspect(polar.imaginary)})>"
  end
  def inspect(ca = %ComplexNum{mode: Cartesian}, _opts) do
    "#ComplexNum (Cartesian)<#{inspect(ca.real)} + #{inspect(ca.imaginary)}·𝑖>"
  end

end
