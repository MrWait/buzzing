<template>
  <div class="module-layout">
    <header v-if="showTopbar" class="module-topbar">
      <TopRightBar />
    </header>
    <RouterView />
  </div>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
import TopRightBar from '@/components/TopRightBar.vue'
import { computed } from 'vue'

const route = useRoute()
// 编辑器页面自己管理头栏，不渲染布局级 topbar
const showTopbar = computed(() => route.name !== 'OfficeEditor')
</script>

<style scoped>
.module-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.module-topbar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  height: 44px;
  padding: 0 16px;
  background: #f5f5f5;
  border-bottom: 1px solid #e0e0e0;
}
</style>
