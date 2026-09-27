<template>
  <el-container class="layout">
    <el-aside width="220px" class="aside">
      <div class="brand" @click="$router.push('/dashboard')">
        <div class="brand-badge">筑</div>
        <div>
          <div class="brand-name">筑安云</div>
          <div class="brand-sub">{{ meta.project.name || '智安协同平台' }}</div>
        </div>
      </div>
      <el-menu :default-active="$route.path" router class="menu">
        <el-menu-item index="/dashboard"><el-icon><DataBoard /></el-icon>安全看板</el-menu-item>
        <el-menu-item v-if="canReport" index="/report"><el-icon><Camera /></el-icon>隐患上报</el-menu-item>
        <el-menu-item index="/orders"><el-icon><Tickets /></el-icon>整改工单</el-menu-item>
        <el-menu-item v-if="canWeekly" index="/weekly"><el-icon><Document /></el-icon>安全周报</el-menu-item>
        <el-menu-item index="/chat"><el-icon><ChatDotRound /></el-icon>AI安全助手</el-menu-item>
        <el-menu-item index="/settings"><el-icon><Setting /></el-icon>系统设置</el-menu-item>
      </el-menu>
      <div class="aside-foot">
        <el-tag v-if="meta.ai_engine" :type="'success'" size="small" effect="dark">
          AI引擎：{{ meta.ai_engine }}
        </el-tag>
        <div class="db-line">数据库：{{ meta.db_mode === 'mysql' ? 'MySQL' : 'SQLite' }}</div>
      </div>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div class="header-title">{{ titleMap[$route.path] || '筑安云' }}</div>
        <div class="header-right">
          <el-tag effect="plain" type="info" size="small">{{ user.role_label }}</el-tag>
          <span class="uname">{{ user.name }}</span>
          <el-button link type="danger" @click="logout">退出</el-button>
        </div>
      </el-header>
      <el-main class="main"><router-view /></el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { userStore, useUserStore } from '../store'
import http from '../api'

const router = useRouter()
const user = computed(() => userStore.user || {})
const meta = ref({ project: {}, db_mode: '', ai_engine: '' })

const titleMap = {
  '/dashboard': '安全看板',
  '/report': '隐患上报',
  '/orders': '整改工单',
  '/weekly': '安全周报',
  '/chat': 'AI安全助手',
  '/settings': '系统设置',
}

const canReport = computed(() => ['safety_officer', 'safety_supervisor'].includes(user.value.role))
const canWeekly = computed(() => ['safety_officer', 'safety_supervisor', 'project_manager'].includes(user.value.role))

onMounted(async () => {
  try {
    meta.value = await http.get('/api/meta/info')
  } catch {}
})

function logout() {
  useUserStore().logout()
  router.push('/login')
}
</script>

<style scoped>
.layout { height: 100vh; }

/* ---- 侧栏 ---- */
.aside {
  background: linear-gradient(180deg, var(--z-navy-900) 0%, var(--z-navy-800) 44%, var(--z-navy-700) 100%);
  display: flex;
  flex-direction: column;
  border-right: 1px solid rgba(255, 255, 255, 0.06);
  box-shadow: 2px 0 14px rgba(9, 20, 50, 0.2);
}
.brand { display: flex; align-items: center; gap: 11px; padding: 20px 16px 16px; cursor: pointer; }
.brand-badge {
  width: 40px; height: 40px; flex: none; border-radius: 11px;
  background: linear-gradient(135deg, var(--z-blue-500), var(--z-blue-700));
  box-shadow: 0 4px 12px rgba(29, 91, 216, 0.45), inset 0 1px 0 rgba(255, 255, 255, 0.28);
  color: #fff; font-weight: 800; font-size: 19px;
  display: flex; align-items: center; justify-content: center;
}
.brand-name { color: #fff; font-weight: 700; font-size: 17px; letter-spacing: 0.5px; line-height: 1.35; }
.brand-sub {
  color: var(--z-side-text-dim); font-size: var(--z-fs-xs); letter-spacing: 0.3px;
  max-width: 130px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}

.menu {
  flex: 1;
  border-right: none;
  padding: 6px 10px;
  background: transparent;
  --el-menu-bg-color: transparent;
  --el-menu-text-color: var(--z-side-text);
  --el-menu-active-color: #ffffff;
  --el-menu-hover-bg-color: var(--z-side-hover);
}
.menu .el-menu-item {
  position: relative;
  height: 44px; line-height: 44px;
  margin-bottom: 4px;
  border-radius: var(--z-radius-sm);
  font-size: 14px;
  color: var(--z-side-text);
  transition: background 0.18s ease, color 0.18s ease, box-shadow 0.18s ease;
}
.menu .el-menu-item .el-icon { width: 17px; font-size: 17px; margin-right: 10px; }
.menu .el-menu-item:hover { color: #fff; background: var(--z-side-hover) !important; }
.menu .el-menu-item.is-active {
  background: linear-gradient(90deg, var(--z-blue-600), rgba(29, 91, 216, 0.72)) !important;
  color: #fff !important;
  font-weight: 600;
  box-shadow: 0 3px 12px rgba(29, 91, 216, 0.42);
}
.menu .el-menu-item.is-active::before {
  content: '';
  position: absolute; left: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 18px; border-radius: 0 3px 3px 0;
  background: var(--z-side-accent);
}

.aside-foot { padding: 12px 16px 14px; border-top: 1px solid rgba(255, 255, 255, 0.08); }
.aside-foot .el-tag {
  --el-tag-bg-color: rgba(103, 194, 58, 0.16);
  --el-tag-border-color: rgba(103, 194, 58, 0.36);
  --el-tag-text-color: var(--z-side-tag-text);
  border-radius: var(--z-radius-pill);
  font-weight: 600;
}
.db-line { color: var(--z-side-text-dim); font-size: var(--z-fs-xs); margin-top: 8px; letter-spacing: 0.2px; }

/* ---- 顶栏 ---- */
.header {
  height: 60px;
  padding: 0 22px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: space-between;
  border-bottom: 1px solid var(--z-border-light);
  box-shadow: 0 1px 4px rgba(23, 52, 110, 0.04);
}
.header-title {
  position: relative;
  padding-left: 12px;
  font-size: 16px; font-weight: 700; color: var(--z-text-1); letter-spacing: 0.3px;
}
.header-title::before {
  content: '';
  position: absolute; left: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 16px; border-radius: 2px; background: var(--z-blue-600);
}
.header-right { display: flex; align-items: center; gap: 12px; }
.header-right .el-tag { border-radius: var(--z-radius-pill); font-weight: 600; }
.uname { font-size: 14px; font-weight: 600; color: var(--z-text-2); }

.main { padding: 20px 22px 28px; overflow-y: auto; }
</style>
