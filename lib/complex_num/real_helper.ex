defmodule ComplexNum.RealHelper do
  @moduledoc """
  Exposes helper functions to perform math on numbers which might be
  custom data types.
  This allows Compex Numbers to be built on any kind of numeric class.

  Math with custom data types is supported, as long as:

  1) One or both of the operands are of the type structModule. The arguments are passed to `structModule` as-is:
     if `structModule` supports addition, subtraction, etc. with one of the numbers being a built-in number (e.g. Integer or Float), then this is also supported by the MathHelper.
  2) This `structModule` module exposes the arity-2 functions `add`, `sub`, `mul`, `div` to do addition, subtraction, multiplication and division, respectively.
  3) This `structModule` exposes the arity-1 function `minus` to negate a number and `abs` to change a number to its absolute value.


  Note that `div` is supposed to be precise division (i.e. no rounding should be performed).
  """

  # Attempt to add two real numbers together.
  # Does not make assumptions on the types of A and B.
  # As long as they are the same kind of struct, will call structModule.add(a, b).
  # Will use Kernel.+(a, b) for built-in numeric types.
  # defp real_add(a, b)

  # defp real_add(a, b) when is_number(a) and is_number(b) do
  #   Kernel.+(a, b)
  # end

  # defp real_add(a = %numericType{}, b = %numericType{}) do
  #   numericType.add(a, b)
  # end

  # defp real_add(a = %numericType{}, b) when is_number(b) do
  #   numericType.add(a, b)
  # end


  # defp real_add(a, b = %numericType{}) when is_number(a) do
  #   numericType.add(a, b)
  # end

  binary_operations = [add: &+/2, sub: &-/2, mul: &*/2, div: &//2]

  for {name, kernelFun} <- binary_operations do
    # num + num
    def unquote(name)(a, b) when is_number(a) and is_number(b) do
      unquote(kernelFun).(a, b)
    end

    # struct + num
    def unquote(name)(a = %numericType{}, b) when is_number(b) do
      numericType.unquote(name)(a, b)
    end

    #num + struct
    def unquote(name)(a, b = %numericType{}) when is_number(a) do
      numericType.unquote(name)(a, b)
    end

    # struct + struct
    def unquote(name)(a = %numericyType{}, b = %numericType{}) do
      numericType.unquote(name)(a, b)
    end

  end

  def minus(num = %numericType{}), do: numericType.minus(num)
  def minus(num) when is_number(num), do: Kernel.-(num)

  def abs(num = %numericType{}), do: numericType.abs(num)
  def abs(num) when is_number(num), do: Kernel.abs(num)

end
