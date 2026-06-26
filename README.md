# Chrome Docker for 2G2C Server

这是一个专门给 `2G RAM / 2 vCPU` 服务器准备的轻量 Chromium 容器方案，目标是:

- 能直接在服务器运行
- 通过浏览器远程访问
- 尽量降低卡顿和内存占用
- 保留持久化用户数据

## 设计思路

相比完整桌面环境，这套方案只保留最低必要组件:

- `Chromium`: 浏览器本体
- `Xvfb`: 虚拟显示
- `Openbox`: 超轻量窗口管理器
- `x11vnc`: 暴露 VNC
- `noVNC + websockify`: 直接通过网页访问
- `supervisord`: 统一拉起和保活

这样做比跑完整 Ubuntu 桌面更省内存，也更适合小规格云服务器。

## 快速启动

```bash
docker compose up -d --build
```

启动后访问:

- noVNC: `http://你的服务器IP:6080/vnc.html`
- VNC: `你的服务器IP:5900`

默认必须设置 `VNC_PASSWORD`，未设置时容器会直接退出。

## 默认优化

已经内置这些适合 `2G2C` 的优化:

- 限制 Chromium renderer 进程数 `--renderer-process-limit=2`
- 启用 `--process-per-site`
- 关闭后台网络、翻译、崩溃上报、扩展等无关功能
- 关闭 GPU 和软件光栅，避免小机器上额外开销
- 将 `/tmp` 和 `/dev/shm` 放到 `tmpfs`
- 浏览器缓存单独持久化，避免频繁写容器层
- 默认分辨率控制在 `1280x720`

## 可调参数

可以通过 `docker-compose.yml` 里的环境变量调整:

```yaml
environment:
  SCREEN_WIDTH: "1280"
  SCREEN_HEIGHT: "720"
  VNC_PASSWORD: "你的强密码"
  CHROME_EXTRA_FLAGS: ""
```

例如你想进一步省资源:

```yaml
environment:
  SCREEN_WIDTH: "1024"
  SCREEN_HEIGHT: "640"
  CHROME_EXTRA_FLAGS: "--force-device-scale-factor=1 --disable-features=UseSkiaRenderer"
```

## 2G2C 机器建议

建议直接用下面这组配置:

- 分辨率保持 `1280x720` 或更低
- 不要同时开太多标签页
- 如果只是自动化用途，尽量只保留单站点任务
- 如果服务器 Swap 太小，建议额外开 `1G` 左右 Swap

## 常用命令

```bash
docker compose logs -f
docker compose restart
docker compose down
```

## 后续可扩展

如果你后面要继续做，我可以直接帮你再补:

- 国内服务器可用的字体和输入法优化
- 账号登录态持久化
- Playwright / Selenium 自动化支持
- 代理配置
- 一键部署脚本
