defmodule ComplexNum.Cartesian do
  import Kernel, except: [div: 2]
  alias ComplexNum.{Cartesian}

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

  @doc """
  Creates a new Cartesian Complex Number.

  `real` and `imaginary` can be Integer, Float or any custom struct that implements the Numeric behaviour. (defined by The [Numbers](https://hex.pm/packages/numbers) package)
  If a custom Numeric type is used, the other argument is converted to that type automatically.
  """
  def new(real, imaginary \\ 0)
  def new(real, imaginary) when is_number(real) and is_number(imaginary) do
    %ComplexNum{mode: Cartesian, real: real, imaginary: imaginary}
  end
  def new(real = %numeric{}, imaginary = %numeric{}) do
    %ComplexNum{mode: Cartesian, real: real, imaginary: imaginary}
  end
  def new(real = %numeric{}, imaginary) when is_number(imaginary) do
    %ComplexNum{mode: Cartesian, real: real, imaginary: numeric.new(imaginary)}
  end
  def new(real, imaginary = %numeric{}) when is_number(real) do
    %ComplexNum{mode: Cartesian, real: numeric.new(real), imaginary: imaginary}
  end

  @doc """
  Extracts the 'real' part from a Complex number.

  For a number in the Cartesian form `a + bi`, this is `a`.
  """
  def real(ca = %ComplexNum{mode: Cartesian}), do: ca.real
  def real(a), do: a

  @doc """
  Extracts the 'imaginary' part from a Complex number.

  For a number in the Cartesian form `a + bi`, this is `b`.
  """
  def imaginary(ca = %ComplexNum{mode: Cartesian}), do: ca.imaginary
  def imaginary(_a), do: 0

  @doc """
  Adds two Complex Numbers in Cartesian form together.

  This is a precise operation.
  Note that this function expects both arguments to be Complex numbers in Cartesian form.
  (optionally, one of the arguments might be an Integer or Float).

  If you want to be able to add Complex numbers in Cartesian form and Polar form together,
  use `ComplexNum.add/2` instead.
  """
  def add(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do
    new(N.add(ca.real, cb.real), N.add(ca.imaginary, cb.imaginary))
  end
  def add(a, cb = %ComplexNum{mode: Cartesian}), do: add(new(a), cb)
  def add(ca = %ComplexNum{mode: Cartesian}, b), do: add(ca, new(b))


  @doc """
  Adds one Complex Numbers in Cartesian form from another.

  This is a precise operation.
  Note that this function expects both arguments to be Complex numbers in Cartesian form.
  (optionally, one of the arguments might be an Integer or Float).

  If you want to be able to subtract Complex numbers in Cartesian form and Polar form together,
  use `ComplexNum.sub/2` instead.
  """
  def sub(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do
    new(N.sub(ca.real, cb.real), N.sub(ca.imaginary, cb.imaginary))
  end
  def sub(a, cb = %ComplexNum{mode: Cartesian}), do: sub(new(a), cb)
  def sub(ca = %ComplexNum{mode: Cartesian}, b), do: sub(ca, new(b))

  @doc """
  Multiplies two Complex Numbers in Cartesian form.

  This is a precise operation (but slower than multiplication of numbers in Polar form).
  Note that this function expects both arguments to be Complex numbers in Cartesian form.
  (optionally, one of the arguments might be an Integer or Float).

  If you want to be able to multiply Complex numbers in Cartesian form and Polar form together,
  use `ComplexNum.mult/2` instead.
  """
  # (a + bi) * (a - bi) == a² + b²
  def mult(
    ca            = %ComplexNum{mode: Cartesian, real: real, imaginary:  imaginary},
    _ca_conjugate = %ComplexNum{mode: Cartesian, real: real, imaginary: neg_imaginary}) when -imaginary == neg_imaginary do
    magnitude_squared(ca)
  end

  # (a + bi) * (c + di)
  def mult(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do

    # (a * c) - (b * d)
    real = N.sub(N.mult(ca.real, cb.real), N.mult(ca.imaginary, cb.imaginary))

    # (a * d + b * c)
    imaginary = N.add(N.mult(ca.real, cb.imaginary), N.mult(ca.imaginary, cb.real))

    new(real, imaginary)
  end
  def mult(a, cb = %ComplexNum{mode: Cartesian}), do: mult(new(a), cb)
  def mult(ca = %ComplexNum{mode: Cartesian}, b), do: mult(ca, new(b))

  @doc """
  Returns the *Complex Conjugate* of a Complex number in Cartesian form.

  For `a + bi`, this is `a - bi`.

  This is a precise operation.
  """
  def conjugate(ca = %ComplexNum{mode: Cartesian}) do
    new(ca.real, N.minus(ca.imaginary))
  end
  def conjugate(a), do: new(a) # as -0 === 0

  @doc """
  Divides a Complex Number in Cartesian form by another.

  This is a precise operation (but slower than division of numbers in Polar form).
  Note that this function expects both arguments to be Complex numbers in Cartesian form.
  (optionally, one of the arguments might be an Integer or Float).

  If you want to be able to multiply Complex numbers in Cartesian form and Polar form together,
  use `ComplexNum.div/2` instead.
  """
  # 1 / (a + bi)
  def div(%ComplexNum{mode: Cartesian, real: 1, imaginary: 0}, cb = %ComplexNum{mode: Cartesian}), do: reciprocal(cb)
  def div(ca = %ComplexNum{mode: Cartesian}, cb = %ComplexNum{mode: Cartesian}) do
    # (a + bi)/(c + di)

    # denom = c^2 + d^2
    denom = N.add(N.mult(cb.real, cb.real), N.mult(cb.imaginary, cb.imaginary))

    # (ac + bd)/denom
    real = N.div(N.add(N.mult(ca.real, cb.real), N.mult(ca.imaginary, cb.imaginary)), denom)

    # (bc - ad)/denom
    imaginary = N.div(N.sub(N.mult(ca.imaginary, cb.real), N.mult(ca.real, cb.imaginary)), denom)

    new(real, imaginary)
  end

  # 1 / (a + bi)
  def div(1, cb = %ComplexNum{mode: Cartesian}), do: reciprocal(cb)
  def div(a, cb = %ComplexNum{mode: Cartesian}), do: div(new(a), cb)
  def div(ca = %ComplexNum{mode: Cartesian}, b), do: div(ca, new(b))

  @doc """
  The reciprocal of a Complex number (a + bi) is identical to 1 / (a + bi).
  """
  def reciprocal(ca = %ComplexNum{mode: Cartesian}) do
      denom = N.add(N.mult(ca.real, ca.real), N.mult(ca.imaginary, ca.imaginary))
      real = N.div(ca.real, denom)
      imaginary = N.div(N.minus(ca.imaginary), denom)
      new(real, imaginary)
  end

  @doc """
  Calculates the magnitude of the Cartesian Complex Number.
  As this is done using Pythagoras, i.e. c = sqrt(a² + b²),
  this is a lossy operation where (a²+b²) is converted to a float,
  so the square root can be calculated.
  """
  # |a + bi| = sqrt(a² + b²)
  def magnitude(ca = %ComplexNum{mode: Cartesian, real: 0}), do: ca.imaginary
  def magnitude(ca = %ComplexNum{mode: Cartesian, imaginary: 0}), do: ca.real
  def magnitude(ca = %ComplexNum{mode: Cartesian}) do
    :math.sqrt(N.to_float(magnitude_squared(ca)))
  end

  @doc """
  Returns the square of the magnitude of the Cartesian Complex Number.
  Because it is not necessary to calculate a square root, this is a precise operation.
  """
  # |a + bi|² = a² + b²
  def magnitude_squared(ca = %ComplexNum{mode: Cartesian}) do
    N.add(N.mult(ca.real, ca.real),N.mult(ca.imaginary, ca.imaginary))
  end

  @doc """
  The absolute value of a Cartesian Complex Number is a real part containing the magnitude of the number,
  and an imaginary part of 0.

  This is a lossy operation, as calculating the magnitude (see `magnitude/1` ) of a Cartesian Complex number is a lossy operation.
  """
  def abs(ca = %ComplexNum{mode: Cartesian}) do
    new(magnitude(ca), 0)
  end

  @doc """
  Negates the complex number.

  This means that both the real and the imaginary part are negated.
  """
  def minus(ca = %ComplexNum{mode: Cartesian}) do
    new(N.minus(ca.real), N.minus(ca.imaginary))
  end

  @doc """
  Integer power function.

  The result is calculated using the Exponentiation by Squaring algorithm,
  which means that it performs log(n) multiplications to calculate (a + bi)^n.

  Note that only integers are accepted as exponent, so you cannot calculate roots
  using this function.
  """
  def pow(base = %ComplexNum{mode: Cartesian}, exponent) when is_integer(exponent) do
    pow_by_sq(base, exponent)
  end

  # Small powers
  defp pow_by_sq(x, 1), do: x
  defp pow_by_sq(x, 2), do: mult(x, x)
  defp pow_by_sq(x, 3), do: mult(mult(x, x), x)
  defp pow_by_sq(x, n) when is_integer(n), do: do_pow_by_sq(x, n)

  # Exponentiation By Squaring.
  defp do_pow_by_sq(x, n, y \\ 1)
  defp do_pow_by_sq(_x, 0, y), do: y
  defp do_pow_by_sq(x, 1, y), do: mult(x, y)
  defp do_pow_by_sq(x, n, y) when n < 0, do: do_pow_by_sq(div(1, x), Kernel.-(n), y)
  defp do_pow_by_sq(x, n, y) when rem(n, 2) == 0, do: do_pow_by_sq(mult(x, x), Kernel.div(n, 2), y)
  defp do_pow_by_sq(x, n, y), do: do_pow_by_sq(mult(x, x), Kernel.div((n - 1), 2), mult(x, y))

  @doc """
  Returns the angle (counter-clockwise in relation to the 'Real' axis of the Argand plane)
  of a Complex number in cartesian form.

  Note that this is a lossy operation, as the trigonometric function `atan2(b, a)` is used,
  which is only available for built-in Floats.

  Note that when called with `0 + 0i` there are infinitely many solutions,
  and thus the result is formally _undefined_.
  By keeping with the convention most practical implementations follow however,
  instead of creating an exceptional situation,
  the solution `angle(0 + 0i) = 0` is returned.
  """
  def angle(ca = %ComplexNum{mode: Cartesian}) do
    :math.atan2(N.to_float(ca.imaginary), N.to_float(ca.real))
  end

  @doc """
  Converts a Complex Number in Cartesian form
  to a Complex Number in Polar form.

  This is a lossy operation, as both `magnitude/1` and `angle/1` need to be called,
  which are both lossy operations (requiring the use of a square root and atan2, respectively).
  """
  def to_polar(ca = %ComplexNum{mode: Cartesian, real: %numericType{}}) do
    float_conversion = do_to_polar(ca)

    converted_magnitude = numericType.new(float_conversion.real)
    converted_angle = numericType.new(float_conversion.imaginary)
    ComplexNum.Polar.new(converted_magnitude, converted_angle)
  end
  def to_polar(ca = %ComplexNum{mode: Cartesian, imaginary: %numericType{}}) do
    float_conversion = do_to_polar(ca)

    converted_magnitude = numericType.new(float_conversion.real)
    converted_angle = numericType.new(float_conversion.imaginary)
    ComplexNum.Polar.new(converted_magnitude, converted_angle)
  end
  def to_polar(ca = %ComplexNum{mode: Cartesian}), do: do_to_polar(ca)
  defp do_to_polar(ca = %ComplexNum{mode: Cartesian}) do
    ComplexNum.Polar.new(magnitude(ca), angle(ca))
  end
end
