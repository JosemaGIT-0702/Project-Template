# Physics working rules

- State assumptions explicitly (approximations, orders in couplings, massless limits,
  which diagrams are included) in the script header and in the paper.
- Before trusting a new result, check at least one of: dimensional analysis, known
  limits (massless, soft/collinear, threshold, high-energy), symmetries, gauge
  independence / Ward identities, unitarity bounds, comparison with literature
  (quote equation numbers and convert conventions explicitly).
- When comparing with a paper, record in `literature/<texkey>.md` the conventions it
  uses and how they map to `notes/conventions.md`.
- Distinguish clearly between what was computed/verified and what is conjectured or
  recalled from memory. Never present an unverified formula as established.
- Signs and factors of 2, π, i are the usual failure points: track them explicitly
  and test them numerically.
