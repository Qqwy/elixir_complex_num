defmodule ComplexNum.Polar do
  defstruct [:modulus, :angle]

  alias Numbers, as: N

  def new(modulus, angle \\ 0)
  def new(modulus, angle) when is_number(modulus) and is_number(angle) do
    %__MODULE__{modulus: modulus, angle: angle}
  end
  def new(modulus = %numeric{}, angle = %numeric{}) do
    %__MODULE__{modulus: modulus, angle: angle}
  end
  def new(modulus = %numeric{}, angle) when is_number(angle) do
    %__MODULE__{modulus: modulus, angle: numeric.new(angle)}
  end
  def new(modulus, angle = %numeric{}) when is_number(modulus) do
    %__MODULE__{modulus: numeric.new(modulus), angle: angle}
  end


  def modulus_part(pa = %__MODULE__{}), do: pa.modulus
  def modulus_part(number), do: number

  def angle_part(pa = %__MODULE__{}), do: pa.angle
  def angle_part(number), do: number

  def mult(pa = %__MODULE__{}, pb = %__MODULE__{}) do
    new(N.mult(pa.modulus, pb.modulus), N.add(pa.angle, pb.angle))
  end

  def div(pa = %__MODULE__{}, pb = %__MODULE__{}) do
    new(N.div(pa.modulus, pb.modulus), N.sub(pa.angle, pb.angle))
  end

  def pow(pa = %__MODULE__{}, exponent) when is_integer(exponent) do
    new(N.pow(pa.modulus, exponent), N.mult(pa.angle, exponent))
  end
end
