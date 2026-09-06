<script setup lang="ts">
// Camada visual partilhada: notificações, barra de progresso e texto de ajuda.
// Todos os produtos tc_ desenham através daqui, para haver uma só identidade
// visual e uma só NUI carregada em memória.
import { ref, onMounted, onUnmounted } from 'vue'

type Notification = { id: string; title?: string; description: string; type: string; duration: number }

const notifications = ref<Notification[]>([])
const progress = ref<{ label: string; duration: number } | null>(null)
const hint = ref<{ text: string; icon?: string } | null>(null)

function push(item: Notification): void {
  notifications.value.push(item)
  setTimeout(() => {
    notifications.value = notifications.value.filter((entry) => entry.id !== item.id)
  }, item.duration)
}

function handleMessage(event: MessageEvent): void {
  const { module, action, payload } = event.data ?? {}

  if (module === 'notify' && action === 'push') push(payload as Notification)
  if (module === 'progress') progress.value = action === 'start' ? (payload as { label: string; duration: number }) : null
  if (module === 'textui') hint.value = action === 'show' ? (payload as { text: string; icon?: string }) : null
}

onMounted(() => window.addEventListener('message', handleMessage))
onUnmounted(() => window.removeEventListener('message', handleMessage))
</script>

<template>
  <div class="notifications">
    <div v-for="item in notifications" :key="item.id" class="toast" :data-type="item.type">
      <strong v-if="item.title">{{ item.title }}</strong>
      <span>{{ item.description }}</span>
    </div>
  </div>

  <div v-if="progress" class="progress">
    <span>{{ progress.label }}</span>
    <div class="track"><div class="fill" :style="{ animationDuration: `${progress.duration}ms` }" /></div>
  </div>

  <div v-if="hint" class="hint">{{ hint.text }}</div>
</template>

<style scoped>
.notifications { position: absolute; top: 24px; right: 24px; display: flex; flex-direction: column; gap: 8px; }
.toast {
  display: flex; flex-direction: column; gap: 2px;
  min-width: 240px; max-width: 320px; padding: 12px 14px;
  background: var(--tc-surface); border-left: 3px solid var(--tc-accent);
  border-radius: var(--tc-radius); color: var(--tc-text); font-size: 14px;
}
.toast[data-type='success'] { border-left-color: #3fb98a; }
.toast[data-type='warning'] { border-left-color: #e0a34a; }
.toast[data-type='error'] { border-left-color: #e05a5a; }
.toast strong { font-weight: 600; }

.progress { position: absolute; bottom: 96px; left: 50%; transform: translateX(-50%); width: 320px; text-align: center; color: var(--tc-text); font-size: 14px; }
.track { height: 4px; margin-top: 8px; background: var(--tc-line); border-radius: 2px; overflow: hidden; }
.fill { height: 100%; width: 100%; background: var(--tc-accent); transform-origin: left; animation: fill linear forwards; }
@keyframes fill { from { transform: scaleX(0); } to { transform: scaleX(1); } }

.hint { position: absolute; bottom: 48px; left: 50%; transform: translateX(-50%); padding: 8px 14px; background: var(--tc-surface); border: 1px solid var(--tc-line); border-radius: var(--tc-radius); color: var(--tc-text); font-size: 14px; }

@media (prefers-reduced-motion: reduce) { .fill { animation: none; transform: scaleX(1); } }
</style>
