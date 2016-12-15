defmodule ComplexNum.Polar do
  # Uses the `real` part of the ComplexNum struct to store the `magnitude`
  # And uses the `imaginary` part of the ComplexNum struct to store the `angle`.

  alias ComplexNum.{Polar}

  alias Numbers, as: N

  @doc """
  Creates a new Complex Numbers in Polar Form
  from the given `magnitude` and `angle`, which can be written as:
  `magnitude * e^{angle * i}`
  """
  def new(magnitude, angle \\ 0)
  def new(magnitude, angle) when is_number(magnitude) and is_number(angle) do
    %ComplexNum{mode: Polar, real: magnitude, imaginary: angle}
  end
  def new(magnitude = %numeric{}, angle = %numeric{}) do
    %ComplexNum{mode: Polar, real: magnitude, imaginary: angle}
  end
  def new(magnitude = %numeric{}, angle) when is_number(angle) do
    %ComplexNum{mode: Polar, real: magnitude, imaginary: numeric.new(angle)}
  end
  def new(magnitude, angle = %numeric{}) when is_number(magnitude) do
    %ComplexNum{mode: Polar, real: numeric.new(magnitude), imaginary: angle}
  end

  @doc """
  Retrieves the magnitude of the Complex Number in Polar form.

  For `r * e^(i * angle)` this is `r`

  This is a precise operation.
  (In stark contrast to computing the magnitude on a Complex Number in Cartesian form!)
  """
  def magnitude(pa = %ComplexNum{mode: Polar}), do: pa.real
  def magnitude(number), do: number

  @doc """
  Computes the square of the magnitude of the Complex number in Polar Form.

  For `r * e^(i * angle)` this is `r²`
  """
  def magnitude_squared(pa = %ComplexNum{mode: Polar}), do: N.mult(pa.real, pa.real)

  @doc """
  Retrieves the angle of the Complex number in Polar form.

  For `r * e^{i * angle}` this is `angle`.

  This is a precise operation.
  (In stark contrast to computing the magnitude on a Complex Number in Cartesian form!)
  """
  def angle(pa = %ComplexNum{mode: Polar}), do: pa.imaginary
  def angle(number), do: number

  @doc """
  Multiplies two Complex Numbers in Polar form.

  This is a precise and very fast operation:
  `(r1 * e^{i * angle1}) * (r2 * e^{i * angle2}) = (r1 * r2) * e^{i * (angle1 + angle2)}`
  """
  def mult(pa = %ComplexNum{mode: Polar}, pb = %ComplexNum{mode: Polar}) do
    new(N.mult(pa.real, pb.real), N.add(pa.imaginary, pb.imaginary))
  end


  @doc """
  Divides a Complex Numbers in Polar form by another.

  This is a precise and very fast operation:
  `(r1 * e^{i * angle1}) / (r2 * e^{i * angle2}) = (r1 / r2) * e^{i * (angle1 - angle2)}`
  """
  def div(pa = %ComplexNum{mode: Polar}, pb = %ComplexNum{mode: Polar}) do
    new(N.div(pa.real, pb.real), N.sub(pa.imaginary, pb.imaginary))
  end

  @doc """
  Integer exponentiation of a number in Polar form.

  This is a precise and very fast operation:
  `(r1 * e^{i * angle1}) ^ (r2 * e^{i * angle2}) = (r1^r2) * e^{i * (angle1 * angle2)}`
  """
  def pow(pa = %ComplexNum{mode: Polar}, exponent) when is_integer(exponent) do
    new(N.pow(pa.real, exponent), N.mult(pa.imaginary, exponent))
  end

  @doc """
  Returns a Complex Number with the same magnitude as this one,
  but with the imaginary part being `0`.
  """
  def abs(pa = %ComplexNum{mode: Polar}) do
    ComplexNum.new(pa.real, 0)
  end

  @doc """
  Converts a Complex Number in Polar form to Cartesian form.

  This is a lossy operation, as `cos` and `sin` have to be used:
  """
  def to_cartesian(pa = %ComplexNum{mode: Polar}) do
    real = N.mult(pa.real, :math.cos(N.to_float(pa.imaginary)))
    imaginary = N.mult(pa.real, :math.sin(N.to_float(pa.imaginary)))
    ComplexNum.new(real, imaginary)
  end
end
