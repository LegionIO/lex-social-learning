# lex-social-learning

Bandura Social Learning Theory implementation for LegionIO cognitive agents. Agents learn vicariously by observing other agents execute behaviors and acquire outcomes.

## What It Does

`lex-social-learning` models observational learning. The agent tracks a set of model agents whose behaviors it observes. Observed behaviors move through four acquisition stages — attention, retention, reproduction, motivation — before they can be reproduced. Model agent prestige updates based on observed outcomes, biasing which agents are imitated over time.

- **Model agents**: tracked agents with prestige scores (0.0–1.0) updated on each observed outcome
- **Observed behaviors**: staged acquisition from attention through retention to reproduction/motivation
- **Retention decay**: unaccessed behaviors decay at 0.02 per tick; reinforced behaviors gain +0.15
- **Prestige learning**: success boosts prestige; failure reduces it (gradient-style EMA)
- **Attention threshold**: behaviors from model agents with prestige < 0.3 are ignored

## Usage

```ruby
require 'legion/extensions/social_learning'

client = Legion::Extensions::SocialLearning::Client.new

# Register a model agent to observe
result = client.register_model_agent(name: 'senior_engineer', domain: :engineering)
model_id = result[:model_id]

# Observe the model agent executing a behavior
result = client.observe_agent_behavior(
  model_id: model_id,
  behavior: 'write_tests_first',
  outcome: :success
)
behavior_id = result[:behavior_id]
# prestige rises; behavior enters :attention stage

# Check what has been retained
client.retained_behaviors
# => { behaviors: [...], count: 1 }

# Reproduce a behavior
client.reproduce_observed_behavior(behavior_id: behavior_id)
# => { success: true, behavior: 'write_tests_first', stage: :attention }

# Reinforce after a successful reproduction
client.reinforce_reproduction(behavior_id: behavior_id, outcome: :success)
# => { retention: 1.0, stage: :retention }

# Best model agents by prestige
client.best_model_agents(limit: 5)

# Per-tick decay
client.update_social_learning
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
