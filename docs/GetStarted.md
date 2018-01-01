# Get Started

## Deployment Strategies

### Asdf on production

- Install `asdf` on your local environment and the production environment.
- Fetch the code on the `publish_to` destination and start a phoeinx server
with `MIX_ENV=prod`.

#### Pros

- This is the simplest way to deploy an elixir application.
- Easy to setup.
- Easy to uprade.

#### Cons

- Installing `asdf` or other elixir/erlang version manager on the production
server.
- Production server and the final build has access to your code.


### Remote Distillery build + Deliver to production

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


### Local Distillery build w/ ERTS + Deliver to production
