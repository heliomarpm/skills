# Referência: Web Performance (Core Web Vitals) e Testes de Carga (`sk-observability`)

Consulte este guia ao auditar desempenho de frontend (Core Web Vitals / bundle) ou planejar e interpretar testes de carga (k6, Artillery, Locust).

## 1. Core Web Vitals (p75 em usuários reais — RUM)
Meça primeiro em **RUM** (Real User Monitoring, p75 por rota e tipo de dispositivo); use **Lab** (Lighthouse CI / DevTools) para reproduzir e validar antes do merge.

| Métrica | Bom (p75) | Precisa melhorar | Principais alavancas |
| :--- | :---: | :---: | :--- |
| **LCP** (Largest Contentful Paint) | `<= 2,5 s` | `<= 4,0 s` | Reduzir TTFB, pré-carregar imagem hero (`fetchpriority="high"`), evitar CSS/JS bloqueante no `<head>`, SSR/CDN |
| **INP** (Interaction to Next Paint) | `<= 200 ms` | `<= 500 ms` | Quebrar *long tasks* (`> 50 ms`) da main thread, adiar scripts de terceiros, virtualizar listas grandes, minimizar re-renders |
| **CLS** (Cumulative Layout Shift) | `<= 0,1` | `<= 0,25` | Definir `width`/`height` ou `aspect-ratio` em imagens e mídias, reservar espaço de skeletons e banners assíncronos |
| **TTFB** (Time to First Byte, suporte) | `<= 800 ms` | `<= 1,8 s` | Cache de borda/CDN, otimização de queries (`sk-sql`), compressão `br`/`gzip`, *early hints* |

- **Orçamento de desempenho no CI**: defina teto de tamanho de bundle JS inicial (ex.: warning/falha em PRs via Lighthouse CI ou plugin do bundler) antes de introduzir dependências pesadas.
- **Armadilha de Lab**: nota 100 no Lighthouse desktop local não garante INP bom em celulares reais com CPU 4x mais lenta.

---

## 2. Testes de carga (k6 / Artillery / Locust)

### Regras obrigatórias de segurança e fidelidade
1. **Isolamento de ambiente**: **nunca** dispare testes de carga contra produção sem janela aprovada e autorização explícita do usuário. Use staging com dados sintéticos ou anonimizados (`sk-security`) e capacidade conhecida.
2. **Sem viés de cache**: parametrize payloads, IDs e buscas a partir de massa variada (evite repetir o mesmo ID 10.000 vezes e medir apenas cache quente).
3. **Think time realista**: inclua `sleep(...)` entre passos da jornada; laços sem pausa simulam ataque DDoS em vez de usuários reais.
4. **Limiares acoplados ao SLO**: valide `http_req_failed` e `http_req_duration` (`p(95)` / `p(99)`) contra o SLO acordado (seção 4).
5. **Correlacione carga com telemetria**: durante o teste, monitore CPU, memória, pool de conexões do banco, `pg_stat_statements` (`sk-sql`) e lag de filas (`sk-system-design`).

### Tipos de teste
- **Smoke** (1–5 VUs, 1–2 min): valida que o script e os endpoints respondem sem erro após deploy em staging.
- **Load** (carga esperada de pico): confirma atendimento do SLO em regime normal/pico.
- **Stress** (rampa acima do pico): encontra o ponto de quebra e verifica se há *rate limit* / *backpressure* ou colapso total.
- **Spike** (salto súbito): testa *autoscaling* (HPA), aquecimento de pool e proteção de cache contra *stampede*.
- **Soak / Endurance** (carga sustentada por horas): expõe vazamento de memória, *file descriptors* e esgotamento lento de conexões.

### Modelo enxuto em k6 (`smoke` / `load`)

```javascript
import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "1m", target: 20 },  // rampa
    { duration: "3m", target: 20 },  // patamar
    { duration: "30s", target: 0 },  // drenagem
  ],
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<400", "p(99)<900"],
  },
};

export default function () {
  const id = __VU * 1000 + (__ITER % 500);
  const res = http.get(`${__ENV.BASE_URL}/api/v1/pedidos?cliente=${id}`);
  check(res, { "status 200": (r) => r.status === 200 });
  sleep(1);
}
```

---

## 3. Armadilhas
- **Rodar teste de carga com gerador subdimensionado**: o gargalo fica na máquina do k6, não no sistema testado.
- **Testar apenas rota `GET` com ID fixo**: mede somente cache em memória e falha na produção real.
- **Ignorar erros 4xx/5xx na média de latência**: respostas rápidas de erro 500 fazem a latência média parecer melhor durante uma queda.
- **Confundir nota de Lighthouse Lab com experiência p75 em RUM.**
