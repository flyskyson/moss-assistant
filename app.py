"""
MOSS Assistant - Streamlit Web UI
"""

import streamlit as st
import os
from pathlib import Path

# 页面配置
st.set_page_config(
    page_title="MOSS Assistant",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# 自定义 CSS
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        margin-bottom: 1rem;
    }
    .chat-message {
        padding: 1rem;
        border-radius: 0.5rem;
        margin-bottom: 1rem;
    }
    .user-message {
        background-color: #e3f2fd;
        border-left: 4px solid #1f77b4;
    }
    .assistant-message {
        background-color: #f5f5f5;
        border-left: 4px solid #4caf50;
    }
    .role-badge {
        display: inline-block;
        padding: 0.25rem 0.5rem;
        border-radius: 0.25rem;
        font-size: 0.875rem;
        margin-left: 0.5rem;
    }
    .role-mentor { background-color: #fff3e0; color: #e65100; }
    .role-partner { background-color: #e3f2fd; color: #1565c0; }
    .role-secretary { background-color: #f3e5f5; color: #7b1fa2; }
    .role-friend { background-color: #e8f5e9; color: #2e7d32; }
</style>
""", unsafe_allow_html=True)

# 初始化 session state
if "moss" not in st.session_state:
    from moss import MOSSAssistant
    st.session_state.moss = MOSSAssistant()

if "messages" not in st.session_state:
    st.session_state.messages = []

if "conversation_started" not in st.session_state:
    st.session_state.conversation_started = False


def main():
    """主函数"""

    # 侧边栏
    with st.sidebar:
        st.header("🤖 MOSS Assistant")

        st.markdown("---")

        # 用户信息
        st.subheader("👤 用户信息")
        user_model = st.session_state.moss.user_model_manager.get_model()
        basic_info = user_model.get("basic_info", {})

        with st.expander("查看/编辑信息"):
            name = st.text_input("姓名", basic_info.get("name", ""))
            if st.button("保存姓名") and name:
                st.session_state.moss.update_user_info("name", name)
                st.success("已保存！")

        # 统计信息
        st.markdown("---")
        st.subheader("📊 统计信息")
        stats = user_model.get("stats", {})
        st.metric("对话次数", stats.get("total_conversations", 0))
        st.metric("交互次数", stats.get("total_interactions", 0))

        # 角色使用情况
        roles_used = stats.get("roles_used", {})
        if roles_used:
            st.markdown("**角色使用分布:**")
            for role, count in roles_used.items():
                st.write(f"- {role}: {count} 次")

        # 目标
        st.markdown("---")
        st.subheader("🎯 当前目标")
        goals = user_model.get("goals", {})

        with st.expander("查看目标"):
            for timeframe in ["short_term", "medium_term", "long_term"]:
                if goals.get(timeframe):
                    st.markdown(f"**{timeframe}:**")
                    for goal in goals[timeframe]:
                        st.write(f"- {goal}")

        new_goal = st.text_input("添加新目标")
        if st.button("添加目标"):
            st.session_state.moss.add_goal(new_goal)
            st.success("已添加！")

        # 备份
        st.markdown("---")
        if st.button("💾 备份数据"):
            st.session_state.moss.backup()
            st.success("备份完成！")

        # 重新开始
        st.markdown("---")
        if st.button("🔄 重新开始"):
            st.session_state.messages = []
            st.session_state.conversation_started = False
            st.rerun()

    # 主界面
    st.markdown('<h1 class="main-header">🤖 MOSS Assistant</h1>', unsafe_allow_html=True)
    st.markdown("*苏格拉底式辩论伙伴 + 全能个人助理*")

    # 欢迎信息（冷启动）
    if not st.session_state.conversation_started:
        with st.chat_message("assistant"):
            greeting = st.session_state.moss.start_conversation()
            st.markdown(greeting)
            st.session_state.conversation_started = True
            st.session_state.messages.append({"role": "assistant", "content": greeting})

    # 显示聊天历史
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
            if "role_type" in message:
                st.markdown(
                    f'<span class="role-badge role-{message["role_type"]}">🎭 {message["role_label"]}</span>',
                    unsafe_allow_html=True
                )

    # 聊天输入
    if prompt := st.chat_input("和 MOSS 对话..."):
        # 显示用户消息
        with st.chat_message("user"):
            st.markdown(prompt)
        st.session_state.messages.append({"role": "user", "content": prompt})

        # 获取 MOSS 响应
        with st.chat_message("assistant"):
            with st.spinner("思考中..."):
                response = st.session_state.moss.chat(prompt)

            # 显示响应
            st.markdown(response)

            # 显示角色信息
            user_model = st.session_state.moss.user_model_manager.get_model()
            last_interaction = user_model.get("stats", {}).get("roles_used", {})

            if last_interaction:
                last_role = list(last_interaction.keys())[-1]
                role_names = {
                    "mentor": "导师",
                    "partner": "伙伴",
                    "secretary": "秘书",
                    "friend": "朋友"
                }
                role_label = role_names.get(last_role, last_role)
                st.markdown(
                    f'<span class="role-badge role-{last_role}">🎭 {role_label}</span>',
                    unsafe_allow_html=True
                )

                st.session_state.messages.append({
                    "role": "assistant",
                    "content": response,
                    "role_type": last_role,
                    "role_label": role_label
                })
            else:
                st.session_state.messages.append({"role": "assistant", "content": response})


if __name__ == "__main__":
    main()
