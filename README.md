# Akd

[![Circle CI](https://circleci.com/gh/annkissam/akd.svg?style=svg)](https://circleci.com/gh/annkissam/akd)
[![Coverage Status](https://coveralls.io/repos/annkissam/akd/badge.svg?branch=master)](https://coveralls.io/r/annkissam/akd?branch=master)
[![Hex Version](http://img.shields.io/hexpm/v/akd.svg?style=flat)](https://hex.pm/packages/akd)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/akd.svg)](https://hex.pm/packages/akd)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/akd)
[![docs](https://inch-ci.org/github/annkissam/akd.svg)](http://inch-ci.org/github/annkissam/akd)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/annkissam/akd/master/LICENSE)

_Akd is Configurable, but easy to set up_

Akd is a framework that allows Elixir developers to easily write automated
deployment tasks. Akd is purely written in elixir.

The purpose of Akd is to encapsulate the entire deployment process into a
simple task.

A Deployment lifecycle in Akd is divided into various `Operations`. Each
`Operation` is encapsulated into an abstraction called `Hook`. A deployment is
a pipeline of `Hook`s which call individual `Operation`s.

Akd integrates seamlessly with packages like `Distillery` and `SimpleDocker` to
make the whole deployment process a cakewalk.

__MORE DOCS TO COME SOON__

## Installation

Akd is [available in Hex](https://hex.pm/docs/publish) and can be installed
by adding `akd` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:akd, "~> 0.2.0-rc.0"}]
end
```

