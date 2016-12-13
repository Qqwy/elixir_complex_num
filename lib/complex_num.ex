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


  @doc """
  Multiplies `ca` by `cb`. This is a precise operation for numbers in both Cartesian and Polar forms.
  """
  def mult(ca, cb)

  @doc """
  Divides `ca` by `cb`. This is a precise operation for numbers in both Cartesian and Polar forms.
  """
  def div(ca, cb)


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
  The absolute value of a Complex Number `ca` has as real part the same magnitude as `ca`,
  but as imaginary part `0`.

  This is a precise operation for numbers in Polar form, but a lossy operation for numbers in Cartesian form.
  """
  def abs(complex)

  @doc  """
  The negation of a Complex Number: Both the real and imaginary parts are negated.

  This is a precise operation for numbers in Cartesian form, but a lossy operation for numbers in Polar form.
  """
  def minus(complex)

  @doc """
  Returns the magnitude of the Complex Number.

  This is a precise operation for numbers in Polar form, but a lossy operation for numbers in Cartesian form.

  If you only need to e.g. sort on magnitudes, consider `magnitude_squared/2` instead, which is also precise for numbers in Cartesian form.
  """
  def magnitude(complex)

  @doc """
  The squared magnitude of the Complex Number.

  This is a precise operation for both Cartesian and Polar form.
  """
  def magnitude_squared(complex)


  @doc """
  Returns the `angle` of the complex number.

  This is a precise operation for numbers in Polar form, but a lossy operation for numbers in Cartesian form.
  """
  def angle(complex)

  unary_operations = [abs: false, minus: true, magnitude: false, angle: false, magnitude_squared: false]
  for {operation, convert_polar_to_cartesian?} <- unary_operations do

    if convert_polar_to_cartesian? do
      def unquote(operation)(ca = %ComplexNum{mode: Polar}) do
        Cartesian.unquote(operation)(Polar.to_cartesian(ca))
      end
    else
      def unquote(operation)(ca = %ComplexNum{mode: Polar}) do
        Polar.unquote(operation)(ca)
      end
    end

    def unquote(operation)(ca = %ComplexNum{mode: Cartesian}) do
      Cartesian.unquote(operation)(ca)
    end

  end

  @doc """
  Power function: computes `base^exponent`,
  where `base` is a Complex Number,
  and `exponent` _has_ to be an integer.

  This means that it is impossible to calculate roots by using this function.

  `pow` is fast (constant time) for numbers in Polar form.
  For numbers in Cartesian form, the Exponentiation by Squaring algorithm is used, which performs `log n` multiplications.
  """
  def pow(base = %ComplexNum{mode: Polar}, exponent) when is_integer(exponent) do
    Polar.pow(base, exponent)
  end

  def pow(base = %ComplexNum{mode: Cartesian}, exponent) when is_integer(exponent) do
      Cartesian.pow(base, exponent)
  end


  @doc """
  Converts a Complex Number to Cartesian Form.

  This is a lossy operation (unless the number already is in Cartesian form).
  """
  def to_cartesian(ca = %ComplexNum{mode: Cartesian}), do: ca
  def to_cartesian(pa = %ComplexNum{mode: Polar}), do: Polar.to_cartesian(pa)

  @doc """
  Converts a Complex Number to Polar Form.

  This is a lossy operation (unless the number already is in Polar form).
  """
  def to_polar(pa = %ComplexNum{mode: Polar}), do: pa
  def to_polar(ca = %ComplexNum{mode: Cartesian}), do: Cartesian.to_polar(ca)

end

defimpl Inspect, for: ComplexNum do
  def inspect(polar = %ComplexNum{mode: ComplexNum.Polar}, _opts) do
    "#ComplexNum (Polar) <#{inspect(polar.real)} · e^(𝑖#{inspect(polar.imaginary)})>"
  end
  def inspect(ca = %ComplexNum{mode: ComplexNum.Cartesian}, _opts) do
    "#ComplexNum (Cartesian) <#{inspect(ca.real)} + #{inspect(ca.imaginary)}·𝑖>"
  end
end
