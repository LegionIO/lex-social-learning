# lex-social-learning

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-social-learning`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::SocialLearning`

## Purpose

Implements Bandura's Social Learning Theory for cognitive agents. The agent observes other model agents executing behaviors and acquiring outcomes, then learns vicariously through those observations. Behaviors move through four acquisition stages (attention, retention, reproduction, motivation) before becoming available for reproduction. Model agent prestige is updated based on observed outcome quality, biasing which agents the learning agent imitates.

## Gem Info

- **Gem name**: `lex-social-learning`
- **License**: MIT
- **Ruby**: >= 3.4
- **No runtime dependencies** beyond the Legion framework

## File Structure

```
lib/legion/extensions/social_learning/
  version.rb                            # VERSION = '0.1.0'
  helpers/
    constants.rb                        # limits, thresholds, rates, stages, outcome types, labels
    model_agent.rb                      # ModelAgent class — observed agent with prestige tracking
    observed_behavior.rb                # ObservedBehavior class — behavior with staged acquisition
    social_learning_engine.rb           # SocialLearningEngine class — full learning store
  runners/
    social_learning.rb                  # Runners::SocialLearning module — all public runner methods
  client.rb                             # Client class including Runners::SocialLearning
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_MODELS` | 200 | Maximum tracked model agents |
| `MAX_BEHAVIORS` | 500 | Maximum observed behaviors |
| `DEFAULT_PRESTIGE` | 0.5 | Starting prestige for new model agents |
| `ATTENTION_THRESHOLD` | 0.3 | Minimum prestige for the agent to attend to a model |
| `RETENTION_DECAY` | 0.02 | Per-tick retention decrease for unaccessed behaviors |
| `REINFORCEMENT_BOOST` | 0.15 | Retention increase on successful reproduction |
| `PUNISHMENT_PENALTY` | 0.2 | Retention decrease on failed reproduction |
| `PRESTIGE_LEARNING_RATE` | 0.1 | EMA-style step for prestige updates |
| `STALE_THRESHOLD` | 120 | Seconds before a behavior is considered stale |
| `OUTCOME_TYPES` | array | `:success`, `:failure`, `:partial`, `:unknown` |
| `LEARNING_STAGES` | 4 symbols | `:attention`, `:retention`, `:reproduction`, `:motivation` |
| `MODEL_LABELS` | hash | Named prestige tiers: low/moderate/high/authoritative |

## Helpers

### `Helpers::ModelAgent`

Observed agent whose behaviors and outcomes the learning agent tracks.

- `initialize(id:, name:, domain: :general, prestige: DEFAULT_PRESTIGE)` — observation_count=0, success_count=0
- `observe!(behavior:, outcome:)` — increments observation_count; if `:success` increments success_count; updates prestige via `prestige = prestige + PRESTIGE_LEARNING_RATE * (outcome_value - prestige)` where success=1.0, failure=0.0, partial=0.5
- `prestige_label` — maps prestige to MODEL_LABELS tiers
- `success_rate` — `success_count.to_f / [observation_count, 1].max`

### `Helpers::ObservedBehavior`

Single behavior observed from a model agent, with acquisition stage tracking.

- `initialize(id:, behavior:, model_id:, outcome:, domain: :general)` — retention=1.0, stage=:attention, observed_at=Time.now
- `decay_retention!` — decrements retention by RETENTION_DECAY; floors at 0.0
- `retained?` — retention >= 0.5
- `stale?` — `(Time.now - observed_at) > STALE_THRESHOLD`

### `Helpers::SocialLearningEngine`

Full learning store with model agents and observed behaviors.

- `register_model(name:, domain: :general)` — creates ModelAgent; returns nil if at MAX_MODELS
- `observe_behavior(model_id:, behavior:, outcome:)` — calls `model.observe!`, creates ObservedBehavior; returns nil if at MAX_BEHAVIORS
- `retained_behaviors(domain: nil)` — all behaviors with `retained? == true`, optionally filtered by domain
- `reproducible_behaviors` — retained behaviors with stage `:reproduction` or `:motivation`
- `reproduce(behavior_id)` — returns the behavior if found and reproducible
- `reinforce(behavior_id)` — boosts retention by REINFORCEMENT_BOOST; advances stage toward :motivation
- `punish(behavior_id)` — decrements retention by PUNISHMENT_PENALTY
- `best_models(limit: 5)` — sorted by prestige descending
- `domain_models(domain)` — all model agents in a given domain
- `decay_all` — decays all behavior retention values; removes behaviors with retention <= 0.0
- `prune_stale` — removes stale behaviors

## Runners

All runners are in `Runners::SocialLearning`. The `Client` includes this module and owns a `SocialLearningEngine` instance.

| Runner | Parameters | Returns |
|---|---|---|
| `register_model_agent` | `name:, domain: :general` | `{ success:, model_id:, name:, prestige: }` |
| `observe_agent_behavior` | `model_id:, behavior:, outcome: :unknown` | `{ success:, behavior_id:, retention:, model_prestige: }` |
| `retained_behaviors` | `domain: nil` | `{ success:, behaviors:, count: }` |
| `reproducible_behaviors` | (none) | `{ success:, behaviors:, count: }` |
| `reproduce_observed_behavior` | `behavior_id:` | `{ success:, behavior:, stage: }` |
| `reinforce_reproduction` | `behavior_id:, outcome: :success` | `{ success:, behavior_id:, retention:, stage: }` |
| `best_model_agents` | `limit: 5` | `{ success:, models:, count: }` |
| `domain_models` | `domain:` | `{ success:, models:, count: }` |
| `update_social_learning` | (none) | `{ success:, behaviors: }` — calls `decay_all` |
| `social_learning_stats` | (none) | Model count, behavior count, retained count, prestige distribution |

## Integration Points

- **lex-tick / lex-cortex**: `update_social_learning` wired as a tick handler runs the decay cycle each cognitive cycle
- **lex-identity**: model agents in social learning can be the same agents tracked in lex-identity's behavioral fingerprint; high-prestige models may bias identity formation
- **lex-trust**: model agents with high trust scores (from lex-trust) should have their prestige initialized higher
- **lex-mesh**: in multi-agent setups, mesh messages from other agents can trigger `observe_agent_behavior` calls when behaviors and outcomes are shared
- **lex-memory**: reproduced behaviors can be stored as memory traces with `origin: :social_learning` for later recall

## Development Notes

- Prestige update uses a gradient-like step: `prestige + rate * (outcome_value - prestige)` — this is not strictly EMA but has the same dampening property
- `ATTENTION_THRESHOLD = 0.3` is defined as a gate for observation — the engine checks prestige before registering a behavior observation from a low-prestige model
- Stage advancement on `reinforce`: `:attention` -> `:retention` -> `:reproduction` -> `:motivation`; `punish` does not reverse stage
- `MAX_BEHAVIORS = 500` with `RETENTION_DECAY = 0.02` means behaviors with no reinforcement fully decay in ~50 ticks (assuming 1-tick-per-call); in practice, the ring buffer prune handles capacity before that
- Stale threshold of 120 seconds is real-time based, not tick-based
