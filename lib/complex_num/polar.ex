defmodule ComplexNum.Polar do
  # Uses the `real` part of the ComplexNum struct to store the `magnitude`
  # And uses the `imaginary` part of the ComplexNum struct to store the `angle`.

  alias Numbers, as: N

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

  def magnitude_part(pa = %ComplexNum{mode: Polar}), do: pa.real
  def magnitude_part(number), do: number

  def angle_part(pa = %ComplexNum{mode: Polar}), do: pa.imaginary
  def angle_part(number), do: number

  def mult(pa = %ComplexNum{mode: Polar}, pb = %ComplexNum{mode: Polar}) do
    new(N.mult(pa.real, pb.real), N.add(pa.imaginary, pb.imaginary))
  end

  def div(pa = %ComplexNum{mode: Polar}, pb = %ComplexNum{mode: Polar}) do
    new(N.div(pa.real, pb.real), N.sub(pa.imaginary, pb.imaginary))
  end

  def pow(pa = %ComplexNum{mode: Polar}, exponent) when is_integer(exponent) do
    new(N.pow(pa.real, exponent), N.mult(pa.imaginary, exponent))
  end

  def to_cartesian(pa = %ComplexNum{mode: Polar}) do
    real = N.mult(pa.real, :math.cos(N.to_float(pa.imaginary)))
    imaginary = N.mult(pa.real, :math.sin(N.to_float(pa.imaginary)))
    ComplexNum.new(real, imaginary)
  end
end

# defimpl Inspect, for: ComplexNum.Polar do
#   def inspect(ca = %ComplexNum.Polar{}, _opts) do
#     "#ComplexNum.Cartesian<#{inspect(ca.magnitude)} · e^(𝑖#{inspect(ca.angle)})>"
#   end
# end
