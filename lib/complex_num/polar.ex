defmodule ComplexNum.Polar do
  defstruct [:magnitude, :angle]

  alias Numbers, as: N

  def new(magnitude, angle \\ 0)
  def new(magnitude, angle) when is_number(magnitude) and is_number(angle) do
    %__MODULE__{magnitude: magnitude, angle: angle}
  end
  def new(magnitude = %numeric{}, angle = %numeric{}) do
    %__MODULE__{magnitude: magnitude, angle: angle}
  end
  def new(magnitude = %numeric{}, angle) when is_number(angle) do
    %__MODULE__{magnitude: magnitude, angle: numeric.new(angle)}
  end
  def new(magnitude, angle = %numeric{}) when is_number(magnitude) do
    %__MODULE__{magnitude: numeric.new(magnitude), angle: angle}
  end


  def magnitude_part(pa = %__MODULE__{}), do: pa.magnitude
  def magnitude_part(number), do: number

  def angle_part(pa = %__MODULE__{}), do: pa.angle
  def angle_part(number), do: number

  def mult(pa = %__MODULE__{}, pb = %__MODULE__{}) do
    new(N.mult(pa.magnitude, pb.magnitude), N.add(pa.angle, pb.angle))
  end

  def div(pa = %__MODULE__{}, pb = %__MODULE__{}) do
    new(N.div(pa.magnitude, pb.magnitude), N.sub(pa.angle, pb.angle))
  end

  def pow(pa = %__MODULE__{}, exponent) when is_integer(exponent) do
    new(N.pow(pa.magnitude, exponent), N.mult(pa.angle, exponent))
  end

  def to_cartesian(pa = %__MODULE__{}) do
    real = N.mult(pa.magnitude, :math.cos(N.to_float(pa.angle)))
    imaginary = N.mult(pa.magnitude, :math.sin(N.to_float(pa.angle)))
    ComplexNum.Cartesian.new(real, imaginary)
  end
end

defimpl Inspect, for: ComplexNum.Polar do
  def inspect(ca = %ComplexNum.Polar{}, _opts) do
    "#ComplexNum.Cartesian<#{inspect(ca.magnitude)} · e^(𝑖#{inspect(ca.angle)})>"
  end
end
