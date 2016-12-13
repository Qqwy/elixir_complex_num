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

  alias Number, as: N
  # ComplexNum.Cartesian itself follows the rules in Numeric,
  # and therefore it is also possible to nest them (and built Quaternions that way?!)
  @behaviour Numeric


  def new(real, imaginary \\ 0) do
    %__MODULE__{real: real, imaginary: imaginary}
  end

  def imaginary(num), do: new(0, num)

  def real_part(ca = %__MODULE__{}), do: ca.real
  def real_part(a), do: a

  def imaginary_part(ca = %__MODULE__{}), do: ca.imaginary
  def imaginary_part(a), do: 0

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

  def mul(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi) * (c + di)

    # (a * c) - (b * d)
    real = N.sub(N.mul(ca.real, cb.real), N.mul(ca.imaginary, cb.imaginary))

    # (a * d + c * b)
    imaginary = N.add(N.mul(ca.real, cb.imaginary), N.mul(ca.imaginary, cb.real))

    new(real, imaginary)
  end
  def mul(a, cb = %__MODULE__{}), do: mul(new(a), cb)
  def mul(ca = %__MODULE__{}, b), do: mul(ca, new(b))

  def conjugate(ca = %__MODULE__{}) do
    new(ca.real, N.minus(ca.imaginary))
  end
  def conjugate(a), do: new(a) # as -0 === 0

  def minus(a), do: conjugate(a) # Follow the Complex number rules.

  def div(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi)/(c + di)

    # denom = c^2 + d^2
    denom = N.add(N.mul(cb.real, cb.real), N.mul(cb.imaginary, cb.imaginary))

    # (ac + bd)/denom
    real = N.div(N.add(N.mul(ca.real, cb.real), N.mul(ca.imaginary, cb.imaginary)), denom)

    # (bc - ad)/denom
    imaginary = N.div(N.sub(N.mul(ca.imaginary, cb.real), N.mul(ca.real, cb.imaginary)), denom)

    new(real, imaginary)
  end
  def div(a, cb = %__MODULE__{}), do: div(new(a), cb)
  def div(ca = %__MODULE__{}, b), do: div(ca, new(b))

  @doc "1 / ca"
  def reciprocal(ca = %__MODULE__{}) do
      denom = N.add(N.mul(ca.real, ca.real), N.mul(ca.imaginary, ca.imaginary))
      real = N.div(ca.real, denom)
      imaginary = N.div(N.minus(ca.imaginary), denom)
      new(real, imaginary)
  end

end
