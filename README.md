# ComplexNum

ComplexNum allows you to work with Complex Numbers. ComplexNum uses `Numbers` to perform the calculations on its real and imaginary parts, which means
that _any_ datatype that implements Numbers' `Numeric` Behaviour can be used as real/imaginary part.

Furthermore, the two data types of ComplexNum _itself_ (Cartesian and Polar) implement the `Numeric` behaviour, which means that you can use it as any other numeric type as well!
(If you want to, you could even nest Complex Numbers?!)

## Cartesian vs. Polar

Both Cartesian Form (`a + bi`) and Polar Form (`r * e^(i*phi)`) are supported. Both forms have different funcionality that is offered at _arbitrary precision_:

### Cartesian Form
- Addition, Subtraction, Multiplication and Division have arbitrary precision (it is as precise as arithmetic with the numeric data type used for the real/imaginary parts allows).
- Determining the real or imaginary parts has full precision (as these are the things stored internally).
- Determining the magnitude or angle are lossy operations (as this requires conversion to floats, so `sqrt` or `atan2` can be used.)

### Polar Form
- Multiplication, Division and Power have arbitrary precision (and are fast). (it is as precise as arithmetic with the numeric data type used for the real/imaginary parts allows)
- Addition and Subtraction are lossy operations, (as this requires conversion to floats, so  `cos` and `sin` can be used).
- Determining the magnitude or angle has full precision (as these are the things stored internally).
- Determining the real or imaginary parts are lossy operations (as this requires conversion to floats, so `cos` and `sin` can be used.)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `complex_num` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:complex_num, "~> 0.2.0"}]
    end
    ```

  2. Ensure `complex_num` is started before your application:

    ```elixir
    def application do
      [applications: [:complex_num]]
    end
    ```

