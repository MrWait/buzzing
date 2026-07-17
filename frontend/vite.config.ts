import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// 需要 dedupe 的 ProseMirror 相关包
// 背景：Vite 会分别对 y-prosemirror(src ESM) 和其他 prosemirror-* CJS 依赖做 optimize，
// 可能各自内联出一份 prosemirror-model 副本，导致 `text.contentMatch !== ContentMatch.empty`
// 的引用比较失败（表现：mark 无法应用到 text 节点上）。
const PROSEMIRROR_PKGS = [
  'prosemirror-model',
  'prosemirror-state',
  'prosemirror-view',
  'prosemirror-transform',
  'prosemirror-keymap',
  'prosemirror-commands',
  'prosemirror-schema-list',
  'prosemirror-schema-basic',
  'prosemirror-inputrules',
  'prosemirror-history',
  'prosemirror-tables',
  'prosemirror-example-setup',
  'prosemirror-menu',
  'prosemirror-dropcursor',
  'prosemirror-gapcursor',
]

export default defineConfig({
  base: '/',
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
    dedupe: PROSEMIRROR_PKGS,
  },
  optimizeDeps: {
    include: PROSEMIRROR_PKGS,
  },
  server: {
    proxy: {
      '/api': {
        target: 'https://localhost:5150',
        changeOrigin: true,
        secure: false,
      },
      '/office/ws': {
        target: 'wss://localhost:5150',
        ws: true,
        secure: false,
      },
    },
  },
})
