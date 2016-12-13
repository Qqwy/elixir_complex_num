defmodule ComplexNum.Cartesian do
  defstruct [:real, :imaginary]

  alias ComplexNum.RealHelper, as: R


  def new(real, imaginary) do
    %__MODULE__{real: real, imaginary: imaginary}
  end

  def add(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    new(R.add(ca.real, cb.real), R.add(ca.imaginary, cb.imaginary))
  end

  
  def sub(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    new(R.sub(ca.real, cb.real), R.sub(ca.imaginary, cb.imaginary))
  end
  
  def mul(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi) * (c + di)

    # (a * c) - (b * d)
    real = R.sub(R.mul(ca.real, cb.real), R.mul(ca.imaginary, cb.imaginary))

    # (a * d + c * b)
    imaginary = R.add(R.mul(ca.real, cb.imaginary), R.mul(ca.imaginary, cb.real))

    new(real, imaginary)
  end

  def conjugate(ca = %__MODULE__{}) do
    new(ca.real, R.minus(ca.imaginary))
  end

  def div(ca = %__MODULE__{}, cb = %__MODULE__{}) do
    # (a + bi)/(c + di)

    # denom = c^2 + d^2
    denom = R.plus(R.mul(cb.real, cb.real), R.mul(cb.imaginary, cb.imaginary))

    # (ac + bd)/denom
    real = R.div(R.plus(R.mul(ca.real, cb.real), R.mul(ca.imaginary, cb.imaginary)), denom)

    # (bc - ad)/denom
    imaginary = R.div(R.sub(R.mul(ca.imaginary, cb.real), R.mul(ca.real, cb.imaginary)), denom)

    new(real, imaginary)
  end

  @doc "1 / ca"
  def reciprocal(ca = %__MODULE__{}) do
      denom = R.plus(R.mul(ca.real, ca.real), R.mul(ca.imaginary, ca.imaginary))
      real = R.div(ca.real, denom)
      imaginary = R.div(R.minus(ca.imaginary), denom)
      new(real, imaginary)
  end

end
