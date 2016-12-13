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

  @doc """
  Adds two `ComplexNum`s together.
  If both are Cartesian, this is a precise operation.

  If one or both are Polar, this is a lossy operation, as they are first converted to Cartesian.
  """
  def add(ca, cb)

  @doc """
  Subtracts one `ComplexNum` from another.
  If both are Cartesian, this is a precise operation.

  If one or both are Polar, this is a lossy operation, as they are first converted to Cartesian.
  """
  def sub(ca, cb)

  operations_that_convert_polar_to_cartesian = [add: true, sub: true, mult: false, div: false]
  for {operation, even_if_both_are_polar?} <- operations_that_convert_polar_to_cartesian do

    # Polar + Polar
    if even_if_both_are_polar? do
      def unquote(operation)(ca = %ComplexNum{mode: Polar}, cb = %ComplexNum{mode: Polar}) do
        Cartesian.unquote(operation)(Polar.to_cartesian(ca), Polar.to_cartesian(cb))
      end
    else
      def unquote(operation)(ca = %ComplexNum{mode: Polar}, cb = %ComplexNum{mode: Polar}) do
        Polar.unquote(operation)(ca, cb)
      end
    end

    # Polar + Cartesian
    def unquote(operation)(ca = %ComplexNum{mode: Polar}, cb = %ComplexNum{mode: Cartesian}) do
      Cartesian.unquote(operation)(Polar.to_cartesian(ca), cb)
    end
    # Cartesian + Polar
    def unquote(operation)(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Polar}) do
      Cartesian.unquote(operation)(ca, Polar.to_cartesian(cb))
    end
    # Cartesian + Cartesian
    def unquote(operation)(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do
      Cartesian.unquote(operation)(ca, cb)
    end
  end

  @doc """
  Power function: computes `base^exponent`,
  where `base` is Numeric,
  and `exponent` _has_ to be an integer.

  This means that it is impossible to calculate roots by using this function.


  `pow` is fast for numbers in Polar form.
  For numbers in Cartesian form, the Exponentiation by Squaring algorithm is used.
  """
  def pow(base = %ComplexNum{mode: Polar}, exponent) when is_integer(exponent) do
    Polar.pow(base, exponent)
  end

  def pow(base = %ComplexNum{mode: Cartesian}, exponent) when is_integer(exponent) do
      Cartesian.pow(base, exponent)
  end

  

end

defimpl Inspect, for: ComplexNum do
  def inspect(polar = %ComplexNum{mode: ComplexNum.Polar}, _opts) do
    "#ComplexNum (Polar) <#{inspect(polar.real)} · e^(𝑖#{inspect(polar.imaginary)})>"
  end
  def inspect(ca = %ComplexNum{mode: ComplexNum.Cartesian}, _opts) do
    "#ComplexNum (Cartesian) <#{inspect(ca.real)} + #{inspect(ca.imaginary)}·𝑖>"
  end
end
