# Sources & attribution

Bibliothèque de skills Claude personnelle de keny4nn, synchronisée entre PC
(Monstre / Scar) via ce dépôt + `skills.ps1`.

## Installation / synchro
- **Bootstrap (nouveau PC)** : `irm https://raw.githubusercontent.com/keny4nn/claude-skills/master/setup-monster.ps1 | iex`
- **Local (depuis le clone)** : `.\skills.ps1` (installe + répare + diagnostic)
- **Publier mes skills locaux vers le dépôt** : `.\skills.ps1 -Push`
- Intégré au bouton **SYNC** de LOG : chaque sync installe/répare les skills automatiquement.

## Origine des skills
La plupart sont des skills communautaires ou maison. Quelques-uns proviennent de
dépôts publics, ré-hébergés ici pour la synchro perso (crédit aux auteurs) :

- **ECC** — `github.com/affaan-m/ECC` : `remotion-video-creation`, `video-editing`,
  `seo`, `accessibility`, `article-writing`, `python-patterns`.
- **claude-skills (curated)** : `canary`, `humanizer`, `prompt-master`, `watch`,
  `council`, `framer-motion`, `frontend-design`, `ui-ux-pro-max`.
- Les autres : suites GSAP / Three.js / Obsidian / design, etc. (sources upstream respectives).

> Dépôt **public** : si tu veux y stocker des skills privés/licenciés, passe-le en
> privé (`gh repo edit keny4nn/claude-skills --visibility private`) — `skills.ps1`
> bascule alors sur un clone authentifié.
