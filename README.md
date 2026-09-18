# 网罗代理

基于 SwitchyOmega 的代理管理工具，兼容 Manifest V3。

## 功能特点

- 轻松快捷地管理和切换多个代理设置
- 支持多种代理协议（HTTP、HTTPS、SOCKS4/5）
- 自动切换模式：根据条件自动选择代理
- PAC 脚本支持
- 规则列表导入/导出
- 支持 Chrome、Edge、Firefox 浏览器

## 安装

### Chrome / Edge

1. 下载最新的 `chromium-release.zip` 发布包
2. 解压到本地目录
3. 打开浏览器扩展管理页面 (`chrome://extensions/`)
4. 启用"开发者模式"
5. 点击"加载已解压的扩展程序"，选择解压后的目录

### Firefox

1. 下载最新的 `firefox-release.zip` 发布包
2. 在 Firefox 中打开 `about:debugging#/runtime/this-firefox`
3. 点击"临时载入附加组件"
4. 选择解压后的 `manifest.json` 文件

## 开发构建

```bash
# 需要 Node.js 20.x
cd omega-build
npm run deps    # 安装依赖
npm run build   # 构建项目
```

构建完成后，在 `omega-target-chromium-extension/build` 目录生成可加载的扩展。

## 项目结构

- `omega-pac` - PAC 脚本生成模块
- `omega-target` - 浏览器无关的配置管理逻辑
- `omega-web` - Web 配置界面
- `omega-target-chromium-extension` - Chromium 扩展目标实现
- `omega-locales` - 多语言翻译文件

## 许可证

GNU General Public License v3.0
