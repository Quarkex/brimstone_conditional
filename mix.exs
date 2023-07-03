defmodule BrimstoneConditional.MixProject do
  use Mix.Project

  @scm_url "https://github.com/Quarkex/brimstone_conditional"

  def project do
    [
      app: :brimstone_conditional,
      description: "Logic holding structs",
      version: "0.1.3",
      elixir: ">= 1.14.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @scm_url,
      docs: docs()
    ]
  end

  defp docs do
    [
      main: "BrimstoneConditional"
    ]
  end

  defp package do
    [
      maintainers: ["Manlio García"],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url},
      files: ~w(lib LICENSE.md mix.exs README.md CHANGELOG.md .formatter.exs)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:ecto_sql, "~> 3.6"}
    ]
  end
end
