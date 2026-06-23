#set par(justify: true)

= Pregunta 3: Estrategia de Replicación para Desastres Regionales en FedEx Perú

Implementaría una *Estrategia Híbrida Multi-Región con Replicación Síncrona Selectiva* @kleppmann2017designing @postgres2026ha:

*Topología de Nodos:*
- *Primario (Lima)*: Procesa todas las escrituras transaccionales.
- *Standby Síncrono (Bogotá)*: Replicación física síncrona con `synchronous_commit = on` para tablas críticas (Inventarios, Pedidos). Garantiza RPO = 0.
- *Standbys Asíncronos (Santiago, México)*: WAL streaming asíncrono. Absorben consultas de lectura pesadas.

*Mecanismo de Failover:*
- Patroni + clúster etcd (Lima, Bogotá, Santiago) para quórum y prevención de Split-Brain.
- ante desastre regional en Perú: etcd detecta pérdida de conectividad → Bogotá es promovido automáticamente → DNS dinámico desvía tráfico → standbys restantes se reconectan a Bogotá.

*Justificación:* RTO < 30 segundos, RPO = 0 para datos críticos, rendimiento balanceado al limitar síncrona solo a la ruta de menor latencia.
