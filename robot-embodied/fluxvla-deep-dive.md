# FluxVLA — All-in-One VLA Engineering Platform

- **Repo**: FluxVLA/FluxVLA (295⭐, pushed 2026-04-23)
- **Description**: An all-in-one VLA engineering platform for embodied AI — from data to real-robot deployment
- **Relevance to Auto-Drive**: VLA (Vision-Language-Action) is the core paradigm for embodied AI. FluxVLA provides end-to-end tooling from data collection to deployment, which complements our ABot-Claw VLAC loop integration path.
- **Key comparison**: ABot-Claw = VLAC (adds Critic loop), FluxVLA = VLA (production pipeline). Both are relevant but serve different layers.

## Integration Potential
- FluxVLA could serve as the **training/data pipeline** for our robot agents
- ABot-Claw's VLAC loop could wrap FluxVLA's deployment output for real-time evaluation
- Auto-Drive idle loop monitors both repos for updates

## Next Steps
- [ ] Clone and analyze FluxVLA architecture when user project shifts to NAV_DOG
- [ ] Compare FluxVLA vs ABot-Claw VLA implementations
- [ ] Evaluate FluxVLA for Go2 deployment pipeline
