defmodule ComplexNum.Cartesian do
  import Kernel, except: [div: 2]

  @moduledoc """
  A simple Complex Number in the form of `a + b*i`.

  `a` and `b` are allowed to be any type that implements the `Numeric` behaviour.
  This means Integer and Float, as well as custom-built data types like Decimal, Ratio, ???.

  Do note that certain kinds of operations (especially the conversion of Cartesian <-> Polar) require the calculation of square roots.
  Computers are not able to calculate any square root with infinite precision in finite time.
  This is exactly the reason that e.g. Decimal and Ratio do _not_ support `sqrt`.
  Therefore, the only way to manage this, is to _explicitly_ convert a (high- or infinite-precision) data type that does not support square roots
  to a data type that _does_ support it (like Floats), in which case precision will be lost.


  """

  defstruct [:real, :imaginary]

  alias Numbers, as: N
  # ComplexNum.Cartesian itself follows the rules in Numeric,
  # and therefore it is also possible to nest them (and built Quaternions that way?!)
  @behaviour Numeric

  @doc """
  Creates a new Cartesian Complex Number.

  `real` and `imaginary` can be Integer, Float or any custom struct that implements the Numeric behaviour. (defined by The [Numbers](https://hex.pm/packages/numbers) package)
  If a custom Numeric type is used, the other argument is converted to that type automatically.
  """
  def new(real, imaginary \\ 0)
  def new(real, imaginary) when is_number(real) and is_number(imaginary) do
    %__MODULE__{real: real, imaginary: imaginary}
  end
  def new(real = %numeric{}, imaginary = %numeric{}) do
    %__MODULE__{real: real, imaginary: imaginary}
  end
  def new(real = %numeric{}, imaginary) when is_number(imaginary) do
    %__MODULE__{real: real, imaginary: numeric.new(imaginary)}
  end
  def new(real, imaginary = %numeric{}) when is_number(real) do
    %__MODULE__{real: numeric.new(real), imaginary: imaginary}
  end



  def imaginary(num), do: new(0, num)

  def real_part(ca = %__MODULE__{}), do: ca.real
  def real_part(a), do: a

  def imaginary_part(ca = %__MODULE__{}), do: ca.imaginary
  def imaginary_part(_a), do: 0

  def add(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    new(N.add(ca.real, cb.real), N.add(ca.imaginary, cb.imaginary))
  end
  def add(a, cb = %__MODULE__{}), do: add(new(a), cb)
  def add(ca = %__MODULE__{}, b), do: add(ca, new(b))



  def sub(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    new(N.sub(ca.real, cb.real), N.sub(ca.imaginary, cb.imaginary))
  end
  def sub(a, cb = %__MODULE__{}), do: sub(new(a), cb)
  def sub(ca = %__MODULE__{}, b), do: sub(ca, new(b))

  def mult(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi) * (c + di)

    # (a * c) - (b * d)
    real = N.sub(N.mult(ca.real, cb.real), N.mult(ca.imaginary, cb.imaginary))

    # (a * d + c * b)
    imaginary = N.add(N.mult(ca.real, cb.imaginary), N.mult(ca.imaginary, cb.real))

    new(real, imaginary)
  end
  def mult(a, cb = %__MODULE__{}), do: mult(new(a), cb)
  def mult(ca = %__MODULE__{}, b), do: mult(ca, new(b))

  def conjugate(ca = %__MODULE__{}) do
    new(ca.real, N.minus(ca.imaginary))
  end
  def conjugate(a), do: new(a) # as -0 === 0


  def div(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi)/(c + di)

    # denom = c^2 + d^2
    denom = N.add(N.mult(cb.real, cb.real), N.mult(cb.imaginary, cb.imaginary))

    # (ac + bd)/denom
    real = N.div(N.add(N.mult(ca.real, cb.real), N.mult(ca.imaginary, cb.imaginary)), denom)

    # (bc - ad)/denom
    imaginary = N.div(N.sub(N.mult(ca.imaginary, cb.real), N.mult(ca.real, cb.imaginary)), denom)

    new(real, imaginary)
  end
  def div(a, cb = %__MODULE__{}), do: div(new(a), cb)
  def div(ca = %__MODULE__{}, b), do: div(ca, new(b))

  @doc "1 / ca"
  def reciprocal(ca = %__MODULE__{}) do
      denom = N.add(N.mult(ca.real, ca.real), N.mult(ca.imaginary, ca.imaginary))
      real = N.div(ca.real, denom)
      imaginary = N.div(N.minus(ca.imaginary), denom)
      new(real, imaginary)
  end

  @doc """
  Calculates the magnitude of the Cartesian Complex Number.
  As this is done using Pythagoras, i.e. c = sqrt(a*a + b*b), this is a lossy operation where (a*a+b*b) is converted to a float.
  """
  def magnitude(ca = %__MODULE__{}) do
    :math.sqrt(N.to_float(magnitude_squared(ca)))
  end

  @doc """
  Returns the square of the magnitude of the Cartesian Complex Number.
  Because it is not necessary to calculate a square root, this is a precise operation.
  """
  def magnitude_squared(ca = %__MODULE__{}) do
    N.add(N.mult(ca.real, ca.real),N.mult(ca.imaginary, ca.imaginary))
  end

  @doc """
  The absolute value of a Cartesian Complex Number is a real part containing the magnitude of the number,
  and an imaginary part of 0.

  This is a lossy operation, as calculating the magnitude of a Cartesian Complex number is a lossy operation.
  """
  def abs(ca = %__MODULE__{}) do
    new(magnitude(ca), 0)
  end

  def minus(ca = %__MODULE__{}) do
    new(N.minus(ca.real), N.minus(ca.imaginary))
  end


  def to_polar(ca = %__MODULE__{}) do
    angle = :math.atan2(N.to_float(ca.imaginary), N.to_float(ca.real))
    ComplexNum.Polar.new(magnitude(ca), angle)
  end
end
