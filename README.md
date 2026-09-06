# tc_lib

> **Instalação:** use o zip da última release, não `git clone`. O repositório chama-se
> `tc-cfx-lib`, mas a pasta do recurso tem de se chamar **`tc_lib`** — o zip já vem correto.

Base partilhada dos recursos `tc_`. **Zero dependências externas.**

## Módulos
| Acesso | O que faz |
|---|---|
| `tc.logger` | logs com níveis (`tc_log_level`) |
| `tc.locale` | traduções por ficheiro JSON, com fallback e `dump()` para a NUI |
| `tc.callback` | pedidos cliente↔servidor com promessa e timeout |
| `tc.security` | throttle, validação de tipos, verificação de proximidade |
| `tc.cache` | memoização com TTL |
| `tc.utils` | uid, deepCopy, sanitize, round, try |
| `tc.player` | estado do jogador local (client) |
| `tc.points` | pontos de proximidade num só thread partilhado (client) |
| `tc.keys` | atalhos remapeáveis (client) |
| `tc.notify` `tc.progress` `tc.textui` | NUI partilhada |
| `tc.db` | consultas via `tc_db` (server) |

## Instalação
`ensure tc_lib` antes de qualquer recurso `tc_`. Compilar a NUI com `bun run build:lib`.

## Licença
**LGPL-3.0-or-later.** Usar em recursos fechados e pagos é livre, desde que o `tc_lib`
continue a ser um recurso separado. Modificar a biblioteca e distribuir a versão modificada
obriga a publicar as alterações sob a mesma licença. Ver `docs/licenca.md`.
