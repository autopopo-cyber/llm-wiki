---
title: 裸机部署清单 — Ubuntu 24.04
created: 2026-04-24
updated: 2026-04-24
type: guide
tags: [deploy, ubuntu, setup]
---

# 裸机部署清单 — Ubuntu 24.04

> 新机器装完 Ubuntu 24.04 后，按此清单逐项部署。用户只需装 Tailscale，其余由主控 Agent 远程完成。

---

## 架构

```
主控 Agent（云服务器 100.80.136.1）
    ↕ Tailscale 虚拟网络
下属 Agent（本地服务器 100.64.63.98 / 新机器）
```

---

## 第零步：用户手动操作（5分钟）

装完 Ubuntu 24.04 后，只需做这一件事：

```bash
# 安装 Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# 浏览器授权 → 加入网络
```

然后告诉主控 Agent：
- Tailscale IP
- SSH 用户名和密码

**⚠️ 安装 Ubuntu 时注意：**
- 如果安装窗口花屏 → 启动参数加 `nomodeset`
- 选 **Ubuntu on Xorg**（不要选 Wayland）
- 勾选安装 **OpenSSH server**

---

## 第一步：SSH 免密登录（主控远程执行）

```bash
# 生成密钥（如果还没有）
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

# 推送公钥到新机器
ssh-copy-id -i ~/.ssh/id_ed25519.pub 用户名@Tailscale-IP

# 配置别名
cat >> ~/.ssh/config << 'EOF'

Host new-machine
    HostName Tailscale-IP
    User 用户名
    IdentityFile ~/.ssh/id_ed25519
EOF
```

---

## 第二步：换国内源

```bash
sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's|http://security.ubuntu.com|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update && sudo apt upgrade -y
```

---

## 第三步：基础工具

```bash
sudo apt install -y git curl wget vim htop tmux net-tools   python3 python3-pip python3-venv   jq unzip software-properties-common   apt-transport-https ca-certificates   openssh-server
```

---

## 第四步：时区

```bash
sudo timedatectl set-timezone Asia/Shanghai
```

---

## 第五步：梯子（mihomo 系统服务）

### 5.1 安装 mihomo

```bash
# 下载最新版（通过 gh-proxy 镜像）
VERSION=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" --proxy http://127.0.0.1:7890 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null || echo "v1.19.0")
curl -sL --max-time 90 -o /tmp/mihomo.gz "https://gh-proxy.com/https://github.com/MetaCubeX/mihomo/releases/download/${VERSION}/mihomo-linux-amd64-${VERSION}.gz"
gunzip -f /tmp/mihomo.gz && chmod +x /tmp/mihomo && sudo mv /tmp/mihomo /usr/local/bin/mihomo
```

### 5.2 下载 GeoIP

```bash
sudo mkdir -p /etc/mihomo
curl -sL --max-time 90 -o /etc/mihomo/geoip.metadb "https://gh-proxy.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb"
curl -sL --max-time 90 -o /etc/mihomo/geosite.dat "https://gh-proxy.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
```

### 5.3 订阅配置

**如果用户有 Clash 格式订阅链接：**

```bash
# 方式A：直接下载
curl -sL "订阅链接" -o /etc/mihomo/config.yaml
```

**如果是 Base64 订阅链接：** 需要转换成 Clash YAML 格式（主控 Agent 可远程转换生成）

### 5.4 注册系统服务

```bash
sudo tee /etc/systemd/system/mihomo.service > /dev/null << 'EOF'
[Unit]
Description=Mihomo Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mihomo
```

### 5.5 代理环境变量

```bash
cat >> ~/.bashrc << 'EOF'

# Mihomo Proxy
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
export all_proxy=socks5://127.0.0.1:7897
export no_proxy=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
EOF

source ~/.bashrc
```

### 5.6 验证

```bash
curl -sL --max-time 10 https://www.google.com -o /dev/null -w "%{http_code}\n"
# 输出 200 = 成功
```

### 5.7 可选：Clash Verge 图形界面

```bash
# 下载 .deb（通过代理）
wget -O /tmp/clash-verge.deb "https://gh-proxy.com/https://github.com/clash-verge-rev/clash-verge-rev/releases/latest/download/clash-verge_latest_amd64.deb"
sudo dpkg -i /tmp/clash-verge.deb
sudo apt install -f -y
```

> Clash Verge 只在需要换节点时打开，日常 mihomo 后台服务即可。

---

## 第六步：Hermes Agent

```bash
# 克隆仓库
git clone https://github.com/NousResearch/hermes-agent.git ~/hermes-agent
cd ~/hermes-agent

# 安装
python3 -m venv .venv
source .venv/bin/activate
pip install -e .

# 首次启动
hermes setup
```

### Hermes 配置要点

- Gateway 开启远程访问（绑定 0.0.0.0）
- 设置 WebUI token
- 配置 OpenRouter API Key
- 加入 A2A 网络（可选）

---

## 第七步：Nvidia 驱动（有 Nvidia 显卡时）

```bash
# 查看推荐驱动
ubuntu-drivers devices

# 自动安装
sudo ubuntu-drivers autoinstall

# 重启
sudo reboot

# 验证
nvidia-smi
```

---

## 第八步：拼音输入法（桌面版需要）

```bash
sudo apt install -y fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5
im-config -n fcitx5

cat >> ~/.bashrc << 'EOF'

# Fcitx5
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
EOF

source ~/.bashrc
# 需要重启或注销后生效
```

快捷键：`Ctrl+Space` 切换中英文

---

## 第九步：远程桌面（可选）

```bash
sudo apt install -y xrdp
sudo systemctl enable --now xrdp

# 如果用 xfce 桌面（更轻量）
sudo apt install -y xfce4 xfce4-goodies
echo "xfce4-session" > ~/.xsession
sudo systemctl restart xrdp
```

Windows 远程桌面连 `Tailscale-IP:3389`

---

## 第十步：Docker（可选）

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# 重新登录生效
```

---

## 常见问题

| 问题 | 解决 |
|------|------|
| 安装窗口花屏 | 启动参数加 `nomodeset`，或选 Xorg 会话 |
| dpkg 安装 deb 报错残留 | `sudo dpkg --purge --force-all 包名` |
| 无线网卡驱动不兼容 | 改用有线，或查 `ubuntu-drivers devices` |
| Tailscale 连不上 | 两边都跑 `tailscale status` 确认在同一网络 |
| SSH 拒绝连接 | `sudo apt install openssh-server && sudo systemctl enable --now ssh` |
| mihomo 启动失败 | `mihomo -t -d /etc/mihomo` 测试配置，缺 geoip 会报错 |
| Clash Verge 订阅导入失败 | Base64 订阅需转换成 Clash YAML 格式 |

---

## 快速部署脚本（主控 Agent 远程执行版）

```bash
# 一键部署（在主控端执行，远程 SSH 到新机器）
ssh new-machine 'bash -s' << 'SCRIPT'
# 换源
sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's|http://security.ubuntu.com|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources

# 基础工具
sudo apt update && sudo apt install -y git curl wget vim htop tmux net-tools python3 python3-pip python3-venv jq openssh-server

# 时区
sudo timedatectl set-timezone Asia/Shanghai

# SSH 免密（从主控推公钥）
mkdir -p ~/.ssh && chmod 700 ~/.ssh

echo "基础环境就绪，接下来装梯子和 Hermes"
SCRIPT
```

---

## 已部署机器

| 机器 | Tailscale IP | 角色 | 配置 |
|------|-------------|------|------|
| vm-0-16-ubuntu（云服务器） | 100.80.136.1 | 主控 | 2核/7.5G/120G |
| qin-Super-Server（本地） | 100.64.63.98 | 下属-1 | 48核/62G/218G |
| 新机器 | 待分配 | 下属-2 | 待补充 |
