defmodule ComplexNum.Mixfile do
  use Mix.Project

  def project do
    [app: :complex_num,
     version: "1.0.3",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications:
      [
        :logger,
        :numbers
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:earmark, ">= 0.0.0", only: [:dev]}, # Markdown, dependency of ex_doc
      {:ex_doc, "~> 0.14", only: [:dev]},    # Documentation for Hex.pm
      {:numbers, "~> 2.0"},
      {:decimal, "~> 1.3", only: [:dev, :test]},
      {:ratio, "~> 1.2", only: [:dev, :test]},

    ]
  end

  defp description do
    """
    ComplexNum allows you to do math with Complex Numbers. Both Cartesian and Polar form are supported.
    """
  end

  defp package do
    [# These are the default files included in the package
      name: :complex_num,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Wiebe-Marten Wijnja/Qqwy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Qqwy/elixir_complex_num/"}
    ]
  end
end
