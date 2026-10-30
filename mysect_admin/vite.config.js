import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import { apiServerPlugin } from './apiServerPlugin.js'

// https://vite.dev/config/
export default defineConfig({
  base: './',
  plugins: [react(), apiServerPlugin()],
})
