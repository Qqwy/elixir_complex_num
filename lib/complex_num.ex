defmodule ComplexNum do
  @moduledoc """
  Complex Numbers.

  ## Cartesian vs Polar

  There are two kinds of representaions for Complex Numbers:
  - Cartesian, of the form `a + bi`. (Storing the `real` and `imaginary` parts of the complex number)
  - Polar, of the form `r * e^(i*phi)`. (storing the `magnitude` and the `angle` of the complex number)

  Polar form is very useful to perform fast multiplications, division and integer powers with.
  Also, it obviously allows for O(1) precise computation of the `magnitude` and the `angle`.

  Cartesian form on the other hand, allows besides multiplication and division, precise addition and subtraction.
  Also, it obviously allows for O(1) precise computation of the `real` and `imaginary` parts.

  Conversions between these two representations is possible, but _lossy_:
  This involves trigonometry and square roots, which means that precision is lost.
  (CompexNum converts the internal data types to floats and back to perform these oprations.)

  ## Internal data types

  ComplexNum uses the [Numbers](https://github.com/Qqwy/elixir_number/) library,
  which means that the `real`/`imaginary` (resp. `magnitude`/`angle`) can be of any
  data type that implements Numbers' `Numeric` behaviour. This means that
  Integers, Floats, arbitrary precision decimals defined by the Decimals package,
  rationals defined by the Ratio package, etc. can be used.

  ComplexNum itself also follows the Numeric behaviour, which means that it can be used inside any container that uses Numbers.
  (Including inside ComplexNum itself, but [who would do such a thing?](https://en.wikipedia.org/wiki/Quaternion#Quaternions_as_pairs_of_complex_numbers))
  """


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

    # PolarOrCartesian + AnyNumeric
    def unquote(operation)(ca = %ComplexNum{mode: mode}, b) do
      mode.unquote(operation)(ca, mode.new(b))
    end
    # AnyNumeric + PolarOrCartesian
    def unquote(operation)(a, cb = %ComplexNum{mode: mode}) do
      mode.unquote(operation)(mode.new(a), cb)
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
  def inspect(polar = %ComplexNum{mode: ComplexNum.Polar, real: 1}, _opts) do
    "#ComplexNum (Polar) <e^(𝑖#{inspect(polar.imaginary)})>"
  end
  def inspect(polar = %ComplexNum{mode: ComplexNum.Polar, imaginary: 0}, _opts) do
    "#ComplexNum (Polar) <#{inspect(polar.real)}>"
  end
  def inspect(polar = %ComplexNum{mode: ComplexNum.Polar}, _opts) do
    "#ComplexNum (Polar) <#{inspect(polar.real)} · e^(𝑖#{inspect(polar.imaginary)})>"
  end

  def inspect(ca = %ComplexNum{mode: ComplexNum.Cartesian, imaginary: 0}, _opts) do
    "#ComplexNum (Cartesian) <#{inspect(ca.real)}>"
  end
  def inspect(ca = %ComplexNum{mode: ComplexNum.Cartesian, real: 0}, _opts) do
    "#ComplexNum (Cartesian) <#{inspect(ca.imaginary)}·𝑖>"
  end
  def inspect(ca = %ComplexNum{mode: ComplexNum.Cartesian}, _opts) do
    "#ComplexNum (Cartesian) <#{inspect(ca.real)} + #{inspect(ca.imaginary)}·𝑖>"
  end
end
