import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { buildOut } from '../../../tools/build/paths'

export default defineConfig({
  plugins: [vue()],
  base: './',
  build: {
    // Árvore única. O `web/dist` interno é o que o fxmanifest do tc_lib procura
    // (`ui_page 'web/dist/index.html'`), e é assim que a base é distribuída.
    outDir: buildOut('tc_lib', 'web/dist'),
    emptyOutDir: true,
    sourcemap: false,
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
})
