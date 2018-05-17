# Get Started

Once an elixir app is working, it's ready to be deployed, but deploying an
elixir application takes a lot of setup and customization. This is where `akd`
comes to the rescue. Akd integrates with elixir deployment packages (like
`distillery`) and combines it with custom generators and DSLs which make elixir
deployments painless. Akd is inspired by the ruby package `capistrano`, in the
way that it provides a similar way of interacting with the deployment servers.

In this document, we will be talking about different ways to deploy an elixir
application and how akd makes it easy to adopt either of those strategies.

## Deployment Strategies

### Remote Distillery build + Deliver to production

This is the recommended way to deploy an elixir application.

- Install `asdf` on a trusted build server which has similar configurations
as the production server (same OS, similar packages etc)
- Use `distillery` to build the code on the build server.
- Copy the `distillery` release to the production server.

#### Pros

- Do not have to put your code on the production server.
- Distillery is widely used, so a good amount of help is available.

#### Cons

- Build server has access to your code.
- Build server should have access to all the dependencies. (For `mix deps.get`)
- Build server should be close to production, which means if production gets
a major upgrade, so should the build server.

### Asdf on production

One of the deployment strategies is to deploy the app as a Mix project (with
the source code) to the destination. This is the simplest way to deploying an
elixir application without needing to configure or initialize another package.

#### Pros

- This is the simplest way to deploy an elixir application.
- Easy to setup.
- Easy to uprade elixir/OTP versions.

#### Cons

- Installing/Maintaining `asdf` or other elixir/erlang version manager on the
production server.
- Production server and the final build has access to your code.
- Deployments are not reproducible.
- Vulnerable to security attacks.
- Doesn't utilize OTP's abilities.

#### Steps to adopt this strategy

- Install `asdf` on your local environment and the production environment.
- Copy the code on the final destination and start a `mix phx.server` or a
`mix run --no-halt` with `MIX_ENV=prod`.

#### How akd does it




### Local Distillery build w/ ERTS + Deliver to production
