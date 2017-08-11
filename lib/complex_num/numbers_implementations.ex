# Implementation for the Numbers Protocols
# The only thing ComplexNum cannot do,
# is be converted to a float.

defimpl Numbers.Protocols.Addition, for: ComplexNum do
  defdelegate add(a, b), to: ComplexNum
  def add_id(_num), do: ComplexNum.new(0)
end

defimpl Numbers.Protocols.Subtraction, for: ComplexNum do
  defdelegate sub(a, b), to: ComplexNum
end

defimpl Numbers.Protocols.Multiplication, for: ComplexNum do
  defdelegate mult(a, b), to: ComplexNum
  def mult_id(_num), do: ComplexNum.new(1)
end

defimpl Numbers.Protocols.Division, for: ComplexNum do
  defdelegate div(a, b), to: ComplexNum
end

defimpl Numbers.Protocols.Minus, for: ComplexNum do
  defdelegate minus(num), to: ComplexNum
end

defimpl Numbers.Protocols.Absolute, for: ComplexNum do
  defdelegate abs(num), to: ComplexNum
end

defimpl Numbers.Protocols.Exponentiation, for: ComplexNum do
  defdelegate pow(num, power), to: Numbers.Helper, as: :pow_by_sq
end

require Coerce

Coerce.defcoercion(ComplexNum, Integer) do
  def coerce(complex_num, integer) do
    {complex_num, ComplexNum.new(integer)}
  end
end

Coerce.defcoercion(ComplexNum, Float) do
  def coerce(complex_num, float) do
    {complex_num, ComplexNum.new(float)}
  end
end

# Built-in coercions for well-known Number libraries:

if Code.ensure_loaded?(Ratio) do
  Coerce.defcoercion(ComplexNum, Ratio) do
    def coerce(complex_num, ratio) do
      {complex_num, ComplexNum.new(ratio)}
    end
  end
end

if Code.ensure_loaded?(Decimal) do
  Coerce.defcoercion(ComplexNum, Decimal) do
    def coerce(complex_num, decimal) do
      {complex_num, ComplexNum.new(decimal)}
    end
  end
end

