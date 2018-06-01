# Akd

[![Circle CI](https://circleci.com/gh/annkissam/akd.svg?style=svg)](https://circleci.com/gh/annkissam/akd)
[![Coverage Status](https://coveralls.io/repos/github/annkissam/akd/badge.svg?branch=master)](https://coveralls.io/github/annkissam/akd?branch=master)
[![Hex Version](http://img.shields.io/hexpm/v/akd.svg?style=flat)](https://hex.pm/packages/akd)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/akd.svg)](https://hex.pm/packages/akd)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/akd)
[![docs](https://inch-ci.org/github/annkissam/akd.svg)](http://inch-ci.org/github/annkissam/akd)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/annkissam/akd/master/LICENSE)

_Akd is Configurable, but easy to set up_

Akd is a framework that allows Elixir developers to easily write automated
deployment tasks. Akd is purely written in elixir.

Akd, in its purest form, is a way of executing a list of operations on a remote
(or local) machine. Akd provides an intuitive DSL that allows developers to easily
define a pipeline consisting of a set of these operations along with corresponding,
remedial operations, in the event that one or more of the primary pipeline
operations fails. If you have experience with the Ruby gem `capistrano`, Akd
should feel familiar.

Akd's primary goal is twofold:
- to provide developers with the ability to easily compose a series of deloyment
operations using the Elixir programming language, and
- to standardize the way in which Elixir application deployments (using tools
like `distillery` or `docker`) are performed.

A Deployment lifecycle in Akd is divided into various `Operations`.
`Operation`s is grouped into an abstraction called `Hook`. A deployment is
a pipeline of `Hook`s which call individual `Operation`s.

Akd integrates seamlessly with packages like `Distillery` and `SimpleDocker` to
make the whole deployment process a cakewalk.

For details on how to setup a new project with `akd` checkout the `Walkthrough`.

## Installation

Akd is [available in Hex](https://hex.pm/docs/publish) and can be installed
by adding `akd` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:akd, "~> 0.2.1"}]
end
```

