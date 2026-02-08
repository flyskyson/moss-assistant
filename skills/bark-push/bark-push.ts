/**
 * Bark 推送通知技能
 *
 * 用途：通过 Bark 服务向 iOS/Android 设备发送推送通知
 * 服务器：http://8.163.19.50:8080
 *
 * 使用方法：
 *   /bark "标题" "内容"
 *   /bark "标题" "内容" --sound=bell --group=通知
 */

import { Tool } from 'openclaw'

// 配置
const BARK_SERVER = process.env.BARK_SERVER || 'http://8.163.19.50:8080'
const BARK_DEVICE_KEY = process.env.BARK_DEVICE_KEY || ''

interface BarkOptions {
  sound?: string
  group?: string
  badge?: number
  url?: string
  icon?: string
  autoCopy?: string
  level?: 'timeless' | 'passive' | 'active'
}

interface BarkMessage {
  title: string
  body: string
  device_key?: string
  sound?: string
  group?: string
  badge?: number
  url?: string
  icon?: string
  autoCopy?: string
  level?: string
}

/**
 * 发送 Bark 推送通知
 */
export async function sendBark(
  title: string,
  body: string,
  options: BarkOptions = {}
): Promise<boolean> {
  // 检查配置
  if (!BARK_DEVICE_KEY) {
    throw new Error('未设置 BARK_DEVICE_KEY 环境变量，请先配置设备密钥')
  }

  const url = `${BARK_SERVER}/${BARK_DEVICE_KEY}/${encodeURIComponent(title)}/${encodeURIComponent(body)}`

  // 构建查询参数
  const params = new URLSearchParams()

  if (options.sound) params.append('sound', options.sound)
  if (options.group) params.append('group', options.group)
  if (options.badge) params.append('badge', options.badge.toString())
  if (options.url) params.append('url', options.url)
  if (options.icon) params.append('icon', options.icon)
  if (options.autoCopy) params.append('autoCopy', options.autoCopy)
  if (options.level) params.append('level', options.level)

  const fullUrl = params.toString() ? `${url}?${params.toString()}` : url

  try {
    const response = await fetch(fullUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    })

    if (response.ok) {
      const result = await response.json()
      console.log('✓ Bark 推送成功:', result)
      return true
    } else {
      console.error('✗ Bark 推送失败:', response.status, response.statusText)
      return false
    }
  } catch (error) {
    console.error('✗ Bark 推送异常:', error)
    return false
  }
}

/**
 * 发送高级 Bark 推送（JSON 格式）
 */
export async function sendAdvancedBark(
  title: string,
  body: string,
  options: BarkOptions = {}
): Promise<boolean> {
  if (!BARK_DEVICE_KEY) {
    throw new Error('未设置 BARK_DEVICE_KEY 环境变量')
  }

  const url = `${BARK_SERVER}/${BARK_DEVICE_KEY}`

  const message: BarkMessage = {
    title,
    body,
    ...options,
  }

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    })

    return response.ok
  } catch (error) {
    console.error('Bark 推送异常:', error)
    return false
  }
}

/**
 * 快捷推送预设
 */
export const BarkPresets = {
  // 系统通知
  system: (title: string, body: string) =>
    sendBark(title, body, {
      sound: 'bell',
      group: '系统通知',
      level: 'active',
    }),

  // 任务完成
  taskComplete: (taskName: string) =>
    sendBark('任务完成', `${taskName} 已完成`, {
      sound: 'healthnotification',
      group: '任务',
      badge: 1,
    }),

  // 错误警报
  error: (error: string) =>
    sendBark('错误警报', error, {
      sound: 'alarm',
      group: '错误',
      level: 'timeless',
    }),

  // 每日简报
  dailyBriefing: (content: string) =>
    sendBark('每日简报', content, {
      sound: ' anticipate',
      group: '简报',
    }),

  // AI 消息
  aiMessage: (message: string) =>
    sendBark('AI 消息', message, {
      sound: 'popcorn',
      group: 'AI',
    }),

  // 定时提醒
  reminder: (title: string, body: string) =>
    sendBark(title, body, {
      sound: 'bell',
      group: '提醒',
      level: 'active',
    }),
}

// CLI 工具
export const barkTool: Tool = {
  name: 'bark',
  description: '向 iOS/Android 设备发送 Bark 推送通知',
  parameters: {
    type: 'object',
    properties: {
      title: {
        type: 'string',
        description: '通知标题',
      },
      body: {
        type: 'string',
        description: '通知内容',
      },
      sound: {
        type: 'string',
        description: '通知声音 (bell, healthnotification, alarm, etc.)',
      },
      group: {
        type: 'string',
        description: '通知分组',
      },
    },
    required: ['title', 'body'],
  },
  execute: async (params) => {
    const { title, body, sound, group } = params as {
      title: string
      body: string
      sound?: string
      group?: string
    }

    return await sendBark(title, body, { sound, group })
  },
}

export default sendBark
