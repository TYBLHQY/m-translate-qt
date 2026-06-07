# Claude AI 助手配置

本项目已集成 Qt 官方 AI Skills，用于增强 Claude Code 和 GitHub Copilot 在 Qt 开发中的能力。

## 已安装的 Qt Agent Skills

这个项目现已安装 **9 个专业 Qt 开发技能**，位于 `.claude/skills/` 目录：

### 核心技能

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| **qt-qml** | 应用 QML 最佳实践 | 编写/处理 QML 代码时自动 |
| **qt-cpp-review** | 审查 C++ 代码 | `/qt-cpp-review` |
| **qt-qml-review** | 审查 QML 代码 | `/qt-qml-review` |
| **qt-qml-test** | 生成 QML 测试 | `/qt-qml-test [<path>]` |
| **qt-qml-test-run** | 运行 QML 测试 | `运行测试` 或 `ctest` |
| **qt-cpp-docs** | 生成 C++ 文档 | `生成文档` |
| **qt-qml-docs** | 生成 QML 文档 | `文档化 QML 组件` |
| **qt-qml-profiler** | 性能分析和优化 | `性能问题` |
| **qt-ui-design** | UI/UX 设计审查 | `设计 UI` 或 `审计 UX` |

### 快速开始

```bash
# 在编写 QML 代码时，自动应用 QML 最佳实践
# (无需手动触发，会自动应用)

# 审查 C++ 代码
/qt-cpp-review

# 审查 QML 代码
/qt-qml-review

# 为组件生成测试
/qt-qml-test src/components/MyButton.qml

# 运行现有的 QML 测试
运行 QML 测试
```

## 技能特性

### 代码审查 (cpp-review / qml-review)
- **60+ 自动检查**: 导入、弃用、性能、内存、线程安全
- **6 个并行分析**: 模型合约、生命周期、线程、API、错误处理、性能
- **智能评分**: 仅报告高置信度问题（>80/100 置信度）
- **可读输出**: 结构化报告，每个问题都有缓解建议

### QML 测试生成 (qml-test)
- 自动为 QML 组件生成 Qt Quick Test 用例
- 覆盖属性、信号、鼠标/键盘事件
- 使用 `TestCase`、`SignalSpy`、`tryCompare` 等
- 支持单个文件或批量生成

### 性能分析 (qml-profiler)
- 识别 QML/Qt Quick 性能瓶颈
- 提供针对性优化建议
- 诊断卡顿、帧率下降等问题

### 文档生成 (cpp-docs / qml-docs)
- 自动生成 Markdown 参考文档
- 提取类、函数、属性、信号的详细描述
- 包含使用示例

## 配置文件

所有技能配置存储在:
- **`.claude/skills/`** - 9 个 Qt 技能
- **`.claude/README.md`** - 详细的技能文档
- **`CLAUDE.md`** - 本文件（快速参考）

## 源代码

这些技能来自 Qt 官方开源项目:
- **仓库**: https://github.com/TheQtCompanyRnD/agent-skills
- **许可证**: LicenseRef-Qt-Commercial OR BSD-3-Clause
- **针对**: Qt 6.x

## 使用场景

### 开发阶段
```
"我写了一个新的 QML 组件，能帮我检查一下最佳实践吗？"
→ qt-qml 自动应用，生成优化代码
```

### 审查阶段
```
"/qt-cpp-review" 
→ 完整的 C++ 代码审查报告
```

### 测试阶段
```
"/qt-qml-test src/components"
→ 自动生成 tst_*.qml 测试文件
```

### 文档阶段
```
"为我的 QML 组件生成文档"
→ 生成完整的 Markdown 参考文档
```

## 提示和技巧

1. **自动触发**: 处理 QML 代码时，qt-qml 技能会自动应用最佳实践
2. **框架模式**: 对于 Qt 框架级别代码，使用 `/qt-cpp-review framework`
3. **批量操作**: qt-qml-test 支持目录和 glob 模式进行批量测试生成
4. **性能优化**: 遇到性能问题时，使用 qt-qml-profiler 获得诊断和建议

## 故障排除

- **技能未触发**: 确保触发词准确（见上表）
- **缺少参数**: 一些技能需要文件路径，如 `/qt-qml-test <path>`
- **更新技能**: 从源仓库重新克隆最新版本

## 更多帮助

访问 `.claude/README.md` 获取每个技能的详细文档。
