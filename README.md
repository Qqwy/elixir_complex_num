# ComplexNum


[![hex.pm version](https://img.shields.io/hexpm/v/complex_num.svg)](https://hex.pm/packages/complex_num)


ComplexNum allows you to work with [Complex Numbers](https://en.wikipedia.org/wiki/Complex_number) in Elixir. 

## Cartesian vs. Polar


There are two kinds of representaions for Complex Numbers:
- Cartesian, of the form `a + bi`. (Storing the `real` and `imaginary` parts of the complex number)
- Polar, of the form `r * e^(i*phi)`. (storing the `magnitude` and the `angle` of the complex number)

Polar form is very useful to perform fast multiplications, division and integer powers with.
Also, it obviously allows for O(1) precise computation of the `magnitude` and the `angle`.

Cartesian form on the other hand, allows besides multiplication and division, precise addition and subtraction.
Also, it obviously allows for O(1) precise computation of the `real` and `imaginary` parts.

Conversions between these two representations is possible, but _lossy_:
This involves trigonometry and square roots, which means that precision is lost.
(CompexNum converts the internal data types to floats and back to perform these oprations.)

## Internal data types

ComplexNum uses the [Numbers](https://github.com/Qqwy/elixir_number/) library,
which means that the `real`/`imaginary` (resp. `magnitude`/`angle`) can be of any
data type that implements Numbers' `Numeric` behaviour. This means that
Integers, Floats, arbitrary precision decimals defined by the Decimals package,
rationals defined by the Ratio package, etc. can be used.

ComplexNum itself also follows the Numeric behaviour, which means that it can be used inside any container that uses Numbers.
(Including inside ComplexNum itself, but [who would do such a thing?](https://en.wikipedia.org/wiki/Quaternion#Quaternions_as_pairs_of_complex_numbers))


## Installation

The package can be installed as:

  1. Add `complex_num` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:complex_num, "~> 1.0.0"}]
    end
    ```

  2. Ensure `complex_num` is started before your application:

    ```elixir
    def application do
      [applications: [:complex_num]]
    end
    ```

## Changelog

- 1.1.0 Support for Numbers v5.0.0.
- 1.0.0 Stable release.
