defmodule Discordian.MixProject do
  use Mix.Project

  def project do
    [
      app: :discordian,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "discordian",
      source_url: "https://github.com/carlosfrodrigues/discordian-calendar"
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
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    An implementation of the Discordian Calendar built using the calendar behaviour
    """
  end
  
  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: :discordian,
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/carlosfrodrigues/discordian-calendar"}
    ]
  end
end
