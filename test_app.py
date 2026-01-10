"""简单的 Streamlit 测试页面"""
import streamlit as st

st.set_page_config(
    page_title="MOSS 测试",
    page_icon="🤖",
    layout="wide"
)

st.title("🤖 MOSS Assistant 测试页面")

st.write("如果你能看到这个页面，说明 Streamlit 运行正常！")

st.markdown("---")

if st.button("测试按钮"):
    st.success("✓ 按钮工作正常！")

st.markdown("---")
st.write("### 配置信息")
st.write(f"- Streamlit 版本: {st.__version__}")
st.write(f"- Python 版本: 3.x")
